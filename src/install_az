#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

main() {
  delete_az
  install_az
  az version
}

delete_az() {
  sudo apt-get remove -y azure-cli
}

install_az() {
  print_light_gray_banner "Installing Azure CLI"

  # Update package index and install Azure CLI
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  sudo apt-get update
  sudo apt-get install -y azure-cli
}

main
