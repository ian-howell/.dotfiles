#!/bin/bash

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

function main() {
  local latest_version
  local current_version

  latest_version=$(get_latest_version)
  current_version=$(get_current_version)

  if [[ -n "$current_version" && "$latest_version" == "$current_version" ]]; then
    return
  fi

  install_stylua "$latest_version"
}

function get_latest_version() {
  local url
  url="https://api.github.com/repos/JohnnyMorganz/StyLua/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

function get_current_version() {
  if ! command -v stylua >/dev/null; then
    return
  fi

  stylua --version | awk '{ print $2 }'
}

function install_stylua() {
  local version
  local url
  version="$1"
  url="https://github.com/JohnnyMorganz/StyLua/releases/download/v${version}/stylua-linux-x86_64.zip"

  cd "$ARTIFACTS_DIR" || return
  curl -sLo stylua.zip "$url"
  unzip -o stylua.zip stylua
  sudo install stylua -D -t /usr/local/bin/
}

main
