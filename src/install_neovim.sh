#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

REPO_DIR="$HOME/.config/src/neovim"

function main() {
  if [ ! -d "$REPO_DIR" ]; then
    install
  else
    upgrade
  fi
}

function install() {
  print_light_gray_banner "Installing Neovim"
  mkdir -p "$REPO_DIR"
  install_dependencies
  clone_repo
  build
}

function upgrade() {
  print_light_gray_banner "Upgrading Neovim"
  if pull_latest_code; then
    build
  else
    echo "Up to date"
  fi
}

function clone_repo() {
  git clone https://github.com/neovim/neovim "$REPO_DIR"
}

function install_dependencies() {
  sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
}

function build() {
  cd "$REPO_DIR" || exit 1
  make CMAKE_BUILD_TYPE=RelWithDebInfo 
  sudo make install
}

# Pull the latest code from the repo
function pull_latest_code() {
  cd "$REPO_DIR" || exit 1
  git fetch --tags --force
  git checkout nightly
}

main
