# essential env first (available to non-interactive shells)
export EDITOR=vim
[[ -z "${LANG}" ]] && export LANG=en_US.UTF-8

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
    command -v git >/dev/null || return
    git clone --depth=1 "https://github.com/$1.git" "${plugin_path}" >/dev/null 2>&1 || return
  fi

  if [[ -n "$2" && -e "${plugin_path}/${2}" ]]; then
    . "${plugin_path}/${2}"
  fi
}

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

# disable flow control (Ctrl+s, Ctrl+q)
if [[ -t 0 ]]; then
  stty -ixon -ixoff
fi

# paths
typeset -U path fpath
path=(
  /usr/local/{bin,sbin}
  /opt/homebrew/{bin,sbin}
  "${GOPATH:-${HOME}/go}/bin"
  ~/.cargo/bin
  "${XDG_BIN_HOME:-${HOME}/.local/bin}"
  $path
)
# Filter out non-existent directories in one go
path=($^path(N-/))


if [[ -e /opt/homebrew/share/zsh/site-functions ]]; then
  fpath+=/opt/homebrew/share/zsh/site-functions
fi

# Stop here for non-interactive shells
[[ -o interactive ]] || return

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

# completion
zmodload zsh/complist
typeset -g compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
autoload -Uz compinit

# Only check security/rebuild cache once a day, otherwise skip checks (-C)
if [[ -n "$compdump(#qN.m-1)" ]]; then
  compinit -C -d "$compdump"
else
  compinit -i -d "$compdump"
fi
# Compile zcompdump to bytecode in the background for even faster loading next time
{ [[ ! "$compdump.zwc" -nt "$compdump" ]] && zcompile "$compdump" } &!

comp-rebuild() {
  local compdump="${XDG_CACHE_HOME:-${HOME}/.cache}/zcompdump"
  # Delete both the text dump and the compiled bytecode
  rm -f -- "$compdump" "$compdump.zwc"

  # Re-initialize with a full security scan (-i)
  autoload -Uz compinit && compinit -i -d "$compdump"

  echo "Completion cache rebuilt."
}

# Include hidden files.
_comp_options+=(globdots)

zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' users root "${USER}"
zstyle ':completion:*' use-ip true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zcompcache"

# case insensitive completion
unsetopt case_glob
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*' \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:upper:]}={[:lower:]}'

# complete . and .. special directories
zstyle ':completion:*' special-dirs true

# kill
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'

# man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# vi mode

bindkey -v
export KEYTIMEOUT=1

# fix backspace bug when switching modes
bindkey "^?" backward-delete-char

# standard keys
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^p' up-line-or-history
bindkey '^n' down-line-or-history
bindkey '^w' backward-kill-word
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
bindkey '^u' backward-kill-line
bindkey '^y' accept-line
bindkey '^l' clear-screen

# edit line in vim buffer ctrl-v
autoload edit-command-line && zle -N edit-command-line
bindkey '^v' edit-command-line
bindkey -M vicmd "^v" edit-command-line

# use vim keys in tab complete menu
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'left' vi-backward-char
bindkey -M menuselect 'down' vi-down-line-or-history
bindkey -M menuselect 'up' vi-up-line-or-history
bindkey -M menuselect 'right' vi-forward-char
# exit menuselect on escape
bindkey -M menuselect '^[' undo

# Change cursor shape for different vi modes
function _set_cursor_shape() {
  case ${KEYMAP} in
    vicmd)      print -n "\e[1 q" ;; # Block for Command Mode
    viins|main) print -n "\e[5 q" ;; # Beam for Insert Mode
    isearch)    print -n "\e[5 q" ;; # Beam for Search Mode
  esac
}

# Define the widgets
zle-keymap-select() { _set_cursor_shape }
zle-line-init() { zle -K viins; _set_cursor_shape }

zle -N zle-keymap-select
zle -N zle-line-init

# Ensure cursor resets to beam before every new prompt
precmd_functions+=(_set_cursor_shape)

# see https://gist.github.com/ketsuban/651e24c2d59506922d928c65c163d79c

# ctrl-left and alt-left
[[ -n "${terminfo[kLFT3]}" ]] && bindkey "${terminfo[kLFT3]}" backward-word
[[ -n "${terminfo[kLFT5]}" ]] && bindkey "${terminfo[kLFT5]}" backward-word
# ctrl-right and alt-right
[[ -n "${terminfo[kRIT5]}" ]] && bindkey "${terminfo[kRIT5]}" forward-word
[[ -n "${terminfo[kRIT3]}" ]] && bindkey "${terminfo[kRIT3]}" forward-word
# pgUp and pgDown
[[ -n "${terminfo[kpp]}" ]] && bindkey "${terminfo[kpp]}" beginning-of-buffer-or-history
[[ -n "${terminfo[knp]}" ]] && bindkey "${terminfo[knp]}" end-of-buffer-or-history

# make reverse completion work (Shift+Tab)
[[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

_load_plugin zsh-users/zsh-completions zsh-completions.plugin.zsh

autoload -Uz colors && colors

# plugins (order matters)
_load_plugin zsh-users/zsh-autosuggestions zsh-autosuggestions.plugin.zsh
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
ZSH_AUTOSUGGEST_STRATEGY=(history completion)

_load_plugin zsh-users/zsh-syntax-highlighting zsh-syntax-highlighting.plugin.zsh
_load_plugin sindresorhus/pure

fpath=("${XDG_DATA_HOME:-${HOME}/.local/share}/pure" "${fpath[@]}")

autoload -U promptinit; promptinit
prompt pure

if [[ -e ~/.zshrc.local.zsh ]]; then
  . ~/.zshrc.local.zsh
fi
