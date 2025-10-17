#!/bin/bash

main() {
  delete_az
  install_az
  az version
}

delete_az() {
  sudo apt-get remove -qq -y azure-cli 2> /dev/null
}

install_az() {
  # Update package index and install Azure CLI
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor | sudo tee /etc/apt/trusted.gpg.d/microsoft.gpg > /dev/null
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/azure-cli.list
  sudo apt-get update
  sudo apt-get install -y azure-cli
}

main
