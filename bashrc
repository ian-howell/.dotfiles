# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# I want to automatically re-source my bashrc if the file has been
# changed since I loaded it. Start by getting the modified ctime.
BASHRC_MOD=`stat -c %Y ~/.bashrc`

#===[ convenience functions
    #===[ addpath
# Add to the path variable named by $1 the component $2.  $3 must be
# "append" or "prepend" to indicate where the component is added.
function addpath ()
{
    # Don't add directory if it doesn't exist...
    if [ -d "$2" ]; then
        eval value=\"\$$1\"
        case "$value" in
            *:$2:*|*:$2|$2:*|$2)  # if the directory is already in the path
                result="$value"  # use the old path
                ;;
            "")  # if the path is empty
                result="$2"  # use the directory (as the first item)
                ;;
            *)  #otherwise...
                case "$3" in
                    p*)  # if it looks like "prepend"
                        result="$2:${value}"  # add the directory to the front
                        ;;
                    *)  # otherwise
                        result="${value}:$2"  # add the directory to the back
                        ;;
                esac
        esac

        export "$1"="$result"
        unset result value
    fi
}
    #===]
    #===[ append
# convenience routine which appends a string to a path.
function append ()
{
    addpath "$1" "$2" append
}
    #===]
    #===[ prepend
# convenience routine which prepends a string to a path.
function prepend ()
{
    addpath "$1" "$2" prepend
}
    #===]
    #===[ rempath
# Remove from the path variable named by $1 the component $2.
function rempath ()
{
    # Process:
    # 1. Create a new variable for the path (starts as empty string)
    # 2. Walk through the current path one directory at a time
    # 3. Add the directory to the new path UNLESS it is $2
    # 4. Repeat 2 and 3 until all directories have been checked
    # 5. Overwrite the old path

    eval dirs=\"\$$1\"

    # split on colons
    PIFS=${IFS}
    IFS=:

    for dir in ${dirs}; do
        if [ ! -z "${dir}" ]; then  # if the string isn't null
            if [ ${dir} != "$2" ]; then  # if the directory is _not_ the one we want to remove
                if [ -z "${result}" ]; then  # if the current result _is_ null
                    result=${dir}  # start the result with this directory
                else
                    result=${result}:${dir}  # append this directory to the result
                fi
            fi
        fi
    done

    export "$1"="$result"
    unset dir dirs result

    IFS=${PIFS}
}
    #===]
#===]

if [[ -f ~/.funcs ]]; then
	source ~/.funcs
fi

#===[ history
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# max number of lines in the history file
HISTFILESIZE=20000000
# the number of commands to "remember"
HISTSIZE=10000000
# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize
#===]
#===[ colors
# enable color support of ls and grep
if [ -x /usr/bin/dircolors ]; then
    alias ls='ls --color=auto'
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colors for man
export LESS_TERMCAP_mb=$'\e[1;31m'     # begin bold
export LESS_TERMCAP_md=$'\e[1;33m'     # begin blink
export LESS_TERMCAP_so=$'\e[01;44;37m' # begin reverse video
export LESS_TERMCAP_us=$'\e[01;37m'    # begin underline
export LESS_TERMCAP_me=$'\e[0m'        # reset bold/blink
export LESS_TERMCAP_se=$'\e[0m'        # reset reverse video
export LESS_TERMCAP_ue=$'\e[0m'        # reset underline
export MANPAGER='less -s -M +Gg'       # percentage into the document
#===]
#===[ aliases
if [ -f ~/.sh_aliases ]; then
    source ~/.sh_aliases
fi
#===]
#===[ path
# initialize PATH
PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin

if [ "$TERM" != "tmux-256color" ]; then
	export TERM=xterm-256color
fi
prepend PATH $HOME/.local/bin
prepend PATH $HOME/bin

export PATH
#===]
#===[ editor
# use a *real* editor
export VISUAL=vim
export EDITOR="$VISUAL"
# turn on vi-mode
set -o vi
#===]
#===[ unsorted
# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# extended globbing for things like !(dont_match_me)
shopt -s extglob

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

xtitle $PWD

set -o notify           # Notify immediately if job changes state
shopt -s checkjobs      # lists the status of any stopped and running jobs before exiting

shopt -s no_empty_cmd_completion

# light spellcheck on cd
shopt -s cdspell

# This is kind of goofy. To check for interactive logins, you generally test the
# value of PS1 -- therefore, I need to set this at the very end, just in case..
if [ "$PS1" ]; then
    fastprompt
fi

# fzf settings
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
#===]

if [[ -f $HOME/.local_bashrc ]]; then
    source $HOME/.local_bashrc
fi

# vim:foldmethod=marker:foldlevel=0:foldmarker====[,===]
