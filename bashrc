# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

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

if [ "$EUID" -ne 0 ]; then
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
fi

# Makes [tab] show all possibilities immediately, rather than when pressed twice 
set show-all-if-ambiguous on


if [ -f /home/$USER/.private ]; then
    . /home/$USER/.private
fi


PS1='\[\e[1;32m\][\[\e[0;32m\]\u\[\e[1;32m\]@\[\e[0;32m\]\h\[\e[1;32m\]] [\[\e[1;34m\]\w\[\e[1;32m\]]\$\[\e[0m\] '

if [ "$EUID" -eq 0 ]; then
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
alias update='sudo apt-get update && sudo apt-get upgrade && sudo apt-get dist-upgrade && sudo apt-get autoremove'

# Tweak Directory Colours
#eval "`dircolors -b ${HOME}/dot_lin/dir_colors`"

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

