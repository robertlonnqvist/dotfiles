if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# path modifications
for p in ~/.local/.bin ~/.bin ~/.npm-packages/bin ${GOPATH:-go}/bin; do
  if [[ -d "${p}" ]] && [[ ":${PATH}:" != *":${p}:"* ]]; then
    PATH="${p}:${PATH}"
  fi
done
unset p
export PATH

# my editor
export EDITOR=vim

# ignore dups and spaces in history
HISTCONTROL=ignoreboth
# history size
HISTSIZE=10000
HISTFILESIZE=${HISTSIZE}

# settings
shopt -s histappend
shopt -s checkwinsize
shopt -s autocd

# functions
man() {
  env LESS_TERMCAP_mb=$'\e[01;33m' \
      LESS_TERMCAP_md=$'\e[01;34m' \
      LESS_TERMCAP_me=$'\e[0m' \
      LESS_TERMCAP_se=$'\e[0m' \
      LESS_TERMCAP_so=$'\e[01;43;30m' \
      LESS_TERMCAP_ue=$'\e[0m' \
      LESS_TERMCAP_us=$'\e[01;36m' \
      man "$@"
}

__exit_status_color() {
  if [[ "$?" == "0" ]]; then echo -e "\e[01;32m"; else echo -e "\e[01;31m"; fi
}

# completions
if [[ -d /usr/local/etc/bash_completion.d ]]; then
  export BASH_COMPLETION_COMPAT_DIR="/usr/local/etc/bash_completion.d"
fi

if [[ -f /usr/local/etc/profile.d/bash_completion.sh ]]; then
  . /usr/local/etc/profile.d/bash_completion.sh
fi

if [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

# if no git prompt has been loaded, load one.
if ! declare -f __git_ps1 >/dev/null 2>&1 ; then
  if [[ -e /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
    . /usr/local/etc/bash_completion.d/git-prompt.sh
  elif [[ -e /usr/share/git/completion/git-prompt.sh ]]; then
    . /usr/share/git/completion/git-prompt.sh
  elif [[ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
  elif [[ -e /usr/lib/git-core/git-sh-prompt ]]; then
    . /usr/lib/git-core/git-sh-prompt
  fi
fi

PS1='\[$(__exit_status_color)\]> \[\e[01;34m\]\W\[\e[00m\] '
if declare -f __git_ps1 >/dev/null 2>&1 ; then
  # prompt setup
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWCOLORHINTS=1
  PROMPT_COMMAND='__git_ps1 "\[$(__exit_status_color)\]> \[\e[01;34m\]\W\[\e[00m\]" " " " (%s)"'
fi

# aliases
alias tree="tree -C"
alias python-http-server="python -m SimpleHTTPServer"
alias myip="curl ifconfig.co"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias zgrep="grep --color=auto"
alias zegrep="zegrep --color=auto"
alias zfgrep="zfgrep --color=auto"

if [[ -f ~/.dir_colors ]]; then
  eval "$(dircolors -b ~/.dir_colors)"
else
  export LS_COLORS="di=1;34:ln=1;36:so=1;36:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=1;30;41:sg=1;30;46:tw=1;30;42:ow=1;30;43"
fi

# platform specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS="ExGxGxDxCxEgEdAbAgAcAd"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi

if [[ -f ~/.bashrc.local ]]; then
  . ~/.bashrc.local
fi
