#!/bin/bash

source "$HOME/.dotfiles/links/zsh/functions/dexec.sh"

# Opposite of cd. Giving an argument jumps up that many directories
bd() {
  iter="${1:-1}"
  while [[ "$iter" -gt 0 ]]
  do
      (( iter = iter - 1 ))
      cd ..
  done
}

# Add paging and color to various commands
grepc() { grep -I "$@" --color=always | less -R --quit-if-one-screen; }
agc() { ag --color --group "$@" | less -R --quit-if-one-screen; }
jqc() { jq -C "$@" | less -R --quit-if-one-screen; }
yqc() { yq -C "$@" | less -R --quit-if-one-screen; }
treec() { tree -C "$@" | less -R --quit-if-one-screen; }

count() {
  ag "$@" -c | awk '
    BEGIN {sum = 0; FS=":"}
      {printf "%-10d %s\n", $2, $1}
      {sum = sum + $2}
    END {printf "--------------------------------------------------------------------------------\n%-10d Total\n", sum}
    '
}

# Paste to ix.io
ix() {
  # examples: ix < file; command | ix
  curl -n -F 'f:1=<-' http://ix.io;
}

# Create a temporary directory, then go there.
# If an argument was provided, use it as a suffix
tmp() {
  suffix=
  if [[ -n "$1" ]]; then
    suffix="-$1"
  fi
  cd "$(mktemp -d --suffix="$suffix")"
}

# Like more, but side by side files
smore() {
  pr -m -T -s\| -W"$COLUMNS" "$@" | less -R --quit-if-one-screen
}

# Takes a list of files/directories "foo", and creates copies called "foo.bak"
bak() {
  for item in "$@"; do
    if [[ -e "$item" ]]; then
      printf "copying %s to %s.bak\n" "$item" "$item"
      cp -r "$item" "$item.bak"
    else
      printf "warning: file or directory \"%s\" could not be found - skipping\n" "$item"
    fi
  done
}

stealth-toggle() {
  if [[ -f ~/.zsh_history.bak ]]; then
    echo "STEALTH => NORMAL"
    grep -v "stealth-toggle" ~/.zsh_history.bak > ~/.zsh_history
    # Use a backslash here so that it doesn't use my alias
    \mv ~/.zsh_history.bak "$(mktemp)"
  else
    echo "NORMAL => STEALTH"
    mv ~/.zsh_history ~/.zsh_history.bak
  fi
}

append() {
  if (( $# != 1 )); then
    printf "Usage: %s <absolute_path>\n" "$0"
    printf "EXAMPLE: %s %s/bin\n" "$0" "$HOME"
    return
  fi
  addpath "$1" append
}

prepend() {
  if (( $# != 1 )); then
    printf "Usage: %s <absolute_path>\n" "$0"
    printf "EXAMPLE: %s %s/bin\n" "$0" "$HOME"
    return
  fi
  addpath "$1" prepend
}

# Add $1 to the PATH variable.  $2 must be "append" or "prepend" to indicate
# where the component is added.
addpath()
{
  # Don't add directory if it doesn't exist...
  if [ ! -d "$1" ]; then
    echo "$1 is not a directory"
    return
  fi

  value="$PATH"
  case "$value" in
    *:"$1":*|*:"$1"|"$1":*|"$1")  # if the directory is already in the path
      result="$value"  # use the old path
      ;;
    "")  # if the path is empty
      result="$1"  # use the directory (as the first item)
      ;;
    *)  #otherwise...
      case "$2" in
        p*)  # if it looks like "prepend"
          result="$1:$value"  # add the directory to the front
          ;;
        *)  # otherwise
          result="$value:$1"  # add the directory to the back
          ;;
      esac
  esac

  export PATH="$result"
  unset result value
}
