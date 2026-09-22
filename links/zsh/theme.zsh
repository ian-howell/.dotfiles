# Files are read at invocation time, so shells don't retain a stale palette.
export BAT_CONFIG_PATH="$HOME/.local/state/dotfiles/theme/bat.conf"
export FZF_DEFAULT_OPTS_FILE="$HOME/.local/state/dotfiles/theme/fzf.conf"
export LG_CONFIG_FILE="$HOME/.dotfiles/links/lazygit.yml,$HOME/.local/state/dotfiles/theme/lazygit.yml"
export K9S_SKIN=dotfiles

_dotfiles_theme_refresh() {
  local selected=dark
  local state="$HOME/.local/state/dotfiles/theme/mode"
  [[ -r $state ]] && read -r selected < "$state"
  export DOTFILES_THEME=$selected
  # fzf-tab supplies explicit colors after the options file; override those too.
  if [[ $selected == light ]]; then
    zstyle ':fzf-tab:*' fzf-flags --color=light,hl:#9854f1,hl+:#9854f1
  else
    zstyle ':fzf-tab:*' fzf-flags --color=hl:188,hl+:255
  fi
}
autoload -Uz add-zsh-hook
add-zsh-hook precmd _dotfiles_theme_refresh
add-zsh-hook preexec _dotfiles_theme_refresh
_dotfiles_theme_refresh
