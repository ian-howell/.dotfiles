#!/bin/bash

base_dir="$(dirname "$(realpath "$0")")"

prevent_apt_daemon_restart_prompts() {
  sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
  local components=(
    "$base_dir/src/install_essentials.sh"
    "$base_dir/src/install_go.sh"
    "$base_dir/src/install_zsh.sh"
    "$base_dir/src/install_fzf.sh"
    "$base_dir/src/install_fd.sh"
    "$base_dir/src/remap_capslock.sh"
    "$base_dir/src/install_node.sh"
    "$base_dir/src/install_delta.sh"
    "$base_dir/src/install_lazygit.sh"
    "$base_dir/src/install_neovim.sh"
    "$base_dir/src/install_tmux.sh"
    "$base_dir/src/install_zoxide.sh"
    "$base_dir/src/install_sesh.sh"
    "$base_dir/src/install_ohmyposh.sh"
  )

  for component in "${components[@]}"; do
    source "$component"
  done
}

link_dotfiles() {
  # TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
  # adjust my dotfile links.
  "$base_dir/src/linkdotfiles/linkdotfiles"
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
