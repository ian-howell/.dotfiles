#!/bin/bash

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

# Color codes
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

function main() {
  latest_version=$(get_latest_version)
  current_version=$(get_current_version)

  if [[ "$latest_version" == "$current_version" ]]; then
    echo -e "${GREEN}k9s is already at the latest version: ${latest_version}${NC}"
    return
  fi

  echo -e "${BLUE}Installing k9s ${latest_version}...${NC}"
  install_k9s
  echo -e "${GREEN}k9s ${latest_version} installed successfully!${NC}"
}

function get_latest_version() {
  # Get latest version from GitHub API
  url="https://api.github.com/repos/derailed/k9s/releases/latest"
  curl -s "$url" | grep -Po '"tag_name": *"v\K[^"]*'
}

function get_current_version() {
  if ! command -v k9s >/dev/null; then
    return
  fi
  k9s version --short | grep -oP 'Version:\s+v\K[^\s]+'
}

function install_k9s() {
  cd "$ARTIFACTS_DIR" || return

  local url
  url+="https://github.com/derailed/k9s/"
  url+="releases/download/v${latest_version}/"
  url+="k9s_Linux_amd64.tar.gz"
  
  echo -e "${YELLOW}Downloading k9s from ${url}${NC}"
  curl -sLo k9s.tar.gz "$url"
  tar xf k9s.tar.gz k9s
  sudo install k9s -D -t /usr/local/bin/
  
  echo -e "${GREEN}Installation complete. Verifying...${NC}"
  k9s version --short
}

main
