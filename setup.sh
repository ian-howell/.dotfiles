#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/log.sh"

prevent_apt_daemon_restart_prompts() {
  sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
  # TODO: Turn these into a DAG and install everything concurrently.
  local components=(
    "$HOME/.dotfiles/src/install_essentials.sh"
    "$HOME/.dotfiles/src/update_git_submodules.sh"
    "$HOME/.dotfiles/src/install_go.sh"
    "$HOME/.dotfiles/src/install_zsh.sh"
    "$HOME/.dotfiles/src/install_fzf.sh"
    "$HOME/.dotfiles/src/install_fd.sh"
    "$HOME/.dotfiles/src/remap_capslock.sh"
    "$HOME/.dotfiles/src/install_node.sh"
    "$HOME/.dotfiles/src/install_bash_language_server.sh"
    "$HOME/.dotfiles/src/install_tree_sitter_cli.sh"
    "$HOME/.dotfiles/src/install_delta.sh"
    "$HOME/.dotfiles/src/install_lazygit.sh"
    "$HOME/.dotfiles/src/install_neovim.sh"
    "$HOME/.dotfiles/src/install_tmux.sh"
    "$HOME/.dotfiles/src/install_zoxide.sh"
    "$HOME/.dotfiles/src/install_sesh.sh"
    "$HOME/.dotfiles/src/install_ohmyposh.sh"
    "$HOME/.dotfiles/src/install_docker.sh"
    "$HOME/.dotfiles/src/install_opencode.sh"
    "$HOME/.dotfiles/src/install_stylua.sh"
    "$HOME/.dotfiles/src/link_dotfiles.sh"
  )

  log_dir=$(mktemp -d /tmp/setup_logs.XXXXXX)

  for component in "${components[@]}"; do
    script_name=$(basename "$component")
    log_file="$log_dir/$script_name.log"
    log "🚀 Running script: $script_name"
    if ! bash "$component" >"$log_file" 2>&1; then
      log "❌ Script $script_name failed. Check the log at $log_file for details."
    fi
  done

  log "Logs saved to: $log_dir"
}

main() {
  export PATH="$PATH:/usr/local/go/bin"
  export PATH="$PATH:$HOME/.local/bin"

  prevent_apt_daemon_restart_prompts
  install_components
  log "🎉✨ All setup tasks are complete! Your environment is ready to go! 🚀"
}

main
