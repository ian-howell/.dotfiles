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

function xtitle ()
{
    case $- in *i*)
        case $TERM in
            xterm | xterm-256color | rxvt | screen)
                # put the arguments in the title bar
                echo -ne "\033]0;$*\007" ;;
            *)  ;;
        esac
    esac
}

# TODO: ask about how the fastprompt function works
function fastprompt()
{
    # tput bold - Bold effect
    # tput rev - Display inverse colors
    # tput sgr0 - Reset everything
    # tput setaf {CODE}- Set foreground color, see color {CODE} table below for more information.
    # tput setab {CODE}- Set background color, see color {CODE} table below for more information.
    #
    # 0	Black
    # 1	Red
    # 2	Green
    # 3	Yellow
    # 4	Blue
    # 5	Magenta
    # 6	Cyan
    # 7	White

    LAST_MOD=`stat -c %Y ~/.bashrc`
    if (( $LAST_MOD >  $BASHRC_MOD )); then
        source ~/.bashrc
        echo "bashrc reloaded"
    fi
    unset PROMPT_COMMAND
    PROMPT_COMMAND=fastprompt

    history -a
    case $TERM in
        xterm | xterm-256color | rxvt | screen )
            # begin building prompt
            PS1="\[$(tput bold)\]\[$(tput setaf 2)\]\u\[$(tput sgr0)\]"  # bold green username
            case $HOSTNAME in
                zld*) # dev machines (green)
                    PS1="$PS1@\[$(tput setaf 2)\]\h\[$(tput sgr0)\]"  # green hostname
                    ;;
                zlt*) # test machines (yellow)
                    PS1="$PS1@\[$(tput setaf 3)\]\h\[$(tput sgr0)\]"  # yellow hostname
                    ;;
                zlp* | *lpd*) # prod machines (red)
                    PS1="$PS1@\[$(tput setaf 1)\]\h\[$(tput sgr0)\]"  # red hostname
                    ;;
                mocdtl12jh6752) # my local machine
                    PS1="$PS1@\[$(tput bold)\]\[$(tput setaf 4)\]localhost\[$(tput sgr0)\]"  # blue "localhost"
                    ;;
                *)  # everything else
                    PS1="$PS1@\[$(tput setaf 6)\]\h\[$(tput sgr0)\]"  # blue hostname
                    ;;
            esac
            # finish building prompt
            PS1="$PS1$ "  # literal "$ "
            ;;
        *)
            PS1="\u@\h$ " ;;
    esac
}

function cd()
{
    case $TERM in
        xterm | xterm-256color | rxvt)  # if we're using an X window
            builtin cd "$@" && xtitle $HOSTNAME: $PWD ;;  # change the title bar
        *)
            builtin cd "$@";;
    esac
}

# Generate a random password
randpw(){ < /dev/urandom tr -dc A-Z-a-z-0-9%\!+@^ | head -c${1:-32};echo;}

todo(){ grep -Hnsr --color=always TODO $1 | cut -d':' -f-2,4- -s;}

###############################################################################
# history
###############################################################################
# don't put duplicate lines or lines starting with space in the history.
HISTCONTROL=ignoreboth
# append to the history file, don't overwrite it
shopt -s histappend
# max number of lines in the history file
HISTFILESIZE=2000
# the number of commands to "remember"
HISTSIZE=1000
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


###############################################################################
# aliases
###############################################################################
if [ -f ~/.sh_aliases ]; then
    source ~/.sh_aliases
fi
alias pwd='pwd;xtitle $HOSTNAME: $PWD'


###############################################################################
# path
###############################################################################
# initialize PATH
PATH=/usr/local/bin:/bin:/usr/bin:/usr/sbin:/sbin

# add go path
if [ -d /usr/local/go ]; then
    prepend PATH /usr/local/go/bin
    export GOPATH=$HOME/workspaces/golang
    prepend PATH $GOPATH/bin
fi

# TODO: ask about why the cygwin setup stuff is in an if/elif/else chain
if [[ $OSTYPE = cygwin ]]; then
    # setup maven and dircolors from cygwin
    prepend PATH "/cygdrive/c/Program Files/apache-maven-3.2.1/bin/"
    eval `dircolors --bourne-shell ~/.dircolors`
elif [[ -d /c/apache-maven-3.2.3/bin ]]; then
    # setup maven
    prepend PATH /c/apache-maven-3.2.3/bin
elif [[ `hostid` = "c98468fb" ]]; then
    # This is goofy. GIT_SSH points to the command for ssh that git will use.
    # You cannot include arguments to SSH via this variable; therefore, SOP
    # is to write a script wrapper for the SSH command... this is done,
    # exclusively as far as I can tell, to get around the "this machine's
    # fingerprint is unknown" message - which, will cause git to fail. Sigh.
    #

    # TODO: ask chris about his 'my_ssh'
    if [[ -d ~/bin ]]; then
        if [[ -f ~/bin/my_ssh ]]; then
            GIT_SSH='my_ssh'
        fi
    fi

    # TODO: ask about grc.bashrc
    if [ -f ~/.grc/grc.bashrc ]; then
        source ~/.grc/grc.bashrc
    fi

    export TERM=xterm-256color
    export EDITOR='vim'
    export VISUAL='vim'
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64
    prepend PATH /opt/app/apache-maven-3.3.9/bin
    prepend PATH /opt/app/eclipse
    prepend PATH /opt/app/docker
    CDPATH=:$HOME/git:$HOME/git/auth:$HOME/git/inno:$HOME/git/cadi
elif [[ -d /usr/lib/jvm/java-1.8.0-openjdk-amd64 ]]; then
    export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-amd64

elif [[ -d /opt/app/java/jdk/jdk170 ]]; then
    export JAVA_HOME=/opt/app/java/jdk/jdk170
fi

# TODO: ask about idea-IC
if [[ -d /opt/app/idea-IC-172.4574.11/bin ]]; then
    prepend PATH /opt/app/idea-IC-172.4574.11/bin
fi

# TODO: ask about maven versions
if [[ -d $HOME/apache-maven-3.2.3 ]]; then
    prepend PATH $HOME/apache-maven-3.2.3/bin
fi

if [ -d /opt/app/node-v4.4.5-linux-x64 ]; then
    prepend PATH /opt/app/node-v4.4.5-linux-x64/bin
fi

# TODO: ask about aft and swm
if [[ -d /opt/app/aft/aftswmcli/bin ]]; then
    prepend PATH /opt/app/aft/aftswmcli/bin
fi
if [[ -d /opt/app/swm/scldlrm/bin ]]; then
    prepend PATH /opt/app/swm/scldlrm/bin
fi

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

# add java home to PATh
prepend PATH $JAVA_HOME/bin
prepend PATH $JAVA_HOME/../bin

# add my own programs to the PATH
prepend PATH $HOME/.local/bin
prepend PATH $HOME/bin

export LD_LIBRARY_PATH
export MANPATH
export PATH

PYTHONPATH=$HOME/aafpylib:$PYTHONPATH


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

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

xtitle $HOSTNAME: $PWD

set -o notify           # Notify immediately if job changes state
shopt -s checkjobs      # lists the status of any stopped and running jobs before exiting

shopt -s no_empty_cmd_completion

# This is kind of goofy. To check for interactive logins, you generally test the
# value of PS1 -- therefore, I need to set this at the very end, just in case..
if [ "$PS1" ]; then
    fastprompt
fi

# home variables for various... things
# TODO: ask about all the SWMCLI_HOME variables
SWMCLI_HOME=/opt/app/aft/aftswmcli
export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin
# SWMCLI_HOME=/opt/app/aft/aftswmcli
# export SWMCLI_HOME
# PATH=$PATH:$SWMCLI_HOME/bin

# No idea where these are being set, so we'll just unset them here
unset NO_PROXY
unset https_proxy
unset HTTPS_PROXY
unset no_proxy
