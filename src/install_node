#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

function main() {
  if is_installed; then
    return
  fi

  print_light_gray_banner "Installing Node.js"
  install_node
}

function is_installed() {
  command -v node >/dev/null
}

function install_node() {
  curl -fsSL https://deb.nodesource.com/setup_23.x -o "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo -E bash "$ARTIFACTS_DIR/nodesource_setup.sh"
  sudo apt-get install -y nodejs
}

main
