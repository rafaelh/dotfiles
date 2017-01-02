# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Enable programmable completion features
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi


# Basic environmental settings
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
shopt -s histappend
shopt -s checkwinsize
set show-all-if-ambiguous on


# Aliases
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

# Ubuntu/Debian 
alias update='sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove'


# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline


# Things to do if you ARE root ================================================
if [ "$EUID" -eq 0 ]; then

    # Set a colour prompt
    PS1='\[\e[1;31m\][\[\e[0;31m\]\u\[\e[1;31m\]@\[\e[0;31m\]\h\[\e[1;31m\]] [\[\e[1;34m\]\w\[\e[1;31m\]]\$\[\e[0m\] '

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
    PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] [\[\e[1;34m\]\w\[\e[1;32m\]]\$\[\e[0m\] '

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

    # Run Private Commands
    if [ -f /home/$USER/.private ]; then
        . /home/$USER/.private
    fi

fi


# For WSL + ConEmu - doesn't start in the right directory
cd
