#!/bin/bash
# Build tmux from a pinned upstream commit; switch-mode -O needs post-3.8 source.
set -euo pipefail

COMMIT="31c28422be0591189fb71670a78d283751294fcd"
STAMP="/usr/local/share/tmux/commit"

main() {
  if ! command -v tmux || [ "$(cat "$STAMP" 2>/dev/null)" != "$COMMIT" ]; then
    sudo apt-get remove -y tmux
    install
  fi
}

install() {
  install_dependencies

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  git -C "$tmpdir" init -q
  git -C "$tmpdir" fetch -q --depth 1 https://github.com/tmux/tmux "$COMMIT"
  git -C "$tmpdir" checkout -q FETCH_HEAD
  cd "$tmpdir"
  sh autogen.sh
  ./configure
  make
  sudo make install
  sudo mkdir -p "${STAMP%/*}"
  echo "$COMMIT" | sudo tee "$STAMP" >/dev/null
}

install_dependencies() {
  sudo apt-get install -y libevent-2.1-7 libevent-dev ncurses-base libncurses-dev bison autoconf automake pkg-config
}

main
