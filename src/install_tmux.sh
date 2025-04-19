#!/bin/bash

VERSION="3.5a"

main() {
  if ! command -v tmux || [ "$(tmux -V | cut -d ' ' -f 2)" != "$VERSION" ]; then
    sudo apt-get remove -y tmux
    install
  fi
}

install() {
  install_dependencies

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  curl -sL "https://github.com/tmux/tmux/releases/download/$VERSION/tmux-$VERSION.tar.gz" -o "$tmpdir/tmux.tar.gz"
  tar -zxf "$tmpdir/tmux.tar.gz" -C "$tmpdir"
  cd "$tmpdir/tmux-$VERSION/" || exit 1
  ./configure
  make && sudo make install
}

install_dependencies() {
  sudo apt-get install -y libevent-2.1-7 libevent-dev ncurses-base libncurses-dev bison
}

main
