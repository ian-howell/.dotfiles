#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

main() {
  print_light_gray_banner "Installing zsh"
  install_zsh
}

install_zsh() {
  # If the user's shell is already zsh, do nothing.
  if grep -q "^$USER:.*zsh" /etc/passwd; then
    echo "zsh already installed :)"
    return
  fi

  sudo apt-get -qq -y install zsh

  # This sed trick prevents `chsh` from asking for a password.
  sudo sed -i.original -e 's/auth\(.*\)pam_shells.so$/# auth\1pam_shells.so/' /etc/pam.d/chsh
  cleanup() {
    sudo mv /etc/pam.d/chsh.original /etc/pam.d/chsh
  }
  trap cleanup EXIT

  sudo chsh -s "$(command -v zsh)" "$USER"

  echo "Finished installing zsh :)"
  echo "You may need to log out and back in for the changes to take effect..."
}

main
