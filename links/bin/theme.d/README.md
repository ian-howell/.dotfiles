# Shared light/dark themes

Paths below are relative to the dotfiles repository root unless shown with `~/`.

```sh
theme dark
theme light
theme get     # prints dark or light; defaults to dark before first use
```

**Alt+T inside tmux** reads `theme get` and selects the opposite mode. Repeating
`theme dark` or `theme light` also reapplies that mode after editing a palette.
Errors are printed directly and return a nonzero exit code; other applications
still get a chance to refresh.

## Ownership

The controller (`links/bin/theme.d/`) saves the mode, selects checked-in palettes,
and requests application reloads. It never generates or copies Linux palettes.
Each app owns explicit light/dark files:

Apps needing a live reload provide a Python `refresh(mode, state)` adapter next
to their themes/config. The coordinator calls these adapters; Neovim and
OpenCode instead use their in-process watchers. The Windows Terminal adapter
and JSONC editor live with its integration under `src/theme/windows-terminal/`.

| App | Palette / integration |
| --- | --- |
| tmux | `links/tmux/themes/{dark,light}.conf`; common layout in `style.conf` |
| Kitty | `links/kitty/themes/{dark,light}.conf` |
| Delta | `links/delta/tokyonight_{moon,day}.gitconfig` |
| bat | `links/bat/{dark,light}.conf` and `themes/` |
| fzf | Tokyo Night Moon/Day in `links/zsh/fzf-themes/{dark,light}.conf` |
| Lazygit | `links/lazygit/themes/{dark,light}.yml` |
| K9s | `links/k9s/skins/tokyonight-{moon,day}.yaml` |
| Neovim | Tokyo Night's Moon/Day themes; `links/nvim/lua/core/theme.lua` |
| Oh My Posh | Dark/Day palettes in `links/ohmyposh/tokyonight.omp.yaml` |
| OpenCode | Shared TUI plugin and palettes in `links/opencode/tui-plugins/` |
| Windows Terminal | Day scheme in `src/theme/windows-terminal/light.json`; preserves live dark schemes |

The saved choice and selector symlinks live in `~/.local/state/dotfiles/theme/`,
outside Git. These are optional: a freshly linked machine uses static dark defaults.
Switching replaces selectors atomically; concurrent setters are serialized. Neovim and
OpenCode watch the saved mode; shells read it before commands/prompts. Apps with
their own hooks read the file directly to avoid repeatedly spawning the CLI.
Glow's `md` wrapper uses `theme get` to select its built-in light or Tokyo Night style.

fzf palettes are single-line, color-only options files, including explicit backgrounds.
Shell and tmux pickers point `FZF_DEFAULT_OPTS_FILE` directly at the checked-in
light/dark palette, so absent runtime files cannot break fzf.
`links/zsh/theme.zsh` also reapplies it after fzf-tab's own highlight flags;
`links/zsh/fzf-git.zsh` lets Git picker labels inherit the palette while keeping
the plugin's header text attributes. Open a new shell to load changes to these
integrations, or source both files in an existing Zsh session.

The command refreshes the invoking tmux server (the default when outside tmux).
Hook-enabled editors under this user follow the shared state. Other machines and
WSL distributions are independent.

## Linking and first use

Normal dotfile linking is sufficient; there is no theme installer. Shells, tmux,
Git, Kitty, and K9s use checked-in dark defaults before any switch. The normal
`src/link_dotfiles.sh` already rebuilds bat's cache for its checked-in themes.
`theme light` / `theme dark` save the choice and change selector symlinks for
applications whose configuration needs a stable include path. Existing generated
palette copies at those selector paths are replaced with symlinks on the next switch.
Shells select static bat/fzf/Lazygit paths on each prompt/command; tmux refreshes
its environment on each switch. K9s uses its static Moon skin initially; the
first switch creates its managed skin link and subsequent switches notify its watcher.

On WSL, switching discovers Windows Terminal's `settings.json` under `/mnt/c/Users`
(packaged or unpackaged installations). Set `DOTFILES_WT_SETTINGS` to its WSL path
if discovery is ambiguous or the file lives elsewhere. This variable can also
explicitly enable the integration outside WSL. Plain Linux skips it.
No saved installation path is required. The first switch adds the checked-in
Day scheme and light/dark mappings to WSL profiles, retaining each existing dark
scheme, and saves `windows-terminal.before.json` in the state directory.
Switches preserve JSONC comments and unrelated settings. Terminal's top-level
`theme` changes its chrome across windows, not Windows' system-wide preference.
Missing/ambiguous settings on WSL are reported while other apps still refresh.

The OpenCode TUI plugin
and its palettes live in `links/opencode/tui-plugins/`, exposed by the existing
`~/.config/opencode` symlink and registered in the base `tui.jsonc`. They load with
or without a work overlay.
OpenCode also installs runtime theme copies under `~/.config/opencode/themes/`,
ignored by Git. Restart OpenCode after changing the plugin or palettes.

The controller needs Python 3's standard library. The OpenCode plugin
was verified with 1.18.32. `DOTFILES_THEME_STATE` overrides the controller/editor
state location for tests; deployed shell/Git/Kitty/tmux configs use the normal path.

## Refresh behavior

- **tmux / Windows Terminal:** update immediately.
- **Neovim / OpenCode:** update within about half a second once their hooks load.
  Restart existing OpenCode sessions after installation. Existing Neovim sessions
  can run `:lua require("core.theme").setup()` instead of restarting.
- **Zsh / prompt:** update at the next command/prompt. After updating the dotfiles,
  open a new shell or source `~/.dotfiles/links/zsh/theme.zsh` and
  `~/.dotfiles/links/zsh/prompt.zsh` once.
- **bat / delta / fzf / Glow:** follow the mode on subsequent invocations.
- **Lazygit:** relaunch after each mode change; 0.62.2 does not live-reload this
  palette overlay. The base config is combined with the selected palette through
  `LG_CONFIG_FILE`.
- **K9s:** relaunch once after the first switch; reactive mode follows the managed
  skin. Its original config, aliases and context paths remain in use. `K9S_SKIN`
  overrides per-context skin choices. The controller replaces the skin symlink
  to notify K9s's directory watcher.
- **Kitty:** receives its config reload signal if installed/running. Not exercised
  on this WSL machine.

Previously printed output and already-open short-lived viewers are not redrawn.

## Removal

Select dark first. Remove the tmux binding with `tmux unbind-key -n M-t` and revert
the repo integration edits. Remove the `theme-sync.mjs` entry from the base TUI
config and its installed plugin/palettes, then restart OpenCode. Remove the K9s
`skins/dotfiles.yaml` link and unset `K9S_SKIN`.

For Windows Terminal, restore the backup to the settings file used by discovery
or `DOTFILES_WT_SETTINGS`.
If unrelated Terminal settings have changed since installation, remove the Day
scheme/mappings and restore the original top-level theme manually instead of
restoring the entire backup. Remove runtime state only after removing its hooks.

## Checks

```sh
python3 links/bin/theme.d/test_theme.py -v
shellcheck links/bin/theme.d/theme links/bin/md src/link_dotfiles.sh
zsh -n links/zsh/theme.zsh
zsh -n links/zsh/fzf-git.zsh
```

Regression tests cover fresh-home Zsh/fzf and isolated tmux pickers, JSONC
preservation, Windows first-switch discovery/idempotence, static palette selector
round-trips, partial refresh failures, and the three-command interface. Live
checks cover tmux, Neovim, OpenCode, Terminal settings, shell/prompt colors, and
Lazygit after relaunch. K9s watcher behavior is source-checked; no cluster connection
was opened for testing.

API source references used (successful catalog fetches): OpenCode
`fe3f3a41f79ad292cc3c7c629567385a20ec5130`, K9s
`f26550f2e3bc1a8789ce7d98a882d75afa7e10da`, Oh My Posh
`def198e06052dbb5414cdcaf09febb10a710111f`. Palette colors follow Tokyo Night Day
and the existing Moon palettes; OpenCode's dark palette matches its built-in
Tokyo Night theme. Assets derive from the respective MIT-licensed projects.
