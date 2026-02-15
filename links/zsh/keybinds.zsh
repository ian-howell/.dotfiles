# turn on vi-mode
bindkey -v

# allow v to edit the command line (standard behaviour)
zle -N edit-command-line
autoload -Uz edit-command-line
bindkey '^X^E' edit-command-line
bindkey -M vicmd '^X^E' edit-command-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history
bindkey -M vicmd '^P' up-history
bindkey -M vicmd '^N' down-history

# allow ctrl-h, ctrl-w, ctrl-? for char and word deletion (standard behaviour)
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
bindkey -M vicmd '^?' backward-delete-char
bindkey -M vicmd '^h' backward-delete-char
bindkey -M vicmd '^w' backward-kill-word

# allow ctrl-a and ctrl-e to move to beginning/end of line
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey -M vicmd '^a' beginning-of-line
bindkey -M vicmd '^e' end-of-line
# The following "fixes" the behavior of the home, end, and delete keys
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" delete-char
bindkey -M vicmd "^[[H" beginning-of-line
bindkey -M vicmd "^[[F" end-of-line
bindkey -M vicmd "^[[3~" delete-char

# same as above, but using the keycodes for tmux
bindkey "^[[1~" beginning-of-line
bindkey "^[[4~" end-of-line
bindkey -M vicmd "^[[1~" beginning-of-line
bindkey -M vicmd "^[[4~" end-of-line

# When hitting ctrl-w in insert mode, include the slash character (/) as a word separator
my-backward-delete-word() {
    local WORDCHARS=${WORDCHARS/\//}
    zle backward-delete-word
}
zle -N my-backward-delete-word
bindkey '^W' my-backward-delete-word

# FZF: pick files from git status
fzf-git-status-widget() {
    if ! command -v fzf >/dev/null; then
        return 0
    fi

    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        return 0
    fi

    local selections
    selections=$(paste <(git -c color.status=always status --short) \
        <(git status --short | sed -E 's/^.. //') | \
        fzf --ansi --multi --prompt='git status> ' --height=40% --layout=reverse \
            --delimiter=$'\t' --with-nth=1)

    [[ -z "$selections" ]] && return 0

    local -a files
    local line path
    while IFS= read -r line; do
        path=${line#*$'\t'}
        path=${path## }
        if [[ "$path" == *" -> "* ]]; then
            path=${path##* -> }
        fi
        [[ -z "$path" ]] && continue
        files+=("$path")
    done <<< "$selections"

    if (( ${#files} > 0 )); then
        local insert="${(q)files[@]}"
        if [[ -n "$LBUFFER" ]]; then
            LBUFFER+=" "
        fi
        LBUFFER+="$insert"
    fi
    zle redisplay
}
zle -N fzf-git-status-widget
bindkey -M viins -r '^G'
bindkey -M vicmd -r '^G'
bindkey -M viins '^G' fzf-git-status-widget
bindkey -M vicmd '^G' fzf-git-status-widget
