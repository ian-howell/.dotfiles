#!/bin/bash

prevent_apt_daemon_restart_prompts() {
  sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
  local components=(
    "$HOME/.dotfiles/src/install_essentials.sh"
    "$HOME/.dotfiles/src/install_go.sh"
    "$HOME/.dotfiles/src/install_zsh.sh"
    "$HOME/.dotfiles/src/install_fzf.sh"
    "$HOME/.dotfiles/src/install_fd.sh"
    "$HOME/.dotfiles/src/remap_capslock.sh"
    "$HOME/.dotfiles/src/install_node.sh"
    "$HOME/.dotfiles/src/install_delta.sh"
    "$HOME/.dotfiles/src/install_lazygit.sh"
    "$HOME/.dotfiles/src/install_neovim.sh"
    "$HOME/.dotfiles/src/install_tmux.sh"
    "$HOME/.dotfiles/src/install_zoxide.sh"
    "$HOME/.dotfiles/src/install_sesh.sh"
    "$HOME/.dotfiles/src/install_ohmyposh.sh"
  )

  for component in "${components[@]}"; do
    source "$component"
  done
}

link_dotfiles() {
  # TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
  # adjust my dotfile links.
  "$HOME/.dotfiles/src/linkdotfiles/linkdotfiles"
}

update_git_submodules() {
  git submodule update --init --recursive
}

main() {
  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/.local/bin"

  prevent_apt_daemon_restart_prompts
  install_components
  link_dotfiles
  update_git_submodules
  echo "========== COMPLETE =========="
}

main
