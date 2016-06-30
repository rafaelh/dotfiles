# If not running interactively, don't do anything
[ -z "$PS1" ] && return

# Set additional Directories for inclusion in the Path
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin:/home/$USER/.bin

# Put your fun stuff here.
shopt -s histappend
shopt -s checkwinsize

# This colourizes man pages, but requires that 'most' is installed.
export PAGER="most"
export BROWSER="most" 

# don't put duplicate lines in the history & ignore same successive entries
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

vim () { 
    if [[ `"$@"` > 1 ]]; then /usr/bin/vim $@;
    elif [ $1 = '' ]; then /usr/bin/vim;
    elif [ ! -f $1 ] || [ -w $1 ]; then /usr/bin/vim $@;
    else
        echo -n "File is readonly. Edit as root? (Y/n): "
        read -n 1 yn; echo;
    if [ "$yn" = 'n' ] || [ "$yn" = 'N' ]; then /usr/bin/vim $*;
    else sudo /usr/bin/vim $*;
    fi
    fi
}

# Makes [tab] show all possibilities immediately, rather than when pressed twice 
set show-all-if-ambiguous on

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ] && ! shopt -oq posix; then
    . /etc/bash_completion
fi

if [ -f /home/$USER/.private ]; then
    . /home/$USER/.private
fi


PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] [\[\e[1;34m\]\w\[\e[1;32m\]]\$\[\e[0m\] '

if [ "$EUID" -ne 0 ]
    PS1='\[\e[1;31m\][\[\e[0;31m\]\u\[\e[1;31m\]@\[\e[0;31m\]\h\[\e[1;31m\]] [\[\e[1;34m\]\w\[\e[1;31m\]]\$\[\e[0m\] '
fi

# Aliases
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'
alias fdisk='sudo fdisk'
alias rm='rm -i'
alias cp='cp -rfv'
alias ls='ls -h --color=auto'
alias grep='grep --colour=auto'
alias df='pydf'
alias path='echo -e ${PATH//:/\\n}'
alias service='sudo service'
alias mount='mount | column -t'
alias openports='netstat -tulanp'
alias wget='wget -c'

# Ubuntu/Debian 
alias update='sudo apt-get update && sudo apt-get upgrade'
