import { execFile } from "node:child_process"
import { promisify } from "node:util"

const exec = promisify(execFile)
const option = "@opencode-status"
const titleOption = "@opencode-title"

// Runs in the TUI so each client updates its own pane, including attached clients.
export default {
  id: "tmux-turn-status",
  async tui(api) {
    const pane = process.env.TMUX_PANE
    if (!process.env.TMUX || !/^%\d+$/.test(pane || "")) return

    const sessions = new Map()
    const requests = new Map()
    let previous
    let disposed = false
    let reported = false
    let pending = Promise.resolve()

    function root(id) {
      const seen = new Set()
      while (id && !seen.has(id)) {
        seen.add(id)
        const parent = api.state.session.get(id)?.parentID
        if (!parent) return id
        id = parent
      }
      return id
    }

    function status(id, type) {
      const last = sessions.get(id)
      const active = type === "busy" || type === "retry"
      sessions.set(id, {
        active,
        mark: active ? "…" : last?.active ? (last.mark === "!" ? "!" : "✓") : last?.mark || "",
      })
    }

    function publish(mark, title) {
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
            api.ui.toast({ title: "Tmux status/title update failed", message: String(error), variant: "error" })
          }
        }
      })
    }

    function refresh() {
      if (disposed || !api.state.ready) return
      const route = api.route.current
      const sessionID = route.name === "session" ? route.params?.sessionID : undefined
      const id = root(sessionID)
      if (!id) return publish("", "")
      // The title follows the displayed session; status rolls up to its root.
      const title = api.state.session.get(sessionID)?.title || ""
      if (!sessions.has(id)) status(id, api.state.session.status(id)?.type || "idle")
      const waiting = api.state.session.permission(id).length || api.state.session.question(id).length ||
        [...requests.values()].some((sessionID) => root(sessionID) === id)
      publish(waiting ? "?" : sessions.get(id).mark, title)
    }

    const unsubscribe = [
      api.event.on("session.status", ({ properties }) => {
        status(properties.sessionID, properties.status.type)
        refresh()
      }),
      api.event.on("session.error", ({ properties }) => {
        if (!properties.sessionID) return
        const last = sessions.get(properties.sessionID)
        sessions.set(properties.sessionID, { active: last?.active || false, mark: "!" })
        refresh()
      }),
      ...["permission.asked", "question.asked"].map((type) => api.event.on(type, ({ properties }) => {
        requests.set(properties.id, properties.sessionID)
        refresh()
      })),
      ...["permission.replied", "question.replied", "question.rejected"].map((type) => api.event.on(type, ({ properties }) => {
        requests.delete(properties.requestID)
        // The state store may still contain the request until this event finishes.
        queueMicrotask(refresh)
      })),
    ]
    // Also follows title changes and navigation between sessions and the home screen.
    const timer = setInterval(refresh, 500)
    api.lifecycle.onDispose(async () => {
      disposed = true
      clearInterval(timer)
      unsubscribe.forEach((stop) => stop())
      await pending
      // The pane may already have been destroyed during shutdown.
      await exec("tmux", [
        "set-option", "-pu", "-t", pane, option,
        ";", "set-option", "-pu", "-t", pane, titleOption,
      ], { timeout: 2000 }).catch(() => {})
    })
    refresh()
  },
}
