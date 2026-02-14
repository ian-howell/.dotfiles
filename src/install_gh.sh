#!/bin/bash

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

function main() {
  latest_version=$(get_latest_version)
  if [[ -z "$latest_version" ]]; then
    echo "Failed to resolve latest gh version" >&2
    return 1
  fi

  current_version=$(get_current_version)

  if [[ "$latest_version" == "$current_version" ]]; then
    return
  fi

  install_gh
}

function get_latest_version() {
  url="https://api.github.com/repos/cli/cli/releases/latest"
  curl -fsSL "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

function get_current_version() {
  if ! command -v gh >/dev/null; then
    return
  fi
  gh --version | head -1 | awk '{print $3}'
}

function install_gh() {
  cd "$ARTIFACTS_DIR" || return

  local url
  url+="https://github.com/cli/cli/"
  url+="releases/download/v${latest_version}/"
  url+="gh_${latest_version}_linux_amd64.tar.gz"
  curl -fsSLo gh.tar.gz "$url"
  tar -xzf gh.tar.gz
  sudo install gh_${latest_version}_linux_amd64/bin/gh -D -t /usr/local/bin/
}

main
