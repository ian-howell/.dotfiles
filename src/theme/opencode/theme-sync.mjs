import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"
import { fileURLToPath } from "node:url"

// TUI plugin, registered in the work tui.json (not a server plugin).
// Fixed-color themes avoid dependence on terminal color queries through tmux.
export default {
  id: "dotfiles-theme",
  async tui(api) {
    const state = process.env.DOTFILES_THEME_STATE || join(homedir(), ".local/state/dotfiles/theme")
    await api.theme.install(fileURLToPath(new URL("./dotfiles-dark.json", import.meta.url)))
    await api.theme.install(fileURLToPath(new URL("./dotfiles-light.json", import.meta.url)))
    let previous
    let busy = false
    let disposed = false
    let reported = false
    const refresh = async () => {
      if (busy || disposed || !api.theme.ready) return
      busy = true
      try {
        const mode = (await readFile(join(state, "mode"), "utf8")).trim()
        if ((mode === "light" || mode === "dark") && mode !== previous) {
          if (!api.theme.set(`dotfiles-${mode}`)) throw new Error(`Theme dotfiles-${mode} was not installed`)
          previous = mode
          reported = false
        }
      } catch (error) {
        if (error.code !== "ENOENT" && !reported) {
          reported = true
          api.ui.toast({ title: "Theme sync failed", message: String(error), variant: "error" })
        }
      } finally {
        busy = false
      }
    }
    const timer = setInterval(refresh, 500)
    api.lifecycle.onDispose(() => {
      disposed = true
      clearInterval(timer)
    })
    await refresh()
  },
}
