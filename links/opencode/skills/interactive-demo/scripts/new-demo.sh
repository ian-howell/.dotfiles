#!/usr/bin/env bash
# Scaffold a demo directory with its own copy of the engine.
# Usage: new-demo.sh <target-dir> [--example <name>] [--force]
#   --example <name>  start from examples/<name> instead of the blank template
#   --force           overwrite existing files (the engine copy may hold demo-specific tweaks!)
set -euo pipefail
skill="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
target="" example="" force=0
while (($#)); do
  case "$1" in
    --example) example="${2:?--example needs a name}"; shift 2 ;;
    --force) force=1; shift ;;
    -*) echo "unknown option: $1" >&2; exit 2 ;;
    *) target="$1"; shift ;;
  esac
done
[[ -n "$target" ]] || { echo "usage: new-demo.sh <target-dir> [--example <name>] [--force]" >&2; exit 2; }
mkdir -p "$target"

put() { # put <source> <dest-name>
  local dest="$target/$2"
  if [[ -e "$dest" && $force -eq 0 ]]; then echo "kept     $dest (exists; use --force to overwrite)"; return; fi
  cp "$1" "$dest" && echo "wrote    $dest"
}
put "$skill/assets/engine.js" engine.js
put "$skill/assets/engine.css" engine.css
if [[ -n "$example" ]]; then
  [[ -d "$skill/examples/$example" ]] || { echo "no example named '$example'" >&2; exit 2; }
  put "$skill/examples/$example/index.html" index.html
  put "$skill/examples/$example/demo.js" demo.js
else
  put "$skill/assets/template.html" index.html
  put "$skill/assets/demo.js" demo.js
fi
