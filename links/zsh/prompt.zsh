# Outputs git info in prompt format
function git_prompt_info() {
  if ! is_git_repo; then
    return
  fi

  local ref
  ref=$(git_ref)

  if is_git_dirty; then
    red ref
  else
    green ref
  fi
}
# is_git_repo returns 0 if the current directory is in a git repository, and 1 otherwise.
function is_git_repo() {
  git rev-parse --is-inside-work-tree &>/dev/null
}

# git_ref returns the current git branch or commit hash.
function git_ref() {
  local ref
  ref=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $ref ]]; then
    echo "${ref#refs/heads/}"
    return
  fi

  ref=$(git rev-parse --short HEAD 2> /dev/null)
  echo "${ref#refs/heads/}"
}

# is_git_dirty returns 0 if the current git repository has uncommitted changes, and 1 otherwise.
function is_git_dirty() {
  [[ -n $(git status --porcelain 2> /dev/null) ]]
}

# If we're in an SSH session, show the hostname in the prompt
function ssh_prompt_info() {
  if [[ -n $SSH_CLIENT ]]; then
    red "SSH(%m)"
  fi
}

function path_prompt_info() {
  case ${KEYMAP} in
    main|viins) 
      cyan "%c"
      return
      ;;
  esac

  magenta "%c"
}

function set_prompt() {
  # KEYMAP contains the currently selected keymap e.g. "main", "viins", "vicmd", etc
  # "main" is just an alias for "viins"
  case ${KEYMAP} in
    main|viins) mode_indication_color="%{$fg_bold[cyan]%}" ;;
    *)   mode_indication_color="%{$fg_bold[magenta]%}" ;;
  esac
  directory=" %{$mode_indication_color%}%c%{$reset_color%}"
  ret_status="%(?:%{$fg_bold[green]%}✓:%{$fg_bold[red]%}✗)%{$reset_color%}"
  LINE1="$ret_status$(ssh_prompt_info)$(path_prompt_info) $(git_prompt_info)"

  NEWLINE=$'\n'
  PROMPT="${LINE1}${NEWLINE}$ "

  zle reset-prompt
}

function zle-line-init zle-keymap-select {
  # zle-line-init and zle-keymap-select are user-defined functions which recieve special treatment when defined as widgets:
  # * zle-line-init is called when the shell first starts (oversimplified, but whatever)
  # * zle-keymap-select is called when the value of ${KEYMAP} changes
  set_prompt
}
# zle -N defines a function as a "widget"
zle -N zle-keymap-select
zle -N zle-line-init
#
# # Ensure that the prompt is redrawn when the terminal size changes.
# TRAPWINCH() {
#   zle && { zle -R; zle reset-prompt }
# }

# TODO: It would be nice to have a suite of these that are just always available.
function red() {
  echo "%{$fg_bold[red]%}$1%{$reset_color%}"
}

function green() {
  echo "%{$fg_bold[green]%}$1%{$reset_color%}"
}

function magenta() {
  echo "%{$fg_bold[magenta]%}$1%{$reset_color%}"
}

function cyan() {
  echo "%{$fg_bold[cyan]%}$1%{$reset_color%}"
}
