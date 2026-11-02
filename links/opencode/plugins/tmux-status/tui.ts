import { execFile } from "node:child_process"
import { promisify } from "node:util"

const exec = promisify(execFile)
const option = "@opencode-status"
const titleOption = "@opencode-title"

// Runs in the TUI so each client updates its own pane, including attached clients.
// A plain object, because OpenCode does not resolve @opencode/plugin for local plugin files.
export default {
  id: "tmux-turn-status",
  setup(context: any) {
    const pane = process.env.TMUX_PANE
    if (!process.env.TMUX || !pane || !/^%\d+$/.test(pane)) return

    const session = context.data.session
    // The last finished turn of each root session: "✓" done or "!" failed.
    const marks = new Map<string, string>()
    // Open permission and question requests, by request ID.
    const requests = new Map<string, string>()
    let previous: { mark: string; title: string } | undefined
    let disposed = false
    let reported = false
    let pending = Promise.resolve()

    const isRoot = (id: string) => !session.get(id)?.parentID

    function publish(mark: string, title: string) {
      if (disposed || (mark === previous?.mark && title === previous?.title)) return
      previous = { mark, title }
      // Serialize writes so a fast busy -> idle transition cannot land backwards.
      pending = pending.then(async () => {
        if (disposed) return
        try {
          await exec("tmux", [
            "set-option", "-p", "-t", pane, option, mark,
            ";", "set-option", "-p", "-t", pane, titleOption, title,
          ], { timeout: 2000 })
          reported = false
        } catch (error) {
          previous = undefined
          if (!reported && !disposed) {
            reported = true
            context.ui.toast.show({ title: "Tmux status/title update failed", message: String(error), variant: "error" })
          }
        }
      })
    }

    function refresh() {
      if (disposed) return
      const route = context.ui.router.current()
      if (route.type !== "session") return publish("", "")
      // The title follows the displayed session; status rolls up to its root.
      const root = session.root(route.sessionID)
      const family = session.family(root)
      const waiting = [...requests.values()].some((id) => family.includes(id)) ||
        family.some((id: string) => session.permission.list(id)?.length || session.form.list(id)?.length)
      const mark = waiting ? "?" : session.status(root) === "running" ? "…" : marks.get(root) ?? ""
      publish(mark, session.get(route.sessionID)?.title ?? "")
    }

    const ended = (id: string, mark: string) => {
      if (isRoot(id)) marks.set(id, mark)
      refresh()
    }
    const unsubscribe = [
      context.data.on("session.execution.started", (event: any) => {
        marks.delete(event.data.sessionID)
        refresh()
      }),
      context.data.on("session.execution.succeeded", (event: any) => ended(event.data.sessionID, "✓")),
      context.data.on("session.execution.interrupted", (event: any) => ended(event.data.sessionID, "✓")),
      context.data.on("session.execution.failed", (event: any) => ended(event.data.sessionID, "!")),
      context.data.on("permission.asked", (event: any) => {
        requests.set(event.data.id, event.data.sessionID)
        refresh()
      }),
      context.data.on("form.created", (event: any) => {
        requests.set(event.data.form.id, event.data.form.sessionID)
        refresh()
      }),
      ...["permission.replied", "form.replied", "form.cancelled"].map((type) =>
        context.data.on(type, (event: any) => {
          requests.delete(event.data.requestID ?? event.data.id)
          // The store may still contain the request until this event finishes.
          queueMicrotask(refresh)
        })),
    ]
    // Also follows title changes and navigation between sessions and the home screen.
    const timer = setInterval(refresh, 500)
    refresh()

    return async () => {
      disposed = true
      clearInterval(timer)
      unsubscribe.forEach((stop) => stop())
      await pending
      // The pane may already have been destroyed during shutdown.
      await exec("tmux", [
        "set-option", "-pu", "-t", pane, option,
        ";", "set-option", "-pu", "-t", pane, titleOption,
      ], { timeout: 2000 }).catch(() => {})
    }
  },
}
