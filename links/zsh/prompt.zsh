# Outputs current branch info in prompt format
function git_prompt_info() {
  local ref
  ref=$(command git symbolic-ref HEAD 2> /dev/null) || \
  ref=$(command git rev-parse --short HEAD 2> /dev/null) || return 0
  local prefix suffix
  # prefix="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
  prefix="%{$fg_bold[blue]%}"
  suffix="%{$reset_color%} "
  echo "$prefix${ref#refs/heads/}$(parse_git_dirty)$suffix"
}

# Checks if working tree is dirty
function parse_git_dirty() {
  local STATUS=''
  local -a FLAGS
  local dirty clean
  dirty=" %{$fg[red]%}✗"
  clean=" %{$fg_bold[green]%}✓"
  staging=" %{$fg[yellow]%}★"
  FLAGS=('--porcelain')
  FLAGS+='--ignore-submodules=dirty'
  STATUS=$(command git status ${FLAGS} 2> /dev/null)

  UNTRACKED=$(command git status ${FLAGS} 2> /dev/null | grep "^??")
  INDEX_CHANGED=$(command git status ${FLAGS} 2> /dev/null | grep "^[^ ?].")
  WORKINGTREE_CHANGED=$(command git status ${FLAGS} 2> /dev/null | grep "^.[^ ?]")
  let "val = 0"
  if [[ -n $UNTRACKED ]]; then
    let "val = $val | 4"
  fi
  if [[ -n $INDEX_CHANGED ]]; then
    let "val = $val | 2"
  fi
  if [[ -n $WORKINGTREE_CHANGED ]]; then
    let "val = $val | 1"
  fi
  if [[ $val -eq 0 ]]; then
    echo " %{$fg_bold[green]%}$val"
  elif [[ "(( $val % 2 ))" -eq 0 ]]; then
    echo " %{$fg_bold[yellow]%}$val"
  else
    echo " %{$fg_bold[red]%}$val"
  fi
}

# If we're in an SSH session, show the hostname in the prompt
function ssh_prompt_info() {
  if [[ -n $SSH_CLIENT ]]; then
      echo " %{$fg_bold[red]%}SSH(%m)%{$reset_color%}"
  fi
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
  LINE1="$ret_status$(ssh_prompt_info)$directory $(git_prompt_info)"

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
