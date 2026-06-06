#!/bin/bash

set -euo pipefail

main() {
  install_go_tool golang.org/x/tools/gopls@latest
  install_go_tool golang.org/x/tools/cmd/goimports@latest
}

install_go_tool() {
  local package="$1"
  /usr/local/go/bin/go install "$package"
}

main
