# shellcheck shell=bash
# Shared presentation and invocation helpers. Sourced by the picker entry points.

picker_require() {
  local command
  for command in "$@"; do
    command -v "$command" >/dev/null || {
      printf '%s: missing required command: %s\n' "${0##*/}" "$command" >&2
      return 1
    }
  done
}

picker_init() {
  picker_require fzf
  export PICKER_SOURCE_PANE="${PICKER_SOURCE_PANE:-${TMUX_PANE:-}}"
  export PICKER_SOURCE_SESSION="${PICKER_SOURCE_SESSION:-}"
  if [[ -n "$PICKER_SOURCE_PANE" && -z "$PICKER_SOURCE_SESSION" ]]; then
    PICKER_SOURCE_SESSION=$(tmux display-message -p -t "$PICKER_SOURCE_PANE" '#{session_id}')
  fi
}

# Use the same bounded popup from a key binding or a shell. fzf can also run
# directly outside tmux. The first argument is the initial list of rows; size
# to that list, then let fzf scroll if a reload adds more entries.
picker_popup() {
  local rows=$1
  shift
  if [[ -n "${TMUX:-}" && -z "${PICKER_POPUP:-}" ]]; then
    local command width height count=0 row desired
    while IFS= read -r row; do
      [[ -z "$row" ]] || ((count += 1))
    done <<<"$rows"
    desired=$((count + 7))
    ((desired <= 20)) || desired=20
    printf -v command '%q ' "$(readlink -f -- "$0")" "$@"
    read -r width height < <(tmux display-message -p -t "$PICKER_SOURCE_PANE" '#{client_width} #{client_height}')
    [[ "$width" =~ ^[0-9]+$ && "$height" =~ ^[0-9]+$ ]] || {
      printf 'picker: no attached tmux client\n' >&2; return 1;
    }
    ((width <= 90)) || width=90
    ((height <= desired)) || height=$desired
    tmux display-popup -EE -b rounded -w "$width" -h "$height" -d "$PWD" \
      -e PICKER_POPUP=1 -e "PICKER_SOURCE_PANE=$PICKER_SOURCE_PANE" \
      -e "PICKER_SOURCE_SESSION=$PICKER_SOURCE_SESSION" "$command"
    exit "$?"
  fi
}

# Set REPLY to a shell-quoted command for an fzf action. Field
# placeholders are appended by the caller; fzf quotes their values itself.
picker_command() {
  printf -v REPLY '%q ' "$@"
}

picker_choose() {
  local status=0 query='' footer='' option
  local -a options=()
  for option in "$@"; do
    case "$option" in
      --footer=*) footer=${option#*=} ;;
      --query=*) query=${option#*=}; options+=("$option") ;;
      *) options+=("$option") ;;
    esac
  done
  local selector_hint='j/k: move · /: filter'
  local filter_hint='Esc: select mode'
  if [[ -n "$footer" ]]; then
    selector_hint+=$'\n'"$footer"
    filter_hint+=$'\n'"$footer"
  fi
  local start='hide-input'
  if [[ -n "$query" ]]; then
    start="show-input+unbind(j,k,/)+change-footer($filter_hint)"
  fi
  local height='~20'
  local PICKER_SELECTOR_ACTIONS="clear-query+hide-input+search()+rebind(j,k,/)+change-footer($selector_hint)"
  export PICKER_SELECTOR_ACTIONS
  [[ -z "${PICKER_POPUP:-}" ]] || height=100%
  # The Escape action is evaluated by fzf's shell with the current input state.
  # shellcheck disable=SC2016
  fzf --height="$height" --layout=reverse --padding=1,2 \
    --no-preview --no-info --no-separator --no-header --no-border \
    --no-scrollbar --footer-border=none --no-input --footer="$selector_hint" \
    --bind="j:down,k:up,/:show-input+unbind(j,k,/)+change-footer($filter_hint)" \
    --bind='esc:transform:if [ "$FZF_INPUT_STATE" = hidden ]; then printf abort; else printf "%s" "$PICKER_SELECTOR_ACTIONS"; fi' \
    --bind="start:$start" "${options[@]}" || status=$?
  case "$status" in
    0|1|130) return 0 ;;
    *) printf '%s: picker failed (exit %s)\n' "${0##*/}" "$status" >&2; return "$status" ;;
  esac
}
