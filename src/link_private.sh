#!/bin/bash
# Link the optional work overlay, if it's cloned.
install="$HOME/.config/work/install"
if [[ -x $install ]]; then
  "$install"
else
  echo "work overlay not cloned; skipping"
fi
