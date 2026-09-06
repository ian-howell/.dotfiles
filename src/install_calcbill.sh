#!/bin/bash

set -euo pipefail

readonly CALCBILL_REPOSITORY='git@github.com:ian-howell/calcbill.git'
readonly CALCBILL_REVISION='5287b3bb16aea61e4fe8b575afd5ed2a724a2ae2'

for prerequisite in git go; do
  if ! command -v "$prerequisite" >/dev/null 2>&1; then
    printf 'calcbill: required command not found: %s\n' "$prerequisite" >&2
    exit 1
  fi
done

if [[ ! "$CALCBILL_REVISION" =~ ^[0-9a-f]{40}$ ]]; then
  printf 'calcbill: CALCBILL_REVISION must be a published full commit SHA.\n' >&2
  exit 1
fi

if ! checkout_dir=$(mktemp -d); then
  printf 'calcbill: could not create a temporary checkout directory.\n' >&2
  exit 1
fi
readonly checkout_dir
trap 'rm -rf -- "$checkout_dir"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if ! git init --quiet "$checkout_dir"; then
  printf 'calcbill: could not initialize the temporary checkout.\n' >&2
  exit 1
fi

if ! GIT_SSH_COMMAND='ssh -o BatchMode=yes' git -C "$checkout_dir" fetch --depth 1 --no-tags "$CALCBILL_REPOSITORY" "$CALCBILL_REVISION"; then
  printf 'calcbill: could not fetch the pinned revision from %s; check SSH access to this private repository and that the commit is published.\n' "$CALCBILL_REPOSITORY" >&2
  exit 1
fi

if ! git -C "$checkout_dir" checkout --detach "$CALCBILL_REVISION"; then
  printf 'calcbill: could not check out the pinned revision.\n' >&2
  exit 1
fi

if [[ ! -f "$checkout_dir/install.sh" ]]; then
  printf 'calcbill: the pinned revision does not contain install.sh.\n' >&2
  exit 1
fi

if ! bash "$checkout_dir/install.sh"; then
  printf 'calcbill: install.sh failed to install into %s/.local/bin.\n' "$HOME" >&2
  exit 1
fi
