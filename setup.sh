#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/log.sh"

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

  log_dir=$(mktemp -d /tmp/setup_logs.XXXXXX)

  for component in "${components[@]}"; do
    script_name=$(basename "$component")
    log_file="$log_dir/$script_name.log"
    echo "🚀 Running script: $script_name"
    if ! bash "$component" >"$log_file" 2>&1; then
      log "❌ Script $script_name failed. Check the log at $log_file for details."
    fi
  done

  log "Logs saved to: $log_dir"
}

link_dotfiles() {
  # TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
  # adjust my dotfile links.
  "$HOME/.dotfiles/src/linkdotfiles/linkdotfiles"
}

update_git_submodules() {
  ssh-keyscan -t ed25519 github.com >> ~/.ssh/known_hosts 2>/dev/null
  git submodule update --init --recursive
}

main() {
  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/.local/bin"

  prevent_apt_daemon_restart_prompts
  install_components
  link_dotfiles
  update_git_submodules
  log "🎉✨ All setup tasks are complete! Your environment is ready to go! 🚀"
}

main
