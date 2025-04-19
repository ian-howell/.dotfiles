#!/bin/bash

ARTIFACTS_DIR=${ARTIFACTS_DIR:-$(mktemp -d)}

main() {
  if command -v fd >/dev/null; then
    echo "fd is already installed"
    return
  fi

  install
}

install() {
  local version="10.2.0"
  local filename="fd-musl_${version}_amd64.deb"
  local url="https://github.com/sharkdp/fd/releases/download/v$version/$filename"
  local filepath="$ARTIFACTS_DIR/$filename"

  wget "$url" -O "$filepath"
  sudo dpkg -i "$filepath"
}

main
