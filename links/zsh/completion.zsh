# Add custom completions to the function path
fpath=($HOME/.zsh/completions $fpath)
# Turn on completion
autoload -U compinit
compinit

# Use fzf for tab completion
# NOTE: This MUST be sourced before autosuggestions (which is near the bottom of this file at time of writing)
if [[ -s "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh" ]]; then
    source "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh"

    zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    zstyle ':fzf-tab:*' popup-pad 80 0

    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    # preview directory's content with ls when completing cd
    zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls -1 --color=always ${(Q)realpath}'

    # magic previews for files and directories
    zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always ${(Q)realpath}'

    # show environment variable contents
    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
fi

# Case insensitive
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
