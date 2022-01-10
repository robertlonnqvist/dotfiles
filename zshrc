# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  . "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# setup standard directories
for p in "${XDG_DATA_HOME:-${HOME}/.local/share}" \
         "${XDG_DATA_HOME:-${HOME}/.local/share/zsh}" \
         "${XDG_DATA_HOME:-${HOME}/.local/share/zsh/site-functions}" \
         "${XDG_STATE_HOME:-${HOME}/.local/state}" \
         "${XDG_CONFIG_HOME:-${HOME}/.config}" \
         "${XDG_CONFIG_HOME:-${HOME}/.config/zsh}" \
         "${XDG_CACHE_HOME:-${HOME}/.cache}" \
         "${XDG_BIN_HOME:-${HOME}/.local/bin}"; do
  if [[ ! -e "${p}" ]]; then
    mkdir -p "${p}"
  fi
done
unset p

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

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups

setopt auto_cd
setopt extended_glob

bindkey -v

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
fpath=("${XDG_DATA_HOME:-${HOME}/.local/share}/zsh/site-functions" "${fpath[@]}")

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
setopt auto_menu
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

if [[ ! -e "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-completions" ]]; then
  git clone https://github.com/zsh-users/zsh-completions.git "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-completions"
fi
. "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-completions/zsh-completions.plugin.zsh"

autoload -Uz compinit && compinit -d "${XDG_CACHE_HOME:-${HOME}/.cache}/zcompdump"
autoload -Uz colors && colors

if [[ ! -e "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-vi-mode" ]]; then
  git clone https://github.com/jeffreytse/zsh-vi-mode.git "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-vi-mode"
fi
. "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-vi-mode/zsh-vi-mode.plugin.zsh"

if [[ ! -e "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting" ]]; then
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting"
fi
. "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"

if [[ ! -e "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions" ]]; then
  git clone https://github.com/zsh-users/zsh-autosuggestions.git "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions"
fi
. "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"

if [[ ! -e "${XDG_DATA_HOME:-${HOME}/.local/share}/powerlevel10k" ]]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "${XDG_DATA_HOME:-${HOME}/.local/share}/powerlevel10k"
fi
. "${XDG_DATA_HOME:-${HOME}/.local/share}/powerlevel10k/powerlevel10k.zsh-theme"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
if [[ -f ~/.p10k.zsh ]]; then
  . ~/.p10k.zsh
fi

if [[ -f ~/.zshrc.local.zsh ]]; then
  . ~/.zshrc.local.zsh
fi
