# Set the key timeout to 1 millisecond. This is needed to reduce
# the delay when switching between viins and vicmd modes.
KEYTIMEOUT=1

function set_prompt() {
  # Return code must be done first
  return_code_icon="$(returncode_prompt_info $?)"
  ssh_indicator="$(ssh_prompt_info)"
  path_indicator="$(path_prompt_info)"
  git_indicator="$(git_prompt_info)"

  # the first line will always start with the return code icon
  line1="$return_code_icon "

  # if we're in an SSH session, show the hostname
  if [[ -n $ssh_indicator ]]; then
    line1="$line1$ssh_indicator "
  fi

  # show the path
  line1="$line1$path_indicator "

  # if we're in a git repository, show the current branch or commit hash
  if [[ -n $git_indicator ]]; then
    line1="$line1$git_indicator "
  fi

  line2="$(prompt_icon) "

  # For some reason, I need this as a variable. I can't
  # just use a newline character in the PROMPT variable.
  newline=$'\n'
  PROMPT="${line1}${newline}${line2}"

  zle reset-prompt
}

# If we're in an SSH session, show the hostname in the prompt
function ssh_prompt_info() {
  if [[ -n $SSH_CLIENT ]]; then
    red_bold "SSH(%m)"
  fi
}

function path_prompt_info() {
  blue_bold "%c"
}

function prompt_icon() {
  # KEYMAP contains the currently selected keymap e.g. "main", "viins", "vicmd", etc
  # "main" is just an alias for "viins"
  case ${KEYMAP} in
    main|viins)
      green "$"
      ;;
    vicmd)
      blue "$"
      ;;
  esac
}

function returncode_prompt_info() {
  if [[ $1 -eq 0 ]]; then
    green "✓"
  else
    red "✗"
  fi
}

# If we're in a git repository, show the current branch or commit hash in the prompt
# If the repository is dirty, show the branch or commit hash in red
function git_prompt_info() {
  if ! is_git_repo; then
    return
  fi

  local ref
  ref=$(git_ref)
  if is_git_dirty; then
    red_bold $ref
  else
    green_bold $ref
  fi
}

# returns 0 if the current directory is in a git repository, and 1 otherwise.
function is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# git_ref returns the current git branch. If there is no active branch, return the commit hash.
function git_ref() {
  local branch
  branch=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $branch ]]; then
    echo "${branch#refs/heads/}"
    return
  fi

  # If the branch is not available, we're in a detached head state. Return the commit hash.
  git rev-parse --short HEAD 2> /dev/null
}

# is_git_dirty returns 0 if the current git repository has uncommitted changes, and 1 otherwise.
function is_git_dirty() {
  [[ -n $(git status --porcelain 2> /dev/null) ]]
}

# TODO: It would be nice to have a suite of these that are just always available.
function green() {
  echo "%{$fg[green]%}$1%{$reset_color%}"
}

function blue() {
  echo "%{$fg[blue]%}$1%{$reset_color%}"
}

function red_bold() {
  echo "%{$fg_bold[red]%}$1%{$reset_color%}"
}

function green_bold() {
  echo "%{$fg_bold[green]%}$1%{$reset_color%}"
}

function blue_bold() {
  echo "%{$fg_bold[blue]%}$1%{$reset_color%}"
}

# NOTE: This defines 2 functions that do the same thing. It's just goofy syntax.
function zle-line-init zle-keymap-select {
  # zle-line-init and zle-keymap-select are user-defined functions which
  # recieve special treatment when defined as widgets:
  # * zle-line-init is called when the shell first starts (oversimplified, but whatever)
  # * zle-keymap-select is called when the value of ${KEYMAP} changes
  set_prompt
}

# zle -N defines a function as a "widget"
zle -N zle-keymap-select
zle -N zle-line-init

# Ensure that the prompt is redrawn when the terminal size changes.
TRAPWINCH() {
  zle && { zle -R; zle reset-prompt }
}
