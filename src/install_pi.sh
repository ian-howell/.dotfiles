#!/bin/bash

function main() {
  if is_installed; then
    return
  fi

  install_pi
}

function is_installed() {
  command -v pi >/dev/null
}

function install_pi() {
  # --ignore-scripts per Pi's recommended install; node/npm come from install_node.sh
  npm install -g --ignore-scripts @earendil-works/pi-coding-agent
}

main
