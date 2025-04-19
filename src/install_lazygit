#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

function main() {
  latest_version=$(get_latest_version)
  current_version=$(get_current_version)

  if [[ "$latest_version" == "$current_version" ]]; then
    return
  fi

  print_light_gray_banner "Installing lazygit $latest_version"
  install_lazygit
}

function get_latest_version() {
  # Taken from https://github.com/jesseduffield/lazygit?tab=readme-ov-file#ubuntu
  url="https://api.github.com/repos/jesseduffield/lazygit/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

function get_current_version() {
  if ! command -v lazygit >/dev/null; then
    return
  fi
  lazygit --version | tr ',' '\n' | tr -d ' ' | awk -F= '/^version/ { print $2 }'
}

function install_lazygit() {
  cd "$ARTIFACTS_DIR" || return

  local url
  url+="https://github.com/jesseduffield/lazygit/"
  url+="releases/download/v${latest_version}/"
  url+="lazygit_${latest_version}_Linux_x86_64.tar.gz"
  curl -sLo lazygit.tar.gz "$url"
  tar xf lazygit.tar.gz lazygit
  sudo install lazygit -D -t /usr/local/bin/
}

main
