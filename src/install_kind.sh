#!/bin/bash

main() {
  if missing_dependencies; then
    echo "Missing dependencies. Please install them and try again."
    exit 1
  fi

  install_kind
}

install_kind() {
  go install sigs.k8s.io/kind@v0.27.0
}

missing_dependencies() {
  local missing=false
  for cmd in go docker; do
    if ! command -v "$cmd" &>/dev/null; then
      echo "Command '$cmd' not found. Please install it."
      missing=true
    fi
  done
  $missing && return 0 || return 1
}

main
