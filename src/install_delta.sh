#!/bin/bash

ARTIFACTS_DIR=${ARTIFACTS_DIR:-$(mktemp -d)}

BIN_DIR="$HOME/.local/bin"

main() {
  if [ ! -f "$BIN_DIR/delta" ]; then
    install_delta
  fi
}

install_delta() {
  mkdir -p "$BIN_DIR"
  download_delta
}

download_delta() {
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  wget -O "$tmpdir/delta.tar.gz" https://github.com/dandavison/delta/releases/download/0.18.1/delta-0.18.1-x86_64-unknown-linux-gnu.tar.gz
  tar -xzf "$tmpdir/delta.tar.gz" -C "$tmpdir"
  mv "$tmpdir/delta-0.18.1-x86_64-unknown-linux-gnu/delta" "$BIN_DIR"
}

main
