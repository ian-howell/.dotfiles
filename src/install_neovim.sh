#!/bin/bash

REPO_DIR="$HOME/.config/src/neovim"

function main() {
  install_dependencies
  clone_or_fetch_repo
  checkout_latest_stable
  build
}

function clone_or_fetch_repo() {
  if [ ! -d "$REPO_DIR/.git" ]; then
    git clone https://github.com/neovim/neovim "$REPO_DIR"
  else
    cd "$REPO_DIR" || exit 1
    git fetch origin --tags --force
  fi
}

function install_dependencies() {
  sudo apt-get install -y ninja-build gettext cmake unzip curl build-essential
}

function build() {
  cd "$REPO_DIR" || exit 1
  make CMAKE_BUILD_TYPE=RelWithDebInfo 
  sudo make install
}

function checkout_latest_stable() {
  cd "$REPO_DIR" || exit 1

  local before tag
  before="$(git rev-parse HEAD)"
  tag="$(git tag -l 'v[0-9]*.[0-9]*.[0-9]*' --sort=-v:refname | head -n 1)"

  if [ -z "$tag" ]; then
    echo "Could not find latest stable tag" >&2
    exit 1
  fi

  git checkout "$tag"

  if [ "$before" != "$(git rev-parse HEAD)" ]; then
    sudo make distclean
  fi
}

main
