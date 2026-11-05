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

# Set REPLY to a shell-quoted command for an fzf action. Field
# placeholders are appended by the caller; fzf quotes their values itself.
picker_command() {
  printf -v REPLY '%q ' "$@"
}

# Inside tmux, re-run the picker in a centred floating pane sized like tmux's
# session switcher. fzf runs directly outside tmux.
picker_float() {
  if [[ -n "${TMUX:-}" && -z "${PICKER_FLOATING:-}" ]]; then
    local command
    printf -v command '%q ' "$(readlink -f -- "$0")" "$@"
    tmux new-pane -t "$PICKER_SOURCE_PANE" -x 75% -y 30% -X 0 -Y 0 -c "$PWD" \
      -e PICKER_FLOATING=1 -e "PICKER_SOURCE_PANE=$PICKER_SOURCE_PANE" \
      -e "PICKER_SOURCE_SESSION=$PICKER_SOURCE_SESSION" "$command" \; move-pane -P centre
    exit 0
  fi
}

# Choose a row the way tmux's session switcher does: typing filters, the
# selection uses tmux's mode-style when it is a hex colour, and the search
# line sits at the bottom.
picker_search() {
  local status=0 height='~20' mode_style part colors='hl:cyan:bold,hl+:cyan:bold,prompt:red'
  local -a parts=()
  [[ -z "${PICKER_FLOATING:-}" ]] || height=100%
  mode_style=$(tmux show -gv mode-style 2>/dev/null || true)
  IFS=, read -ra parts <<<"$mode_style"
  for part in "${parts[@]}"; do
    case "$part" in
      fg=\#??????) colors+=",fg+:${part#fg=}" ;;
      bg=\#??????) colors+=",bg+:${part#bg=}" ;;
    esac
  done
  fzf --height="$height" --layout=reverse-list --prompt='(search) ' --pointer='' --gutter=' ' \
    --no-preview --no-info --no-separator --no-header --no-border --no-scrollbar \
    --footer-border=none \
    --color="$colors" \
    --bind=ctrl-j:down,ctrl-k:up "$@" || status=$?
  case "$status" in
    0|1|130) return 0 ;;
    *) printf '%s: picker failed (exit %s)\n' "${0##*/}" "$status" >&2; return "$status" ;;
  esac
}
