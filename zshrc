
export EDITOR=nvim

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
# use ctrl left/right
bindkey '^[[1;5C' forward-word
bindkey '^[[1;5D' backward-word
# use alt left/right
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word
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
# Use Shift-Escape for reverse menu complete
bindkey '^[[Z' reverse-menu-complete

# paths
declare -U path
if [[ -d ~/.local/bin ]]; then
  path=(~/.local/bin $path[@])
fi
if [[ -d ~/.bin ]]; then
  path=(~/.bin $path[@])
fi
if [[ -d ~/.node_modules/bin ]]; then
  path=(~/.node_modules/bin $path[@])
fi
if [[ -d "${GOPATH:-~/go}/bin" ]]; then
  path=("${GOPATH:-~/go}/bin" $path[@])
fi
export PATH

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
alias vim="nvim"

# platform specific stuff
if [[ "$(uname)" == "Darwin" ]]; then
  export CLICOLOR=1
  export LSCOLORS="ExGxGxDxCxEgEdAbAgAcAd"
  alias ls="ls -GFh"
else
  alias ls="ls --color=auto -Fh"
fi

if [[ -f ~/.dir_colors ]]; then
  eval "$(dircolors -b ~/.dir_colors)"
else
  export LS_COLORS="di=1;34:ln=1;36:so=1;36:pi=1;33:ex=1;32:bd=1;34;46:cd=1;34;43:su=1;30;41:sg=1;30;46:tw=1;30;42:ow=1;30;43"
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
zstyle ':completion::complete:*' cache-path ~/.zcompcache

autoload -Uz compinit && compinit
autoload -Uz colors && colors

# prompt
setopt prompt_subst

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

__build_prompt() {

    local temp=''

    if [[ -n "${VIRTUAL_ENV}" ]]; then
      temp+="(${VIRTUAL_ENV##*/}) "
    fi

    if [[ -n "${SSH_TTY}" ]]; then
      temp+="%{$fg_bold[green]%}%n@%m "
    fi

    temp+="%{$fg_bold[blue]%}%c "

    echo "${temp}"
}

PROMPT="$(__build_prompt)%(?:%{$fg_bold[magenta]%}:%{$fg_bold[red]%}%s)❯ %{$reset_color%}"
if declare -f __git_ps1 2>&1 >/dev/null ; then
  precmd() {
    __git_ps1 "$(__build_prompt)" '%(?:%{$fg_bold[magenta]%}:%{$fg_bold[red]%}%s)❯ %{$reset_color%}' '%s '
  }
fi

if [[ -f ~/.zshrc.local ]]; then
  . ~/.zshrc.local
fi
