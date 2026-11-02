import { readFile } from "node:fs/promises"
import { homedir } from "node:os"
import { join } from "node:path"

// Follows the dotfiles light/dark mode. The "dotfiles" theme holds both palettes, and the
// renderer's theme_mode event switches between them without locking the mode or rewriting
// cli.json, which the built-in theme commands do. Fixed-color palettes avoid depending on
// terminal color queries through tmux.
// A plain object, because OpenCode does not resolve @opencode/plugin for local plugin files.
export default {
  id: "dotfiles-theme",
  setup(context: any) {
    const state = process.env.DOTFILES_THEME_STATE || join(homedir(), ".local/state/dotfiles/theme")
    let previous: string | undefined
    let busy = false
    let disposed = false
    let reported = false

    const refresh = async () => {
      if (busy || disposed) return
      busy = true
      try {
        const mode = (await readFile(join(state, "mode"), "utf8")).trim()
        if ((mode === "light" || mode === "dark") && mode !== previous) {
          context.renderer.emit("theme_mode", mode)
          previous = mode
          reported = false
        }
      } catch (error: any) {
        if (error?.code !== "ENOENT" && !reported) {
          reported = true
          context.ui.toast.show({ title: "Theme sync failed", message: String(error), variant: "error" })
        }
      } finally {
        busy = false
      }
    }

    const timer = setInterval(refresh, 500)
    void refresh()
    return () => {
      disposed = true
      clearInterval(timer)
    }
  },
}
