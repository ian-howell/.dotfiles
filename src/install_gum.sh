#!/bin/bash

BIN_DIR="$HOME/.local/bin"

main() {
  latest_version=$(get_latest_version)
  current_version=$(get_current_version)

  if [ -n "$current_version" ] && [ "$latest_version" = "$current_version" ]; then
    echo "gum is already at the latest version: $latest_version"
    return
  fi

  echo "Installing gum ${latest_version}..."
  install_gum "$latest_version"
  echo "gum ${latest_version} installed successfully."
}

get_latest_version() {
  local url="https://api.github.com/repos/charmbracelet/gum/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

get_current_version() {
  if ! command -v gum >/dev/null 2>&1; then
    return
  fi
  set -- $(gum --version)
  echo "$3"
}

install_gum() {
  local version="$1"
  local tmpdir
  local archive_dir

  mkdir -p "$BIN_DIR"
  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  archive_dir="gum_${version}_Linux_x86_64"

  local url
  url="https://github.com/charmbracelet/gum/releases/download/v${version}/gum_${version}_Linux_x86_64.tar.gz"

  curl -fsLo "$tmpdir/gum.tar.gz" "$url"
  tar -xzf "$tmpdir/gum.tar.gz" -C "$tmpdir"

  if [ ! -f "$tmpdir/$archive_dir/gum" ]; then
    echo "gum binary not found after extracting $url"
    return 1
  fi

  mv "$tmpdir/$archive_dir/gum" "$BIN_DIR/"
}

main
