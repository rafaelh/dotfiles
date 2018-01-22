# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


# Basic Settings - All Environments
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize
set show-all-if-ambiguous on

alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias ls='ls -h --color=auto'
alias grep='grep --color=auto'
alias rm='rm -i'
alias cp='cp -rfv'
alias df='pydf||df -h'
alias path='echo -e ${PATH//:/\\n}'
alias mount='mount | column -t'
alias openports='netstat -tulanp'
alias wget='wget -c'
alias term='echo $TERM'

if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
fi

# Ubuntu/Debian Specific
if [[ `uname -s` == Linux* ]]; then
    alias update='sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove'
    alias autoupdate='sudo apt-get update -y && sudo apt-get upgrade -y && sudo apt-get dist-upgrade -y && sudo apt-get autoremove -y'

# Cygwin Specific
elif [[ `uname -s` == CYGWIN* ]]; then
    alias update="~/.bin/cygupdate"
    alias ifconfig="ipconfig"
    alias traceroute="tracert"
    alias keyring="rundll32.exe keymgr.dll KRShowKeyMgr"
    alias ps="ps -W"
    alias sudo=""
    alias python="/cygdrive/c/Python36/python"
    alias pip="/cygdrive/c/Python36/Scripts/pip.exe"

    export CYGWIN="nodosfilewarning server"
    export DISPLAY=localhost:0.0
fi

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# Colour variable to make the next function more readable
COLOR_RED="\e[0;31m"
COLOR_YELLOW="\e[0;33m"
COLOR_GREEN="\e[0;32m"
COLOR_OCHRE="\e[38;5;95m"
COLOR_BLUE="\e[0;34m"
COLOR_WHITE="\e[0;37m"
COLOR_RESET="\e[0m"

function git_color {
    local git_status="$(git status 2> /dev/null)"

    if [[ ! $git_status =~ "working [tree|directory] clean"  ]]; then
        echo -e $COLOR_RED
    elif [[ $git_status =~ "Your branch is ahead of"  ]]; then
        echo -e $COLOR_YELLOW
    elif [[ $git_status =~ "nothing to commit"  ]]; then
        echo -e $COLOR_GREEN
    else
        echo -e $COLOR_OCHRE
    fi
}

function git_branch {
    local git_status="$(git status 2> /dev/null)"
    local on_branch="On branch ([^${IFS}]*)"
    local on_commit="HEAD detached at ([^${IFS}]*)"

    if [[ $git_status =~ $on_branch  ]]; then
        local branch=${BASH_REMATCH[1]}
        echo " ($branch)"
    elif [[ $git_status =~ $on_commit  ]]; then
        local commit=${BASH_REMATCH[1]}
        echo " ($commit)"
    fi
}

# Things to do if you ARE root ================================================
if [ "$EUID" -eq 0 ]; then

    # Set a colour prompt
    PS1='\[\e[1;31m\][\[\e[0;31m\]\u\[\e[1;31m\]@\[\e[0;31m\]\h\[\e[1;31m\]] [\[\e[0;33m\]\w\[\e[1;31m\]]\$\[\e[0m\] '

    # Set additional Directories for inclusion in the Path
    export PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin:/root/.bin

    # Run Private Commands
    if [ -f /root/.private ]; then
        . /root/.private
    fi

fi

# Things to do if you AREN'T root =============================================
if [ "$EUID" -ne 0 ]; then

    # Set a colour prompt
    PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] '
    PS1+='[\[\e[0;33m\]\w\[\e[1;32m\]]\$\[\e[0m\]'   # Working Directory
    PS1+="\[\$(git_color)\]"                         # Colors git status
    PS1+="\$(git_branch)"                            # Prints current branch
    PS1+="$COLOR_RESET "                             # Ends prompt

    # Aliases
    alias fdisk='sudo fdisk'
    alias service='sudo service'

    # Set additional Directories for inclusion in the Path
    export PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin:/home/$USER/.bin

    vim () { 
        if [ ! -f $1 ] || [ -w $1 ]; then /usr/bin/vim $@;
        else sudo /usr/bin/vim $@;
        fi
    }

    # Run Private Commands specific to the machine
    if [ -f /home/$USER/.private ]; then
        . /home/$USER/.private
    fi

    # Run Private Commands that apply to all machines
    if [ -f /mnt/c/Users/$USER/Dropbox/Computers/Private_Bash.sh ]; then
        . /mnt/c/Users/$USER/Dropbox/Computers/Private_Bash.sh
    fi
fi


# For WSL + ConEmu - doesn't start in the right directory
cd
