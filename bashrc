if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

export GOPATH=${HOME}/Development/go

# path modifications
for p in ${HOME}/.bin ${HOME}/.npm-packages/bin ${GOPATH}/bin; do
  if [[ -d "${p}" ]] && [[ ":${PATH}:" != *":${p}:"* ]]; then
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
if command -v >/dev/null 2>&1; then
  if [[ -d /usr/local/etc/bash_completion.d ]]; then
    for p in /usr/local/etc/bash_completion.d/*; do
      if [[ -f "${p}" ]]; then
        . "${p}"
      fi
    done
    unset p
  fi
  if [[ -f /usr/local/etc/profile.d/bash_completion.sh ]]; then
    . /usr/local/etc/profile.d/bash_completion.sh
  fi
elif [[ -f /usr/share/bash-completion/bash_completion ]]; then
  . /usr/share/bash-completion/bash_completion
fi

if [[ -d ${HOME}/.bash_completion.d ]]; then
  for p in ${HOME}/.bash_completion.d/*; do
    if [[ -f "${p}" ]]; then
      . "${p}"
    fi
  done
  unset p
fi

# if no git prompt has been loaded, load one.
if ! declare -f __git_ps1 >/dev/null 2>&1 ; then
  if [[ -f /usr/share/git/completion/git-prompt.sh ]]; then
    . /usr/share/git/completion/git-prompt.sh
  elif [[ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]]; then
    . /usr/share/git-core/contrib/completion/git-prompt.sh
  fi
fi

PS1='\[$(__exit_status_color)\]❯ \[\e[01;34m\]\W\[\e[00m\] '
if declare -f __git_ps1 >/dev/null 2>&1 ; then
  # prompt setup
  GIT_PS1_SHOWDIRTYSTATE=1
  GIT_PS1_SHOWUPSTREAM=auto
  GIT_PS1_SHOWSTASHSTATE=1
  GIT_PS1_SHOWUNTRACKEDFILES=1
  GIT_PS1_SHOWCOLORHINTS=1
  PROMPT_COMMAND='__git_ps1 "\[$(__exit_status_color)\]❯ \[\e[01;34m\]\W\[\e[00m\]" " " " (%s)"'
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

if [[ -f ~/.dir_colors ]]; then
  eval "$(dircolors -b ~/.dir_colors)"
fi

# platform specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS="exfxcxdxbxGxDxabagacad"
  export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi
