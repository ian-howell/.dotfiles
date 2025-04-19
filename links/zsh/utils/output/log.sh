#!/bin/bash

# Logs a message with a timestamp and a vertical separator.
# The timestamp is displayed in magenta for better visibility.
# Supports "fancy" animated logging for added flair.
#
# Usage:
#   log "Your message here"
#
# Example:
#   log "🔐 Logging into Azure..."
#   Output: 2023-10-05 14:23:45 │ 🔐 Logging into Azure...
log() {
  local message="$*"
  local timestamp="\e[35m$(date '+%Y-%m-%d %H:%M:%S')\e[0m │ "

  printf "%b" "$timestamp"
  for ((i = 0; i < ${#message}; i++)); do
    printf "%s" "${message:i:1}"
    sleep 0.05
  done
  printf "\n"
}
