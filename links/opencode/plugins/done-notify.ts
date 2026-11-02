import { execFile } from "node:child_process"
import { realpathSync } from "node:fs"
import { basename, join } from "node:path"

// Raises a desktop toast (Windows, via WSL) when a top-level session finishes a turn that
// took at least OPENCODE_NOTIFY_MIN_SECONDS (default 180), ended in an error, or was
// explicitly requested (user interruptions never notify) with the notify_when_done tool.
// OPENCODE_NOTIFY=0 disables it.
// A plain object, because OpenCode does not resolve @opencode/plugin for local plugin files.
export default {
  id: "done-notify",
  async setup(ctx: any) {
    if (process.env.OPENCODE_NOTIFY === "0") return
    const minMs = (Number(process.env.OPENCODE_NOTIFY_MIN_SECONDS) || 180) * 1000
    const toast = join(realpathSync(import.meta.dirname), "../../bin/notify.d/win-toast")

    type Turn = { start: number; requested: boolean }
    const turns = new Map<string, Turn>()
    const running = new Set<string>()
    const parents = new Map<string, Promise<string | undefined>>()
    const turn = (id: string) => turns.get(id) ?? turns.set(id, { start: Date.now(), requested: false }).get(id)!

    const parentOf = (id: string) => {
      if (!parents.has(id)) {
        parents.set(id, ctx.session.get({ sessionID: id }).then((s: any) => s?.parentID, () => undefined))
      }
      return parents.get(id)!
    }
    const rootOf = async (id: string) => {
      for (let parent = await parentOf(id); parent; parent = await parentOf(id)) id = parent
      return id
    }

    const run = (file: string, args: string[]) =>
      new Promise<string>((resolve, reject) =>
        execFile(file, args, { timeout: 25_000 }, (err, stdout, stderr) =>
          err ? reject(new Error(stderr.trim() || err.message)) : resolve(stdout.trim()),
        ),
      )

    const tmuxWindow = async () => {
      const pane = process.env.TMUX_PANE
      return pane ? run("tmux", ["display-message", "-p", "-t", pane, "#S:#W"]).catch(() => "") : ""
    }

    const formatDuration = (ms: number) => {
      const s = Math.round(ms / 1000)
      return s >= 60 ? `${Math.floor(s / 60)}m${String(s % 60).padStart(2, "0")}s` : `${s}s`
    }

    const notify = async (id: string, t: Turn, error?: string) => {
      const title = (await ctx.session.get({ sessionID: id }).catch(() => undefined))?.title ?? id
      const where = [basename(ctx.location?.directory ?? ""), await tmuxWindow()].filter(Boolean).join(" · ")
      const took = formatDuration(Date.now() - t.start)
      const body = [title, [where, took].filter(Boolean).join(" · "), error].filter(Boolean).join("\n")
      await run(toast, [error ? "opencode: error" : "opencode: done", body]).catch((err) =>
        console.warn(`done-notify: toast failed: ${err instanceof Error ? err.message : err}`),
      )
    }

    // A turn ends when its root session stops and none of its subagents still run; a subagent's
    // report wakes the root again, which continues the same turn.
    const finish = async (id: string, outcome: "succeeded" | "failed" | "interrupted", error?: string) => {
      running.delete(id)
      if (await parentOf(id)) return
      const t = turns.get(id)
      if (!t) return
      if (outcome === "succeeded") {
        for (const other of running) if ((await rootOf(other)) === id) return
      }
      turns.delete(id)
      if (outcome === "interrupted") return
      if (error || t.requested || Date.now() - t.start >= minMs) await notify(id, t, error)
    }

    await ctx.tool.transform((editor: any) => {
      editor.add({
        name: "notify_when_done",
        description:
          "Request a desktop notification when the current turn finishes, regardless of how long it takes. " +
          "Call this when the user asks to be notified, pinged, or alerted when you are done.",
        input: { type: "object", properties: {}, additionalProperties: false },
        execute: async (_input: unknown, context: { sessionID: string }) => {
          turn(await rootOf(context.sessionID)).requested = true
          return { content: "The user will be notified when this turn finishes." }
        },
      })
    })

    const abort = new AbortController()
    void (async () => {
      const types = [
        "session.execution.started",
        "session.execution.succeeded",
        "session.execution.failed",
        "session.execution.interrupted",
      ]
      for await (const event of ctx.event.subscribe({ types, signal: abort.signal })) {
        const id = event.data.sessionID
        if (event.type === "session.execution.started") {
          running.add(id)
          if (!(await parentOf(id))) turn(id)
        } else if (event.type === "session.execution.failed") {
          await finish(id, "failed", event.data.error?.message ?? "Error")
        } else {
          await finish(id, event.type === "session.execution.succeeded" ? "succeeded" : "interrupted")
        }
      }
    })().catch((err) => {
      if (!abort.signal.aborted) console.warn(`done-notify: event stream ended: ${err}`)
    })
    return () => abort.abort()
  },
}
