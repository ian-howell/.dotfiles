#!/bin/bash

source "$HOME/.dotfiles/links/zsh/utils/output/output.sh"

BIN_DIR="$HOME/.local/bin"

main() {
  if [ ! -f "$BIN_DIR/oh-my-posh" ]; then
    print_light_gray_banner "Installing Oh My Posh"
    validate_dependencies
    validate_BIN_DIRectory
    install
  fi
}

install_ohmyposh() {
  mkdir -p "$BIN_DIR"
}

error() {
  printf "\e[31m$1\e[0m\n"
  exit 1
}

info() {
  printf "$1\n"
}

warn() {
  printf "⚠️  \e[33m$1\e[0m\n"
}

SUPPORTED_TARGETS="linux-386 linux-amd64 linux-arm linux-arm64 darwin-amd64 darwin-arm64 freebsd-386 freebsd-amd64 freebsd-arm freebsd-arm64"

validate_dependency() {
  if ! command -v "$1" >/dev/null; then
    error "$1 is required to install Oh My Posh. Please install $1 and try again.\n"
  fi
}

validate_dependencies() {
  validate_dependency curl
}

validate_BIN_DIRectory() {
  #check if installation dir exists
  if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
    return
  fi

  # Check if regular user has write permission
  if [ ! -w "$BIN_DIR" ]; then
    error "Cannot write to ${BIN_DIR}. Please check write permissions or set a different directory and try again: \ncurl -s https://ohmyposh.dev/install.sh | bash -s -- -d {directory}"
  fi

  # check if the directory is in the PATH
  good=$(
    IFS=:
    for path in $PATH; do
      if [ "${path%/}" = "${BIN_DIR}" ]; then
        printf 1
        break
      fi
    done
  )

  if [ "${good}" != "1" ]; then
    warn "Installation directory ${BIN_DIR} is not in your \$PATH, add it using \nexport PATH=\$PATH:${BIN_DIR}"
  fi
}

install() {
  arch=$(detect_arch)
  platform=$(detect_platform)
  target="${platform}-${arch}"

  good=$(
    IFS=" "
    for t in $SUPPORTED_TARGETS; do
      if [ "${t}" = "${target}" ]; then
        printf 1
        break
      fi
    done
  )

  if [ "${good}" != "1" ]; then
    error "${arch} builds for ${platform} are not available for Oh My Posh"
  fi

  info "\nℹ️  Installing oh-my-posh for ${target} in ${BIN_DIR}"

  executable=${BIN_DIR}/oh-my-posh
  url=https://cdn.ohmyposh.dev/releases/latest/posh-${target}

  info "⬇️  Downloading oh-my-posh from ${url}"

  http_response=$(curl -s -f -L "$url" -o "$executable" -w "%{http_code}")

  if [ "$http_response" != "200" ] || [ ! -f "$executable" ]; then
    error "Unable to download executable at ${url}\nPlease validate your curl, connection and/or proxy settings"
  fi

  chmod +x "$executable"

  info "🚀 Installation complete.\n\nYou can follow the instructions at https://ohmyposh.dev/docs/installation/prompt"
  info "to setup your shell to use oh-my-posh."
}

detect_arch() {
  arch="$(uname -m | tr '[:upper:]' '[:lower:]')"

  case "${arch}" in
  x86_64) arch="amd64" ;;
  armv*) arch="arm" ;;
  arm64) arch="arm64" ;;
  aarch64) arch="arm64" ;;
  i686) arch="386" ;;
  esac

  if [ "${arch}" = "arm64" ] && [ "$(getconf LONG_BIT)" -eq 32 ]; then
    arch=arm
  fi

  printf '%s' "${arch}"
}

detect_platform() {
  platform="$(uname -s | awk '{print tolower($0)}')"

  case "${platform}" in
  linux) platform="linux" ;;
  darwin) platform="darwin" ;;
  esac

  printf '%s' "${platform}"
}

main
