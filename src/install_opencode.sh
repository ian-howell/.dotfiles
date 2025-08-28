#!/usr/bin/env bash
set -euo pipefail
APP=opencode

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
ORANGE='\033[38;2;255;140;0m'
NC='\033[0m' # No Color

requested_version=${VERSION:-}

os=$(uname -s | tr '[:upper:]' '[:lower:]')
if [[ "$os" == "darwin" ]]; then
    os="darwin"
fi
arch=$(uname -m)

if [[ "$arch" == "aarch64" ]]; then
  arch="arm64"
elif [[ "$arch" == "x86_64" ]]; then
  arch="x64"
fi

filename="$APP-$os-$arch.zip"


case "$filename" in
    *"-linux-"*)
        [[ "$arch" == "x64" || "$arch" == "arm64" ]] || exit 1
    ;;
    *"-darwin-"*)
        [[ "$arch" == "x64" || "$arch" == "arm64" ]] || exit 1
    ;;
    *"-windows-"*)
        [[ "$arch" == "x64" ]] || exit 1
    ;;
    *)
        echo "${RED}Unsupported OS/Arch: $os/$arch${NC}"
        exit 1
    ;;
esac

INSTALL_DIR=$HOME/.opencode/bin
mkdir -p "$INSTALL_DIR"

if [ -z "$requested_version" ]; then
    url="https://github.com/sst/opencode/releases/latest/download/$filename"
    specific_version=$(curl -s https://api.github.com/repos/sst/opencode/releases/latest | awk -F'"' '/"tag_name": "/ {gsub(/^v/, "", $4); print $4}')

    if [[ $? -ne 0 ]]; then
        echo "${RED}Failed to fetch version information${NC}"
        exit 1
    fi
else
    url="https://github.com/sst/opencode/releases/download/v${requested_version}/$filename"
    specific_version=$requested_version
fi

print_message() {
    local level=$1
    local message=$2
    local color=""

    case $level in
        info) color="${GREEN}" ;;
        warning) color="${YELLOW}" ;;
        error) color="${RED}" ;;
    esac

    echo -e "${color}${message}${NC}"
}

check_version() {
    if command -v opencode >/dev/null 2>&1; then
        opencode_path=$(which opencode)


        ## TODO: check if version is installed
        # installed_version=$(opencode version)
        installed_version="0.0.1"
        installed_version=$(echo $installed_version | awk '{print $2}')

        if [[ "$installed_version" != "$specific_version" ]]; then
            print_message info "Installed version: ${YELLOW}$installed_version."
        else
            print_message info "Version ${YELLOW}$specific_version${GREEN} already installed"
            exit 0
        fi
    fi
}

download_and_install() {
    print_message info "Downloading ${ORANGE}opencode ${GREEN}version: ${YELLOW}$specific_version ${GREEN}..."
    mkdir -p opencodetmp && cd opencodetmp
    curl -# -L -o "$filename" "$url"
    unzip -q "$filename"
    mv opencode "$INSTALL_DIR"
    cd .. && rm -rf opencodetmp 
}

check_version
download_and_install
