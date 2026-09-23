source "$HOME/.dotfiles/links/zsh/fzf-git.sh/fzf-git.sh"

# Use fzf-git's customization hook so labels inherit the shared RGB palette.
_fzf_git_fzf() {
  fzf-tmux -p80%,60% -- \
    --layout=reverse --multi --height=50% --min-height=20 --border \
    --border-label-pos=2 \
    --color='header:italic:underline' \
    --preview-window='right,50%,border-left' \
    --bind='ctrl-/:change-preview-window(down,50%,border-top|hidden|)' "$@"
}
