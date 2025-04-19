#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

print_light_gray_banner "Remapping caps lock to ctrl"

sudo sed -i '/XKBOPTIONS/c\\XKBOPTIONS="ctrl:nocaps"' /etc/default/keyboard
sudo dpkg-reconfigure -f noninteractive keyboard-configuration
