#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

print_light_gray_banner "Installing fzf"

git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install --key-bindings --completion --no-update-rc
