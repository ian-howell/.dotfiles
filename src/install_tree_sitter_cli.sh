#!/bin/bash

function main() {
  if is_installed; then
    return
  fi

  install_tree_sitter_cli
}

function is_installed() {
  command -v tree-sitter >/dev/null
}

function install_tree_sitter_cli() {
  sudo npm install -g tree-sitter-cli
}

main
