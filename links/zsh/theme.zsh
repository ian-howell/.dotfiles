_dotfiles_theme_refresh() {
  local selected=dark
  local state="$HOME/.local/state/dotfiles/theme/mode"
  [[ -r $state ]] && read -r selected < "$state"
  [[ $selected == light || $selected == dark ]] || selected=dark
  export DOTFILES_THEME=$selected
  # Static palettes work immediately after linking, without runtime state.
  local links="$HOME/.dotfiles/links"
  export BAT_CONFIG_PATH="$links/bat/$selected.conf"
  export FZF_DEFAULT_OPTS_FILE="$links/zsh/fzf-themes/$selected.conf"
  export LG_CONFIG_FILE="$links/lazygit.yml,$links/lazygit/themes/$selected.yml"
  export K9S_SKIN=tokyonight-moon
  [[ $selected == light ]] && export K9S_SKIN=tokyonight-day
  [[ -r ${XDG_CONFIG_HOME:-$HOME/.config}/k9s/skins/dotfiles.yaml ]] && export K9S_SKIN=dotfiles
  # fzf-tab supplies explicit colors after the options file. Reapply our
  # single-line, color-only palette after those flags as well.
  local palette
  if [[ -r $FZF_DEFAULT_OPTS_FILE ]]; then
    read -r palette < "$FZF_DEFAULT_OPTS_FILE"
    zstyle ':fzf-tab:*' fzf-flags "$palette"
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_theme_refresh
add-zsh-hook preexec _dotfiles_theme_refresh
_dotfiles_theme_refresh
