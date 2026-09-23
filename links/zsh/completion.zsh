# Add custom completions to the function path
fpath=($HOME/.zsh/completions $fpath)
# Turn on completion
autoload -U compinit
compinit

# Use fzf for tab completion
# NOTE: This MUST be sourced before autosuggestions (which is near the bottom of this file at time of writing)
if [[ -s "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh" ]]; then
    source "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh"

    # Use fzf's native popup sizing; --height is the fallback outside tmux.
    _dotfiles_completion_fzf() {
        fzf "$@" --tmux=center,90%,50% --height=50% --border=rounded \
            --info=hidden --no-scrollbar --no-separator \
            --preview-window=right,50%,border-left,noinfo,nowrap
    }
    zstyle ':fzf-tab:*' fzf-command _dotfiles_completion_fzf

    # set list-colors to enable filename colorizing
    zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

    # Preview immediate directory contents, or show regular-file contents.
    zstyle ':fzf-tab:complete:*:*' fzf-preview '
        if [[ -d "$realpath" ]]; then
            {
                printf "\033[2m%s\033[0m\n\n" "$realpath"
                eza --oneline --icons=always --color=always --classify=always \
                    --group-directories-first --all --ignore-glob=.git -- "$realpath/"
            } | {
                # Hold the last visible row until we know whether more follows.
                integer height=${FZF_PREVIEW_LINES:-0} row=0
                local line last
                while IFS= read -r line; do
                    (( ++row ))
                    if (( height <= 0 || row < height )); then
                        print -r -- "$line"
                    elif (( row == height )); then
                        last=$line
                    elif (( row == height + 1 )); then
                        printf "\033[2m…\033[0m\n"
                    fi
                done
                if (( height > 0 && row == height )); then
                    print -r -- "$last"
                fi
            }
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
