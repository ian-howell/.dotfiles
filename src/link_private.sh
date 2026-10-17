#!/bin/bash
# Link the optional private config repo, if it's cloned.
install="$HOME/.config/hermes-private/install"
if [[ -x $install ]]; then
  "$install"
else
  echo "private config not cloned; skipping"
fi
