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

    # Preview directories one level deep, or show regular-file contents.
    zstyle ':fzf-tab:complete:*:*' fzf-preview '
        if [[ -d "$realpath" ]]; then
            eza --tree --level=1 --long --icons=always --color=always \
                --group-directories-first --all --ignore-glob=.git \
                --no-permissions --no-user --no-time -- "$realpath/"
        elif [[ -f "$realpath" ]]; then
            bat --color=always --paging=never -- "$realpath"
        fi
    '

    # show environment variable contents
    zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'
fi

# Case insensitive
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Completion's trailing space is an auto-removable suffix; by default `&` and `|`
# eat it. Keep removal for space/tab/newline/`;`, but not for pipes/backgrounding.
ZLE_REMOVE_SUFFIX_CHARS=$' \t\n;'
