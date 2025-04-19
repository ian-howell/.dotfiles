#!/bin/bash

# This script installs the latest version of Go.
# If an argument was provided, it should be in the form of a version number
# (e.g., 1.24.0), and the script will install that specific version.

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

main() {
  delete_go
  install_go "$1"
  go version
}

delete_go() {
  sudo rm -rf /usr/local/go
}

install_go() {
  local version="$1"
  print_light_gray_banner "Installing go $version"

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT

  local filename
  if [ -n "$version" ]; then
    filename="go$version.linux-amd64.tar.gz"
  else
    filename=$(
      curl -sL 'https://golang.org/dl/?mode=json' |
        jq '.[0].files[] | select(.arch == "amd64") | select(.os == "linux") | .filename' -r
    )
  fi

  tarball="$tmpdir/$filename"
  release_url="https://go.dev/dl/$filename"
  # Download and install
  curl -sL "$release_url" --output "$tarball"
  sudo tar -C /usr/local -xzf "$tarball"
}

main "$1"
