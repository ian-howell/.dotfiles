#!/bin/bash

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

function main() {
  if is_installed; then
    return
  fi

  install_node
}

function is_installed() {
  command -v node >/dev/null
}

function install_node() {
  curl -fsSL https://deb.nodesource.com/setup_23.x -o "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo -E bash "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo apt-get install -y nodejs=23.7.0-1nodesource1
}

main
