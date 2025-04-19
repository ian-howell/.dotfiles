#!/bin/bash

main() {
  update_git_submodules
}

update_git_submodules() {
  ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null
  git submodule update --init --recursive
}

main
