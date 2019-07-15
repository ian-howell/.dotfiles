#!/bin/bash
set -x

echo "Updating less"

ARTIFACTS_DIR="${ARTIFACTS_DIR:-$(mktemp -d)}"

# Use a subshell so that we don't need to remember where we started
(
  cd "$ARTIFACTS_DIR"

  curl https://ftp.gnu.org/gnu/less/less-530.tar.gz > less-530.tar.gz
  tar -xzf less-530.tar.gz
  cd less-530
  sh configure
  make
  sudo make install
  for binary in less lessecho lesskey; do
    sudo rm -f "/usr/bin/$binary"
    sudo ln -s "/usr/local/bin/$binary" "/usr/bin/$binary"
  done
)

set +x
