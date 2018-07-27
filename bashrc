# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

# I want to automatically re-source my bashrc if the file has been
# changed since I loaded it. Start by getting the modified ctime.
BASHRC_MOD=`stat -c %Y ~/.bashrc`


###############################################################################
# convenience functions
###############################################################################
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

# convenience routine which appends a string to a path.
function append ()
{
    addpath "$1" "$2" append
}

# convenience routine which prepends a string to a path.
function prepend ()
{
    addpath "$1" "$2" prepend
}

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

function cd_func()
{
    local x2 the_new_dir adir index
    local -i cnt

    if [[ $1 ==  "--" ]]; then
        dirs -v
        return 0
    fi

    the_new_dir=$1
    [[ -z $1 ]] && the_new_dir=$HOME

    if [[ ${the_new_dir:0:1} == '-' ]]; then
        #
        # Extract dir N from dirs
        index=${the_new_dir:1}
        [[ -z $index ]] && index=1
        adir=$(dirs +$index)
        [[ -z $adir ]] && return 1
        the_new_dir=$adir
    fi

    #
    # '~' has to be substituted by ${HOME}
    [[ ${the_new_dir:0:1} == '~' ]] && the_new_dir="${HOME}${the_new_dir:1}"

    #
    # Now change to the new dir and add to the top of the stack
    pushd "${the_new_dir}" > /dev/null
    [[ $? -ne 0 ]] && return 1
    the_new_dir=$(pwd)

    #
    # Trim down everything beyond 11th entry
    popd -n +11 2>/dev/null 1>/dev/null

    #
    # Remove any other occurence of this dir, skipping the top of the stack
    for ((cnt=1; cnt <= 10; cnt++)); do
        x2=$(dirs +${cnt} 2>/dev/null)
        [[ $? -ne 0 ]] && return 0
        [[ ${x2:0:1} == '~' ]] && x2="${HOME}${x2:1}"
        if [[ "${x2}" == "${the_new_dir}" ]]; then
            popd -n +$cnt 2>/dev/null 1>/dev/null
            cnt=cnt-1
        fi
    done

    return 0
}

if [[ -f ~/.funcs ]]; then
	source ~/.funcs
fi

###############################################################################
# history
###############################################################################
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


###############################################################################
# colors
###############################################################################
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

###############################################################################
# aliases
###############################################################################
if [ -f ~/.sh_aliases ]; then
    source ~/.sh_aliases
fi
alias pwd='pwd;xtitle $PWD'


###############################################################################
# path
###############################################################################
# initialize PATH
PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin

if [ "$TERM" != "tmux-256color" ]; then
	export TERM=xterm-256color
fi
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
export JUNIT_HOME=/usr/local/JUNIT
export CLASSPATH=$JUNIT_HOME/junit-4.10.jar:.

prepend PATH /opt/app/apache-maven-3.3.9/bin
prepend PATH /opt/app/eclipse
prepend PATH /opt/app/docker

# add java home to PATh
prepend PATH $JAVA_HOME/bin
prepend PATH $JAVA_HOME/../bin

# add my own programs to the PATH
prepend PATH $HOME/.local/bin
prepend PATH $HOME/bin

# setup cassandra
if [[ -d /opt/app/cassandra/bin ]]; then
    export CASS_HOME=/opt/app/cassandra
    prepend PATH /opt/app/cassandra/bin
elif [[ -d /opt/app/cassandra/2.1.14/bin ]]; then
    export CASS_HOME=/opt/app/cassandra/2.1.14
    prepend PATH /opt/app/cassandra/2.1.14/bin
elif [[ -d $HOME/cassandra ]]; then
    prepend PATH $HOME/cassandra/bin
elif [[ -d $HOME/apache-cassandra-2.1.3 ]]; then
    prepend PATH $HOME/apache-cassandra-2.1.3/bin
fi

export LD_LIBRARY_PATH
export MANPATH
export PATH

###############################################################################
# editor
###############################################################################
# use a *real* editor
export VISUAL=vim
export EDITOR="$VISUAL"
# turn on vi-mode
set -o vi


###############################################################################
# unsorted
###############################################################################
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

# Prevent ctrl-d from exiting the shell
set -o ignoreeof

# This is kind of goofy. To check for interactive logins, you generally test the
# value of PS1 -- therefore, I need to set this at the very end, just in case..
if [ "$PS1" ]; then
    fastprompt
fi

# No idea where these are being set, so we'll just unset them here
unset NO_PROXY
unset https_proxy
unset HTTPS_PROXY
unset no_proxy

# My personal bin
export PATH="/home/ih616h/bin:$PATH"
