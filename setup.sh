#!/bin/bash

prevent_apt_daemon_restart_prompts() {
    sudo sed -i "s/^#\$nrconf{restart} = 'i';/\$nrconf{restart} = 'a';/" /etc/needrestart/needrestart.conf
}

install_components() {
    local components=(
        "src/install_essentials.sh"
        "src/install_go.sh"
        "src/install_zsh.sh"
        "src/install_fzf.sh"
        "src/install_fd.sh"
        "src/remap_capslock.sh"
        "src/install_node.sh"
        "src/install_delta.sh"
        "src/install_lazygit.sh"
        "src/install_neovim.sh"
        "src/install_tmux.sh"
        "src/install_zoxide.sh"
        "src/install_sesh.sh"
        "src/install_ohmyposh.sh"
    )

    for component in "${components[@]}"; do
        source "$component"
    done
}

link_dotfiles() {
    # TODO: Just `go run` this. Currently, I need to rebuild the binary every time I
    # adjust my dotfile links.
    ./src/linkdotfiles/linkdotfiles
}

update_git_submodules() {
    git submodule update --init --recursive
}

main() {
    prevent_apt_daemon_restart_prompts
    install_components
    link_dotfiles
    update_git_submodules
    echo "========== COMPLETE =========="
}

main
