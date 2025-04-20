#!/bin/bash

ARTIFACTS_DIR=${ARTIFACTS_DIR:-$(mktemp -d)}

main() {
  VERSION=$(curl -L -s https://dl.k8s.io/release/stable.txt)
  export VERSION
  download_binary
  validate_binary
  install_to_local_bin
}

download_binary() {
   curl -L \
    -o "$ARTIFACTS_DIR/kubectl" \
    "https://dl.k8s.io/release/$VERSION/bin/linux/amd64/kubectl"
}

validate_binary() {
  local sha256
  sha256=$(curl -L -s "https://dl.k8s.io/release/$VERSION/bin/linux/amd64/kubectl.sha256")
  echo "$sha256 $ARTIFACTS_DIR/kubectl" | sha256sum --check
}

install_to_local_bin() {
  sudo install -o root -g root -m 0755 "$ARTIFACTS_DIR/kubectl" /usr/local/bin/kubectl
}

main
