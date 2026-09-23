# shellcheck shell=bash
# Session identity is distinct from its human-readable tmux name. Arrays are
# snapshots for picker annotations; reload before resolving a create operation.

sessions_load() {
  SESSION_IDS=()
  declare -gA SESSION_IDENTITY=() SESSION_NAME=() SESSION_PATH=()
  local id ids
  # A server without sessions is normal. Other failures should be visible.
  if ! ids=$(tmux list-sessions -F '#{session_id}' 2>&1); then
    case "$ids" in
      *'no server running'*|*'No such file or directory'*|*'no sessions'*) return 0 ;;
      *) printf '%s\n' "$ids" >&2; return 1 ;;
    esac
  fi
  while IFS= read -r id; do
    [[ -n "$id" ]] || continue
    SESSION_IDS+=("$id")
    SESSION_IDENTITY["$id"]=$(tmux display-message -p -t "$id" '#{@picker_identity}')
    SESSION_NAME["$id"]=$(tmux display-message -p -t "$id" '#{session_name}')
    SESSION_PATH["$id"]=$(tmux display-message -p -t "$id" '#{session_path}')
  done <<<"$ids"
}

session_name() {
  REPLY="${1//./_}"
  REPLY="${REPLY//:/_}"
}

# Resolve metadata first; adopt a legacy path-based session only when both its
# name and canonical directory match. An unrelated same-name session is never
# accepted merely because it already exists.
session_find() {
  local identity=$1 name=$2 path=$3 id existing_path
  REPLY=""
  for id in "${SESSION_IDS[@]}"; do
    if [[ "${SESSION_IDENTITY[$id]}" == "$identity" ]]; then
      REPLY=$id
      return 0
    fi
  done
  [[ "$identity" != ssh:* ]] || return 1
  for id in "${SESSION_IDS[@]}"; do
    [[ -z "${SESSION_IDENTITY[$id]}" && "${SESSION_NAME[$id]}" == "$name" ]] || continue
    existing_path=$(readlink -f -- "${SESSION_PATH[$id]}") || continue
    if [[ "$existing_path" == "$path" ]]; then
      REPLY=$id
      return 0
    fi
  done
  return 1
}

session_switch() {
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$1"
  else
    tmux attach-session -t "$1"
  fi
}
