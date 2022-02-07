# setup standard directories
for p in "${XDG_DATA_HOME:-${HOME}/.local/share}" \
         "${XDG_STATE_HOME:-${HOME}/.local/state}" \
         "${XDG_CACHE_HOME:-${HOME}/.cache}" \
         "${XDG_BIN_HOME:-${HOME}/.local/bin}"; do
  if [[ ! -e "${p}" ]]; then
    mkdir -p "${p}"
  fi
done
unset p

_load_plugin() {
  local plugin_name="${1##*/}"
  local plugin_path="${XDG_DATA_HOME:-${HOME}/.local/share}/${plugin_name}"

  if [[ ! -e "${plugin_path}" ]]; then
    git clone --depth=1 "https://github.com/$1.git" "${plugin_path}"
  fi

  if [[ -e "${plugin_path}/${2}" ]]; then
    . "${plugin_path}/${2}"
  fi
}

export EDITOR=vim
if [[ -z "${LANG}" ]]; then
  export LANG=en_US.UTF-8
fi

# history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh_history"

# Remove path separator from WORDCHARS.
WORDCHARS=${WORDCHARS//[\/]}

setopt hist_ignore_space
setopt hist_ignore_dups

setopt auto_cd
setopt extended_glob

bindkey -v

_load_plugin jeffreytse/zsh-vi-mode zsh-vi-mode.plugin.zsh

# fix shift-tab backward completion
bindkey -M viins "${terminfo[kcbt]}" reverse-menu-complete
bindkey -M vicmd "${terminfo[kcbt]}" reverse-menu-complete

# ctrl-left and alt-left
bindkey '^[^[[D' backward-word
bindkey '^[[1;5D' backward-word

# ctrl-right and alt-right
bindkey '^[[1;5C' forward-word
bindkey '^[^[[C' forward-word

# paths
typeset -U path fpath
for p in /usr/local/bin \
         /usr/local/sbin \
         /opt/homebrew/bin \
         /opt/homebrew/sbin \
         "${GOPATH:-${HOME}/go}/bin" \
         ~/.cargo/bin \
         ~/.node_modules/bin \
         "${XDG_BIN_HOME:-${HOME}/.local/bin}"; do
  if [[ -d "${p}" ]]; then
    path=("${p}" "${path[@]}")
  fi
done
unset p
export PATH

if [[ -e /opt/homebrew/share/zsh/site-functions ]]; then
  fpath+=/opt/homebrew/share/zsh/site-functions
fi

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

if command -v bat &> /dev/null; then
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

if [[ -f ~/.dir_colors ]]; then
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

# completion
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' users root "${USER}"
zstyle ':completion:*' use-ip true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zcompcache"

# case insensitive completion
unsetopt case_glob
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# kill
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

_load_plugin zsh-users/zsh-completions zsh-completions.plugin.zsh

autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zcompdump"
autoload -Uz colors && colors

_load_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting.plugin.zsh
_load_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions.plugin.zsh
_load_plugin sindresorhus/pure

fpath=("${XDG_DATA_HOME:-${HOME}/.local/share}/pure" "${fpath[@]}")

autoload -U promptinit; promptinit
prompt pure

if [[ -f ~/.zshrc.local.zsh ]]; then
  . ~/.zshrc.local.zsh
fi
