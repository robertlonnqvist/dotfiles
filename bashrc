if [[ -e /etc/bashrc ]]; then
  source /etc/bashrc
fi

export GOPATH=${HOME}/Development/go

# path modifications
for p in ${HOME}/.bin ${HOME}/.npm-packages/bin ${GOPATH}/bin; do
  if [[ -e "${p}" ]] && [[ ":${PATH}:" != *":${p}:"* ]]; then
    PATH="${p}:${PATH}"
  fi
done
unset p
export PATH

# my editor
export EDITOR=vim

# no forkedbooter popups in maven
export MAVEN_OPTS="-Djava.awt.headless=true"

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
if [[ -e /usr/local/share/bash-completion/bash_completion ]]; then
  source /usr/local/share/bash-completion/bash_completion
elif [[ -e /usr/share/bash-completion/bash_completion ]]; then
  source /usr/share/bash-completion/bash_completion
fi
if [[ -d ${HOME}/.bash_completion.d ]]; then
  for p in ${HOME}/.bash_completion.d/*; do
    if [[ -e "${p}" ]]; then
      source "${p}"
    fi
  done
  unset p
fi

# if no git prompt has been loaded, load one.
if ! declare -f __git_ps1 >/dev/null 2>&1 ; then
  if [[ -e /usr/share/git/completion/git-prompt.sh ]]; then
    source /usr/share/git/completion/git-prompt.sh
  elif [[ -e /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
    source /usr/share/git-core/contrib/completion/git-prompt.sh
  fi
fi

PS1='\[$(__exit_status_color)\]➜ \[\e[01;34m\]\W\[\e[00m\] '
if declare -f __git_ps1 >/dev/null 2>&1 ; then
  # prompt setup
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWCOLORHINTS=1
  PROMPT_COMMAND='__git_ps1 "\[$(__exit_status_color)\]➜ \[\e[01;34m\]\W\[\e[00m\]" " " " (%s)"'
fi

# if keychain is installed use it
command -v keychain >/dev/null 2>&1 && eval "$(keychain --eval --quiet id_rsa)"

# aliases
alias tree="tree -C"
alias mysql-drop-testdbs='mysql -u root -e "show databases" --batch --column-names=false|grep ^test_|xargs -n 1 -I{} mysql -u root -e "drop database {}"'
alias python-http-server="python -m SimpleHTTPServer"
alias myip="curl ifconfig.co"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias zgrep="grep --color=auto"
alias zegrep="zegrep --color=auto"
alias zfgrep="zfgrep --color=auto"

if [[ -e ~/.dir_colors ]]; then
  eval "$(dircolors -b ~/.dir_colors)"
fi

# platform specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS="ExGxFxDxCxegedabagacad"
  export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33:ex=1;32:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi
