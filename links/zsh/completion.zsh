# Add custom completions to the function path
fpath=($HOME/.zsh/completions $fpath)
# Turn on completion
autoload -U compinit
compinit

# Use fzf for tab completion
# NOTE: This MUST be sourced before autosuggestions (which is near the bottom of this file at time of writing)
if [[ -s "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh" ]]; then
    source "$HOME/.dotfiles/links/zsh/fzf/fzf-tab.plugin.zsh"

    # Shared presentation for the popup and the fallback outside tmux.
    _dotfiles_completion_fzf() {
        # Calculate inside fzf: the popup can be narrower than the tmux window.
        # Leave at least 20 text columns, plus the selector gutter and borders.
        local resize_preview='
            width=$(( FZF_COLUMNS * 80 / 100 ))
            minimum=${DOTFILES_COMPLETION_MIN_COLUMNS:-28}
            maximum=$(( FZF_COLUMNS - minimum ))
            (( width > maximum )) && width=$maximum
            (( width < 1 )) && width=1
            printf "change-preview-window(right,%s,border-left,noinfo,nowrap)+refresh-preview" "$width"
        '
        local -a display=(--height=80% --tmux=center,90%,80% --border=rounded)
        if [[ -n $DOTFILES_COMPLETION_POPUP ]]; then
            display=(--no-tmux --no-height --border=${DOTFILES_COMPLETION_BORDER:-none} --margin=0 --padding=0)
        fi
        fzf "$@" $display \
            --info=hidden --no-scrollbar --no-separator \
            --preview-window=right,80%,border-left,noinfo,nowrap \
            --bind="start:transform:$resize_preview" \
            --bind="resize:transform:$resize_preview"
    }
    # fzf-tab recognises this exact name and skips inline cursor movements.
    # Align the popup input with the shell cursor, growing above or below it.
    ftb-tmux-popup() {
        local -a geometry
        geometry=(${(s: :)$(tmux display-message -p -t "$TMUX_PANE" \
            "#{pane_left} #{pane_top} #{cursor_x} #{cursor_y} #{client_width} #{client_height} #{status-position} #{status}")})
        (( ${#geometry} == 8 )) || return 1
        integer x=$(( geometry[1] + geometry[3] ))
        integer y=$(( geometry[2] + geometry[4] ))
        integer screen_width=$geometry[5] screen_height=$geometry[6]
        # Pane coordinates exclude a top status line.
        if [[ $geometry[7] == top && $geometry[8] != off ]]; then
            if [[ $geometry[8] == on ]]; then
                (( ++y ))
            else
                (( y += geometry[8] ))
            fi
        fi

        local arg query='' layout=reverse
        for arg in "$@"; do
            [[ $arg == --query=* ]] && query=${arg#--query=}
        done
        integer query_width=${(m)#query}
        # fzf reserves two columns beside a vertical border, one row horizontally.
        integer border_x=2 border_y=1
        (( x - query_width < 2 || x >= screen_width - 2 )) && border_x=0
        (( y == 0 || y == screen_height - 1 )) && border_y=0
        local popup_border=rounded
        if (( ! border_x && ! border_y )); then
            popup_border=none
        elif (( ! border_x )); then
            popup_border=horizontal
        elif (( ! border_y )); then
            popup_border=vertical
        fi
        integer left=$(( x - query_width - border_x ))
        (( left < 0 )) && left=0
        # Near the right edge, shift the box left and pad its input to compensate.
        integer minimum_width=$(( screen_width < 40 ? screen_width : 40 ))
        (( left > screen_width - minimum_width )) && left=$(( screen_width - minimum_width ))
        integer prompt_width=$(( x - left - query_width - border_x ))
        (( prompt_width < 0 )) && prompt_width=0
        local popup_prompt=${(pl:$prompt_width:: :)""}
        integer width=$(( screen_width * 90 / 100 ))
        (( width > screen_width - left )) && width=$(( screen_width - left ))
        integer height=$(( screen_height * 80 / 100 )) top=$(( y - border_y ))
        if (( y > (screen_height - 1) / 2 )); then
            layout=default
            (( height > y + border_y + 1 )) && height=$(( y + border_y + 1 ))
            top=$(( y - height + border_y + 1 ))
        else
            (( height > screen_height - top )) && height=$(( screen_height - top ))
        fi

        local popup_dir result
        popup_dir=$(mktemp -d "${TMPDIR:-/tmp}/dotfiles-completion.XXXXXXXX") || return
        {
            # fzf-tab passes candidates on stdin and expects the selection on stdout.
            command cat > "$popup_dir/input"
            local -a options=("$@" --no-tmux --no-height --border=none
                --margin=0 --padding=0 --prompt="$popup_prompt" --layout=$layout)
            [[ $layout == default ]] && options+=(--bind=tab:up,btab:down)
            {
                print -r -- "_dotfiles_completion_fzf() { ${functions[_dotfiles_completion_fzf]} }"
                print -r -- "export SHELL=${(q)commands[zsh]}"
                print -r -- "export DOTFILES_COMPLETION_POPUP=1"
                print -r -- "export DOTFILES_COMPLETION_BORDER=$popup_border"
                # A long initial query also needs enough space to keep its cursor visible.
                integer input_width=$(( prompt_width + query_width ))
                print -r -- "export DOTFILES_COMPLETION_MIN_COLUMNS=$(( input_width > 20 ? input_width + 8 : 28 ))"
                print -r -- "_dotfiles_completion_fzf ${(j: :)${(@q)options}} < ${(q)popup_dir}/input > ${(q)popup_dir}/output"
            } > "$popup_dir/run.zsh"
            tmux display-popup -B -E -t "$TMUX_PANE" -x "$left" -y "$(( top + height ))" \
                -w "$width" -h "$height" -d "$PWD" \
                "${(q)commands[zsh]} -f ${(q)popup_dir}/run.zsh"
            result=$?
            [[ -f $popup_dir/output ]] && command cat "$popup_dir/output"
        } always {
            command rm -rf -- "$popup_dir"
        }
        return $result
    }
    if [[ -n $TMUX ]]; then
        zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
    else
        zstyle ':fzf-tab:*' fzf-command _dotfiles_completion_fzf
    fi

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
