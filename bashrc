# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi


# Set additional Directories for inclusion in the Path
export PATH=$PATH:/sbin:/usr/sbin:/usr/local/bin:/home/$USER/.bin

# Put your fun stuff here.
shopt -s histappend
shopt -s checkwinsize

# don't put duplicate lines in the history & ignore same successive entries
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

#if [ "$EUID" -ne 0 ]; then
#    vim () { 
#        if [[ `"$@"` > 1 ]]; then /usr/bin/vim $@;
#        elif [ $1 = '' ]; then /usr/bin/vim;
#        elif [ ! -f $1 ] || [ -w $1 ]; then /usr/bin/vim $@;
#        else
#            echo -n "File is readonly. Edit as root? (Y/n): "
#            read -n 1 yn; echo;
#        if [ "$yn" = 'n' ] || [ "$yn" = 'N' ]; then /usr/bin/vim $*;
#        else sudo /usr/bin/vim $*;
#        fi
#        fi
#}
#fi

# Makes [tab] show all possibilities immediately, rather than when pressed twice 
set show-all-if-ambiguous on


if [ -f /home/$USER/.private ]; then
    . /home/$USER/.private
fi

# Set a colour prompt
PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] [\[\e[1;34m\]\w\[\e[1;32m\]]\$\[\e[0m\] '

if [ "$EUID" -eq 0 ]; then
    PS1='\[\e[1;31m\][\[\e[0;31m\]\u\[\e[1;31m\]@\[\e[0;31m\]\h\[\e[1;31m\]] [\[\e[1;34m\]\w\[\e[1;31m\]]\$\[\e[0m\] '
fi

# Basic environmental settings
shopt -s histappend
shopt -s checkwinsize
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000
set show-all-if-ambiguous on

PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] [\[\e[1;34m\]\w\[\e[1;32m\]]\$\[\e[0m\] '

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
alias update='sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove'

# Tweak Directory Colours
#eval "`dircolors -b ${HOME}/dot_lin/dir_colors`"
alias path='echo -e ${PATH//:/\\n}'
alias wget='wget -c'
alias update='apt update && apt upgrade'

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# Requirement for WSL
cd
