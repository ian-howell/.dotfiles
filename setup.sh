#!/bin/bash

# Prevent apt from bothering me about restarting daemons
sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf

# Order is (somewhat) important
source src/install_essentials.sh
source src/install_go.sh
source src/install_zsh.sh
source src/install_fzf.sh
source src/install_fd.sh
source src/remap_capslock.sh
source src/install_node.sh
source src/install_delta.sh
source src/install_lazygit.sh
source src/install_neovim.sh
source src/install_tmux.sh
source src/install_zoxide.sh
source src/install_sesh.sh
source src/install_ohmyposh.sh

# TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
# adjust my dotfile links.
./src/linkdotfiles/linkdotfiles

git submodule update --init --recursive

echo "========== COMPLETE =========="
