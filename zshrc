export EDITOR=vim
if [[ -z "${LANG}" ]]; then
  export LANG=en_US.UTF-8
fi

# history
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt append_history
setopt hist_ignore_space
setopt hist_ignore_dups
setopt share_history

setopt auto_cd
setopt extended_glob

bindkey -v
export KEYTIMEOUT=1

# Change cursor shape for different vi modes.
function zle-keymap-select {
  if [[ ${KEYMAP} == vicmd ]] || [[ $1 = 'block' ]]; then
    echo -ne '\e[1 q'
  elif [[ ${KEYMAP} == main ]] || [[ ${KEYMAP} == viins ]] || [[ ${KEYMAP} = '' ]] || [[ $1 = 'beam' ]]; then
    echo -ne '\e[5 q'
  fi
}
zle -N zle-keymap-select
zle-line-init() {
    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
    echo -ne "\e[5 q"
}
zle -N zle-line-init
echo -ne '\e[5 q' # Use beam shape cursor on startup.
preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

# Search backwards and forwards with a pattern
bindkey -M vicmd '/' history-incremental-pattern-search-backward
bindkey -M vicmd '?' history-incremental-pattern-search-forward

# set up for insert mode too
bindkey -M viins '^R' history-incremental-pattern-search-backward
bindkey -M viins '^S' history-incremental-pattern-search-forward

# some emacs standard shortcuts
bindkey -M viins '^U' backward-kill-line
bindkey -M viins '^W' backward-kill-word
bindkey -M viins '^A' beginning-of-line
bindkey -M viins '^K' kill-line
bindkey -M viins '^E' end-of-line

# allow ctrl-p, ctrl-n for navigate history (standard behaviour)
bindkey '^P' up-history
bindkey '^N' down-history

# allow ctrl-v to edit the command line (standard behaviour)
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey -M vicmd '^V' edit-command-line

# fix backspace bug when switching modes
bindkey "^?" backward-delete-char

# paths
declare -U path
for p in /usr/local/bin \
         /usr/local/sbin \
         /opt/homebrew/bin \
         /opt/homebrew/sbin \
         "${GOPATH:-~/go}/bin" \
         ~/.cargo/bin \
         ~/.node_modules/bin \
         ~/.local/bin; do
  if [[ -d "${p}" ]]; then
    path=("${p}" "${path[@]}")
  fi
done
unset p
export PATH

# aliases
alias tree="tree -C"
alias python-http-server="python3 -m http.server"
alias myip="curl ifconfig.co"
alias grep="grep --color=auto"
alias egrep="egrep --color=auto"
alias fgrep="fgrep --color=auto"
alias zgrep="grep --color=auto"
alias zegrep="zegrep --color=auto"
alias zfgrep="zfgrep --color=auto"

# platform specific stuff
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export CLICOLOR=1
  export LSCOLORS="ExGxGxDxCxEgEdAbAgAcAd"
  alias ls="ls -GFh"

  brewPrefix="$(brew --prefix)"

  if [[ -e "${brewPrefix}/share/zsh-completions" ]]; then
    fpath+=("${brewPrefix}/share/zsh-completions")
  fi

  # https://github.com/Homebrew/homebrew-core/issues/33275
  fpath[(i)${brewPrefix}/share/zsh/site-functions]=()
  if [[ -e "${brewPrefix}/share/zsh/site-functions" ]]; then
    fpath+=("${brewPrefix}/share/zsh/site-functions")
  fi
  # end fix

  unset brewPrefix

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
zstyle ':completion:*' users root "${USER}"
zstyle ':completion:*' use-ip true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path ~/.zcompcache

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

autoload -Uz compinit && compinit
autoload -Uz colors && colors

if [[ "${OSTYPE}" == "darwin"* ]]; then
  brewPrefix="$(brew --prefix)"
  if [[ -e "${brewPrefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]]; then
    . "${brewPrefix}/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
  fi

  if [[ -e "${brewPrefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]]; then
    . "${brewPrefix}/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
  fi
  unset brewPrefix
fi

if [[ -e "${HOME}/git/github.com/woefe/git-prompt.zsh/git-prompt.zsh" ]]; then
  ZSH_GIT_PROMPT_SHOW_STASH=1
  ZSH_GIT_PROMPT_SHOW_UPSTREAM="symbol"
  . "${HOME}/git/github.com/woefe/git-prompt.zsh/git-prompt.zsh"
fi

if [[ -f ~/.zshrc.local.zsh ]]; then
  . ~/.zshrc.local.zsh
fi
