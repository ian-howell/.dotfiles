#!/bin/bash
set -euo pipefail

# Install the latest stable Go, or a requested version (e.g. 1.27.1).
# Download, verify, and extract before replacing the existing installation.
main() {
  local version="${1:-}" arch metadata release filename checksum tarball
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=arm64 ;;
    *) printf 'Unsupported architecture: %s\n' "$(uname -m)" >&2; return 1 ;;
  esac
  if [[ "$(uname -s)" != Linux ]]; then
    printf 'This installer supports Linux only.\n' >&2
    return 1
  fi

  tmpdir=$(mktemp -d)
  trap 'rm -rf "$tmpdir"' EXIT
  metadata='https://go.dev/dl/?mode=json'
  [[ -z "$version" ]] || metadata+='&include=all'
  curl --fail --silent --show-error --location "$metadata" --output "$tmpdir/releases.json"
  release=$(jq -er --arg version "${version:+go$version}" --arg arch "$arch" '
    first(.[] | select(.stable and ($version == "" or .version == $version))
      | .files[] | select(.os == "linux" and .arch == $arch and .kind == "archive")
      | [.filename, .sha256] | @tsv)
  ' "$tmpdir/releases.json")
  IFS=$'\t' read -r filename checksum <<< "$release"
  tarball="$tmpdir/$filename"
  curl --fail --silent --show-error --location "https://go.dev/dl/$filename" --output "$tarball"
  printf '%s  %s\n' "$checksum" "$tarball" | sha256sum --check --status
  tar -C "$tmpdir" -xzf "$tarball"
  env -u GOROOT GOTOOLCHAIN=local "$tmpdir/go/bin/go" version

  # Stage on the destination filesystem so the directory moves are atomic.
  local stage
  stage=$(sudo mktemp -d /usr/local/.go-install.XXXXXX)
  if ! sudo cp -a "$tmpdir/go" "$stage/go"; then
    sudo rm -rf "$stage"
    return 1
  fi
  sudo chown -R root:root "$stage/go"
  if [[ -e /usr/local/go ]]; then
    sudo mv /usr/local/go "$stage/previous"
  fi
  if ! sudo mv "$stage/go" /usr/local/go; then
    if sudo test -e "$stage/previous"; then
      sudo mv "$stage/previous" /usr/local/go
    fi
    sudo rm -rf "$stage"
    return 1
  fi
  sudo rm -rf "$stage"
  env -u GOROOT GOTOOLCHAIN=local /usr/local/go/bin/go version
}

main "${1:-}"
