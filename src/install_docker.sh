#!/bin/bash

main() {
  uninstall_conflicting_packages
  setup_apt_repository
  install_docker
  add_user_to_docker_group
  setup_docker_service
}

function uninstall_conflicting_packages() {
  packages=(
    docker.io
    docker-doc
    docker-compose
    docker-compose-v2
    podman-docker
    containerd
    runc
  )
  for pkg in "${packages[@]}"; do sudo apt-get remove "$pkg"; done
}

setup_apt_repository() {
  # Add Docker's official GPG key:
  sudo apt-get update
  sudo apt-get install ca-certificates curl
  sudo install -m 0755 -d /etc/apt/keyrings
  sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
  sudo chmod a+r /etc/apt/keyrings/docker.asc

  # Add the repository to Apt sources:
  echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" |
    sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
  sudo apt-get update
}

install_docker() {
  sudo apt-get install -y \
    docker-ce \
    docker-ce-cli \
    containerd.io \
    docker-buildx-plugin \
    docker-compose-plugin
}

add_user_to_docker_group() {
  sudo groupadd docker
  sudo usermod -aG docker $USER
}

setup_docker_service() {
  # Enable Docker to start on boot
  sudo systemctl enable docker
  sudo systemctl start docker
}

main
