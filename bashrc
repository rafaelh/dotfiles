# Put your fun stuff here.
shopt -s histappend
shopt -s checkwinsize

# don't put duplicate lines in the history & ignore same successive entries
HISTCONTROL=ignoredups:ignoreboth
HISTSIZE=1000
HISTFILESIZE=2000

# Makes [tab] show all possibilities immediately, rather than when pressed twice 
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

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

