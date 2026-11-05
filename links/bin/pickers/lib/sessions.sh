# shellcheck shell=bash
# Session identity is distinct from its human-readable tmux name. Arrays are
# snapshots for picker annotations; reload before resolving a create operation.

sessions_load() {
  SESSION_IDS=()
  declare -gA SESSION_IDENTITY=() SESSION_NAME=() SESSION_PATH=() SESSION_LAST_ATTACHED=()
  local sessions id last_attached identity path name
  # A server without sessions is normal. Other failures should be visible.
  if ! sessions=$(tmux list-sessions -F $'#{session_id}\x1f#{session_last_attached}\x1f#{@picker_identity}\x1f#{session_path}\x1f#{session_name}' 2>&1); then
    case "$sessions" in
      *'no server running'*|*'No such file or directory'*|*'no sessions'*) return 0 ;;
      *) printf '%s\n' "$sessions" >&2; return 1 ;;
    esac
  fi
  # Unit separators keep empty fields; tabs would collapse them.
  while IFS=$'\x1f' read -r id last_attached identity path name; do
    [[ -n "$id" ]] || continue
    SESSION_IDS+=("$id")
    # shellcheck disable=SC2034 # read by the calling picker
    SESSION_LAST_ATTACHED["$id"]=${last_attached:-0}
    SESSION_IDENTITY["$id"]=$identity
    SESSION_PATH["$id"]=$path
    SESSION_NAME["$id"]=$name
  done <<<"$sessions"
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

# Recently picked keys for a picker, oldest first, as "epoch<TAB>key" lines.
picker_history_file() {
  REPLY=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/pickers/$1-history
}

# Fill the PICKED_AT associative array with each key's last pick time.
picker_history_load() {
  local time key
  declare -gA PICKED_AT=()
  picker_history_file "$1"
  [[ -r "$REPLY" ]] || return 0
  while IFS=$'\t' read -r time key; do
    # shellcheck disable=SC2034 # read by the calling picker
    PICKED_AT["$key"]=$time
  done <"$REPLY"
}

# Record a pick, keeping the latest 200 keys.
picker_history_record() {
  local key=$2 file
  picker_history_file "$1"
  file=$REPLY
  mkdir -p "${file%/*}"
  {
    [[ ! -r "$file" ]] || awk -F '\t' -v key="$key" '$2 != key' "$file" | tail -n 199
    printf '%s\t%s\n' "$(date +%s)" "$key"
  } >"$file.$$"
  mv "$file.$$" "$file"
}

# Print rows prefixed by a last-use time, newest first, without the prefix.
# Equal times keep their input order.
picker_by_recency() {
  sort -t $'\t' -k1,1nr -s | cut -f2-
}
