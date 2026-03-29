#!/bin/bash

ARTIFACTS_DIR=${ARTIFACTS_DIR:-$(mktemp -d)}

main() {
  if command -v tv >/dev/null; then
    echo "tv is already installed"
    return
  fi

  install
}

install() {
  local version="0.15.4"
  local filename="tv-${version}-x86_64-unknown-linux-gnu.deb"
  local url="https://github.com/alexpasmantier/television/releases/download/${version}/${filename}"
  local filepath="$ARTIFACTS_DIR/$filename"

  curl -sLo "$filepath" "$url"
  sudo dpkg -i "$filepath"
}

main
