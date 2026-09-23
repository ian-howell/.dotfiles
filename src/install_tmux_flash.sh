#!/bin/bash

set -euo pipefail

readonly REVISION='2d441894bc714e297c6583b1532981c18b1dc9b0'
readonly VERSION='v0.2.0-ian.1'
readonly SOURCE_SHA256='e22e1199a5b56648e51a5d13901c1d15040ccb6b991ff6435747b2dd726e0a00'
readonly ZIG_VERSION='0.16.0'
readonly destination="$HOME/.local/bin/flash_tmux"

if [[ -x "$destination" ]] && [[ "$("$destination" --version)" == "$VERSION" ]]; then
  printf 'flash.tmux: %s already installed\n' "$VERSION"
  exit 0
fi

case "$(uname -s)/$(uname -m)" in
  Linux/x86_64)
    architecture=x86_64
    zig_sha256='70e49664a74374b48b51e6f3fdfbf437f6395d42509050588bd49abe52ba3d00'
    ;;
  Linux/aarch64)
    architecture=aarch64
    zig_sha256='ea4b09bfb22ec6f6c6ceac57ab63efb6b46e17ab08d21f69f3a48b38e1534f17'
    ;;
  *) printf 'flash.tmux: installer supports Linux x86_64 and aarch64\n' >&2; exit 1 ;;
esac

tmpdir=$(mktemp -d)
trap 'rm -rf -- "$tmpdir"' EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

verify() {
  printf '%s  %s\n' "$1" "$2" | sha256sum --check --status
}

zig="$HOME/.local/share/zig-$architecture-linux-$ZIG_VERSION/zig"
if [[ ! -x "$zig" ]] || [[ "$("$zig" version)" != "$ZIG_VERSION" ]]; then
  curl --fail --location --silent --show-error \
    "https://ziglang.org/download/$ZIG_VERSION/zig-$architecture-linux-$ZIG_VERSION.tar.xz" \
    -o "$tmpdir/zig.tar.xz"
  verify "$zig_sha256" "$tmpdir/zig.tar.xz"
  mkdir -p "$HOME/.local/share"
  tar -xf "$tmpdir/zig.tar.xz" -C "$HOME/.local/share"
fi

curl --fail --location --silent --show-error \
  "https://api.github.com/repos/ian-howell/flash.tmux/tarball/$REVISION" \
  -o "$tmpdir/source.tar.gz"
verify "$SOURCE_SHA256" "$tmpdir/source.tar.gz"
mkdir "$tmpdir/source"
tar -xzf "$tmpdir/source.tar.gz" --strip-components=1 -C "$tmpdir/source"
(
  cd "$tmpdir/source"
  "$zig" build -Doptimize=ReleaseSafe
)
[[ "$("$tmpdir/source/zig-out/bin/flash_tmux" --version)" == "$VERSION" ]]
mkdir -p "$HOME/.local/bin"
install -m 755 "$tmpdir/source/zig-out/bin/flash_tmux" "$destination.new"
mv -f "$destination.new" "$destination"
printf 'flash.tmux: installed %s from %s\n' "$VERSION" "$REVISION"
