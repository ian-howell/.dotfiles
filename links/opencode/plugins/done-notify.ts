import { type Plugin, tool } from "@opencode-ai/plugin"
import { execFile } from "node:child_process"
import { realpathSync } from "node:fs"
import { basename, join } from "node:path"

// Raises a desktop toast (Windows, via WSL) when a top-level session finishes a turn that
// took at least OPENCODE_NOTIFY_MIN_SECONDS (default 180), ended in an error, or was
// explicitly requested (user interruptions never notify) with the notify_when_done tool. OPENCODE_NOTIFY=0 disables it.
// Only the plugin may be exported: OpenCode treats every export of a plugin file as a plugin.
export const DoneNotifyPlugin: Plugin = async ({ client, directory }) => {
  const disabled = process.env.OPENCODE_NOTIFY === "0"
  const minMs = (Number(process.env.OPENCODE_NOTIFY_MIN_SECONDS) || 180) * 1000
  const toast = join(realpathSync(import.meta.dirname), "../../bin/notify.d/win-toast")

  type Turn = { start?: number; requested: boolean; error?: string; aborted?: boolean }
  const turns = new Map<string, Turn>()
  const parents = new Map<string, string | undefined>()
  const turn = (id: string) => turns.get(id) ?? turns.set(id, { requested: false }).get(id)!

  const log = (level: "info" | "warn", message: string) =>
    client.app.log({ body: { service: "done-notify", level, message } }).catch(() => {})

  const session = async (id: string) => (await client.session.get({ path: { id } })).data
  const parentOf = async (id: string) => {
    if (!parents.has(id)) parents.set(id, (await session(id).catch(() => undefined))?.parentID)
    return parents.get(id)
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

  const notify = async (id: string, t: Turn) => {
    const title = (await session(id).catch(() => undefined))?.title ?? id
    const where = [basename(directory), await tmuxWindow()].filter(Boolean).join(" · ")
    const took = t.start ? formatDuration(Date.now() - t.start) : ""
    const body = [title, [where, took].filter(Boolean).join(" · "), t.error].filter(Boolean).join("\n")
    await run(toast, [t.error ? "opencode: error" : "opencode: done", body]).catch((err) =>
      log("warn", `Toast failed: ${err instanceof Error ? err.message : err}`),
    )
  }

  return {
    event: async ({ event }) => {
      if (disabled) return
      if (event.type === "session.status" && event.properties.status.type === "busy") {
        const t = turn(event.properties.sessionID)
        t.start ??= Date.now()
      } else if (event.type === "session.error" && event.properties.sessionID) {
        const err = event.properties.error
        const t = turn(event.properties.sessionID)
        // User interruptions (Esc) never notify: the user is already at the terminal.
        if (err?.name === "MessageAbortedError") t.aborted = true
        else t.error = (err?.data as { message?: string })?.message ?? err?.name ?? "Error"
      } else if (event.type === "session.idle") {
        const id = event.properties.sessionID
        const t = turns.get(id)
        turns.delete(id)
        if (!t || t.aborted || (await parentOf(id))) return
        const long = t.start !== undefined && Date.now() - t.start >= minMs
        if (long || t.requested || t.error) await notify(id, t)
      }
    },

    tool: {
      notify_when_done: tool({
        description:
          "Request a desktop notification when the current turn finishes, regardless of how long it takes. " +
          "Call this when the user asks to be notified, pinged, or alerted when you are done.",
        args: {},
        async execute(_args, context) {
          if (disabled) return "Notifications are disabled (OPENCODE_NOTIFY=0)."
          const t = turn(await rootOf(context.sessionID))
          t.requested = true
          return "The user will be notified when this turn finishes."
        },
      }),
    },
  }
}
