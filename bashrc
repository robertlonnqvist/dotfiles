#!/usr/bin/env bash

# If not running interactively, don't do anything further
case $- in
    *i*) ;;
      *) return;;
esac

set -o vi

export EDITOR=vim
[[ -z "${LANG}" ]] && export LANG=en_US.UTF-8

mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}" \
         "${XDG_STATE_HOME:-${HOME}/.local/state}" \
         "${XDG_CACHE_HOME:-${HOME}/.cache}" \
         "${XDG_BIN_HOME:-${HOME}/.local/bin}"

# Detect and initialize Homebrew/Linuxbrew
if [[ "$OSTYPE" == "darwin"* ]]; then
    BREW_EXE="/opt/homebrew/bin/brew"
    [[ ! -x "$BREW_EXE" ]] && BREW_EXE="/usr/local/bin/brew"
else
    BREW_EXE="/home/linuxbrew/.linuxbrew/bin/brew"
    [[ ! -x "$BREW_EXE" ]] && BREW_EXE="${HOME}/.linuxbrew/bin/brew"
fi

if [[ -x "$BREW_EXE" ]]; then
    eval "$("$BREW_EXE" shellenv)"
fi
unset BREW_EXE

path_prepend() {
    [[ -d "$1" ]] || return
    # Remove all instances of the path first
    PATH=":${PATH}:"
    PATH="${PATH//:$1:/:}"
    # Clean up edge colons and prepend
    PATH="${1}${PATH%:}"
    PATH="${PATH#:}"
    export PATH
}

path_prepend "${HOME}/.node_modules/bin"
path_prepend "${GOPATH:-${HOME}/go}/bin"
path_prepend "${HOME}/.cargo/bin"
path_prepend "${XDG_BIN_HOME:-${HOME}/.local/bin}"

export PATH

# disable flow control (Ctrl+s, Ctrl+q)
if [[ -t 0 ]]; then
  stty -ixon -ixoff
fi

shopt -s checkwinsize

export HISTCONTROL=ignorespace:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/bash_history"

# aliases
alias tree="tree -C"
alias python-http-server="python3 -m http.server"
alias my-ip="curl ifconfig.co"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias zgrep="grep --color=auto"
alias zegrep="zegrep --color=auto"
alias zfgrep="zfgrep --color=auto"

if type -p bat > /dev/null; then
  alias cat="bat -p"
fi

# platform specific stuff
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export CLICOLOR=1
  export LSCOLORS="exfxcxdxbxegedabagacad"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi

if [[ -f ~/.dir_colors ]] && command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b ~/.dir_colors)"
else
  export LS_COLORS="di=34:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
fi

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

get_toolbox_name() {
  if [[ -f /run/.containerenv ]]; then
    while IFS= read -r line; do
      if [[ "$line" =~ ^name=\"(.*)\" ]]; then
        echo "(${BASH_REMATCH[1]})"
        return
      fi
    done < /run/.containerenv
  fi
  echo ""
}

TOOLBOX_NAME=$(get_toolbox_name)

# Completion
if ! declare -F _completion_loader >/dev/null; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  fi

  if [[ -n "${HOMEBREW_PREFIX}" ]]; then
    if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
      . "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
    elif [[ -d "${HOMEBREW_PREFIX}/etc/bash_completion.d" ]]; then
      for completion in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
        [[ -r "$completion" ]] && . "$completion"
      done
      unset completion
    fi
  fi
fi

# Git prompt
if [ -f /usr/share/git-core/contrib/completion/git-prompt.sh ]; then
  . /usr/share/git-core/contrib/completion/git-prompt.sh
fi

# Configure git prompt variables
export GIT_PS1_SHOWCOLORHINTS=true
export GIT_PS1_SHOWDIRTYSTATE=y      # Show if working tree is dirty
export GIT_PS1_SHOWSTASHSTATE=y      # Show if there are stashed changes
export GIT_PS1_SHOWUNTRACKEDFILES=y  # Show if there are untracked files
export GIT_PS1_SHOWUPSTREAM=auto     # Show upstream branch status

PROMPT_CHAR="❯"
[[ "$TERM" == "linux" ]] && PROMPT_CHAR=">"

[[ -n "$TOOLBOX_NAME" ]] && TOOLBOX_PREFIX="$TOOLBOX_NAME " || TOOLBOX_PREFIX=""

PROMPT_COMMAND() {
  local last_exit_status="$?"
  
  local c_reset='\[\033[00m\]'
  local c_dir='\[\033[01;34m\]'
  local c_good='\[\033[01;32m\]'
  local c_bad='\[\033[01;31m\]'

  local prompt_char_color
  if [[ "$last_exit_status" -eq 0 ]]; then
    prompt_char_color="$c_good"
  else
    prompt_char_color="$c_bad"
  fi

  local pre="\n$TOOLBOX_PREFIX$c_dir\w$c_reset"
  local post="\n$prompt_char_color$PROMPT_CHAR$c_reset "
  
  __git_ps1 "$pre" "$post" " %s"
}

export PROMPT_COMMAND=PROMPT_COMMAND

if [[ -e ~/.bashrc.local.bash ]]; then
  . ~/.bashrc.local.bash
fi

