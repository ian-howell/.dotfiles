#!/bin/bash

set -euo pipefail

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"
REQUIRED_MAJOR="${REQUIRED_MAJOR:-22}"
NODE_MAJOR="${NODE_MAJOR:-23}"

function main() {
  if is_installed; then
    return
  fi

  install_node
}

function is_installed() {
  command -v node >/dev/null || return 1

  local current_major
  current_major="$(node --version | sed 's/^v\([0-9]*\).*/\1/')"

  [ "$current_major" -ge "$REQUIRED_MAJOR" ]
}

function install_node() {
  curl -fsSL "https://deb.nodesource.com/setup_${NODE_MAJOR}.x" -o "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo -E bash "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo apt-get install -y nodejs
}

main
