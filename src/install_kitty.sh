#!/bin/bash

function main() {
  install
}

function install() {
  curl -L https://sw.kovidgoyal.net/kitty/installer.sh | sh /dev/stdin \
    launch=n \
    installer=nightly

  install_desktop_integration
}

function create_symlinks() {
  ln -sf ~/.local/kitty.app/bin/kitty ~/.local/kitty.app/bin/kitten ~/bin/
}

function install_desktop_integration() {
  cp ~/.local/kitty.app/share/applications/kitty.desktop ~/.local/share/applications/

  # This lets you open text files and images in kitty via your file manager
  cp ~/.local/kitty.app/share/applications/kitty-open.desktop ~/.local/share/applications/

  # Update the paths to the kitty and its icon in the kitty desktop file(s)
  sed -i "s|Icon=kitty|Icon=$(readlink -f ~)/.local/kitty.app/share/icons/hicolor/256x256/apps/kitty.png|g" \
    ~/.local/share/applications/kitty*.desktop
  sed -i "s|Exec=kitty|Exec=$(readlink -f ~)/.local/kitty.app/bin/kitty|g" \
    ~/.local/share/applications/kitty*.desktop

  # Make xdg-terminal-exec (and hence desktop environments that support it use kitty)
  echo 'kitty.desktop' > ~/.config/xdg-terminals.list
}

main
