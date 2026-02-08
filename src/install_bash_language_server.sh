#!/bin/bash

function main() {
  if is_installed; then
    return
  fi

  install_bash_language_server
}

function is_installed() {
  command -v bash-language-server >/dev/null
}

function install_bash_language_server() {
  sudo npm install -g bash-language-server
}

main
