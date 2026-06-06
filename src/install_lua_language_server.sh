#!/bin/bash

set -euo pipefail

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"
INSTALL_DIR="/opt/lua-language-server"
BIN_PATH="/usr/local/bin/lua-language-server"

main() {
  if is_installed; then
    return
  fi

  install_lua_language_server "$(get_latest_version)"
}

is_installed() {
  command -v lua-language-server >/dev/null
}

get_latest_version() {
  local url
  url="https://api.github.com/repos/LuaLS/lua-language-server/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"\K[^"]*'
}

get_asset_name() {
  case "$(uname -m)" in
    x86_64 | amd64)
      printf "lua-language-server-%s-linux-x64.tar.gz" "$1"
      ;;
    aarch64 | arm64)
      printf "lua-language-server-%s-linux-arm64.tar.gz" "$1"
      ;;
    *)
      printf "Unsupported architecture: %s\n" "$(uname -m)" >&2
      return 1
      ;;
  esac
}

install_lua_language_server() {
  local version
  local asset_name
  local url
  version="$1"
  asset_name="$(get_asset_name "$version")"
  url="https://github.com/LuaLS/lua-language-server/releases/download/${version}/${asset_name}"

  mkdir -p "$ARTIFACTS_DIR/lua-language-server"
  curl -sLo "$ARTIFACTS_DIR/$asset_name" "$url"
  tar -xzf "$ARTIFACTS_DIR/$asset_name" -C "$ARTIFACTS_DIR/lua-language-server"

  sudo rm -rf "$INSTALL_DIR"
  sudo mkdir -p "$INSTALL_DIR"
  sudo cp -a "$ARTIFACTS_DIR/lua-language-server/." "$INSTALL_DIR/"
  sudo ln -sf "$INSTALL_DIR/bin/lua-language-server" "$BIN_PATH"
}

main
