#!/bin/bash

BIN_DIR="$HOME/.local/bin"

main() {
  latest_version=$(get_latest_version)
  current_version=$(get_current_version)

  if [ -n "$current_version" ] && [ "$latest_version" = "$current_version" ]; then
    echo "glow is already at the latest version: $latest_version"
    return
  fi

  echo "Installing glow ${latest_version}..."
  install_glow "$latest_version"
  echo "glow ${latest_version} installed successfully."
}

get_latest_version() {
  local url="https://api.github.com/repos/charmbracelet/glow/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

get_current_version() {
  if ! command -v glow >/dev/null 2>&1; then
    return
  fi
  set -- $(glow --version)
  echo "$3"
}

install_glow() {
  local version="$1"
  local tmpdir
  local archive_dir

  mkdir -p "$BIN_DIR"
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  archive_dir="glow_${version}_Linux_x86_64"

  local url
  url="https://github.com/charmbracelet/glow/releases/download/v${version}/glow_${version}_Linux_x86_64.tar.gz"

  curl -fsLo "$tmpdir/glow.tar.gz" "$url"
  tar -xzf "$tmpdir/glow.tar.gz" -C "$tmpdir"

  if [ ! -f "$tmpdir/$archive_dir/glow" ]; then
    echo "glow binary not found after extracting $url"
    return 1
  fi

  mv "$tmpdir/$archive_dir/glow" "$BIN_DIR/"
}

main
