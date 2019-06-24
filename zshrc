
export GOPATH=${HOME}/Development/go

export EDITOR=vim

# no forkedbooter popups in maven
export MAVEN_OPTS="-Djava.awt.headless=true"

# history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups

setopt auto_cd
setopt extended_glob

# keybindings
# delete path segments
autoload -U select-word-style && select-word-style bash
# emacs bindings
bindkey -e
# ctrl-right - move forward one word
bindkey '^[[1;5C' forward-word
# ctrl-left - move backward one word
bindkey '^[[1;5D' backward-word
# forward delete
bindkey '^[[3~' delete-char
bindkey '^[3;5~' delete-char
# up down history search
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey '^[[A'  history-beginning-search-backward-end
bindkey '^[[B'  history-beginning-search-forward-end
# make Ctrl+U delete from cursor to the beginning of the line
bindkey '^U' backward-kill-line
# enable edit command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# paths
declare -U path
if [[ -d "${HOME}/.bin" ]]; then
  path=("${HOME}/.bin" $path[@])
fi
if [[ -d "${HOME}/.npm-packages/bin" ]]; then
  path=("${HOME}/.npm-packages/bin" $path[@])
fi
if [[ -d "${GOPATH}/bin" ]]; then
  path=("${GOPATH}/bin" $path[@])
fi
export PATH

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
  export LSCOLORS="Gxfxcxdxbxegedabagacad"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi

if [[ -f ~/.dir_colors ]]; then
  eval "$(dircolors -b ~/.dir_colors)"
else
  export LS_COLORS="di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"
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

# completion
setopt auto_menu
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' use-ip true
# case insensitive completion
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion:*:*:*:users' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${HOME}/.zcompcache"
zstyle ':completion:*' completer _complete _match _approximate

autoload -Uz compinit && compinit
autoload -Uz colors && colors

# prompt
setopt promptsubst

if ! declare -f __git_ps1 2>&1 >/dev/null ; then
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

GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUPSTREAM=auto
GIT_PS1_SHOWSTASHSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWCOLORHINTS=1

PROMPT='%(?:%{$fg_bold[green]%}> :%{$fg_bold[red]%}> %s)%{$fg[cyan]%}%c%{$reset_color%}%b '
if declare -f __git_ps1 2>&1 >/dev/null ; then
  precmd() {
    __git_ps1 '%(?:%{$fg_bold[green]%}> :%{$fg_bold[red]%}> %s)%{$fg_bold[cyan]%}%c%b' '%{$reset_color%} ' ' (%s)'
  }
fi

# if keychain is installed use it
command -v keychain >/dev/null 2>&1 && eval "$(keychain --eval --quiet id_rsa)"

# custom plugins
if [[ -d "${HOME}/.zsh" ]]; then
  for f in ${HOME}/.zsh/*.zsh(N); do
    . "$f"
  done
  unset f
fi
