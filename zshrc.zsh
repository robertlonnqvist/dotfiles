# Exit early, skip env and path stuff for non-interactive shells
[[ $- == *i* ]] || return

# ==============================================================================
# ENVIRONMENT & SHELL OPTIONS (Essential)
# ==============================================================================
export EDITOR=vim
[[ -z "${LANG}" ]] && export LANG=en_US.UTF-8

# Setup unified system paths
typeset -U path fpath

# ==============================================================================
# RUNTIME / PACKAGE MANAGER MANIFESTS (Homebrew, Nix)
# ==============================================================================
# Detect and initialize Homebrew/Linuxbrew
if [[ "$OSTYPE" == "darwin"* ]]; then
  BREW_EXE="/opt/homebrew/bin/brew"
else
  BREW_EXE="/home/linuxbrew/.linuxbrew/bin/brew"
fi

if [[ -x "$BREW_EXE" ]]; then
  eval "$("$BREW_EXE" shellenv)"
fi
unset BREW_EXE

# ==============================================================================
# EXECUTABLE PATH SEEDING & FILTERING
# ==============================================================================
path=(
  "${XDG_BIN_HOME:-${HOME}/.local/bin}"
  "${GOPATH:-${HOME}/go}/bin"
  "${HOME}/.cargo/bin"
  $path
)

path=($^path(N-/)) # Keep only real physical directories

# History config
HISTSIZE=10000
SAVEHIST=10000
HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/zsh_history"

# Shell adjustments
WORDCHARS=${WORDCHARS//[\/]/} # Remove path separator from word characters

setopt hist_ignore_space
setopt hist_ignore_dups
setopt auto_cd
setopt extended_glob
unsetopt case_glob

# Disable flow control terminal freezing (Ctrl+s, Ctrl+q)
[[ -t 0 ]] && stty -ixon -ixoff

# Load runtime environment variables
export LS_COLORS="di=01;36:ln=35:so=32:pi=33:ex=31:bd=01;36:cd=01;33:su=01;31:sg=01;35:tw=00;32:ow=00;34"
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export CLICOLOR=1
  export LSCOLORS="GxFxCxDxBxegedabagaced"
fi

# Inject completion paths *before* initialization steps
if [[ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-completions" ]]; then
  . "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-completions/zsh-completions.plugin.zsh"
fi

if [[ -d "${HOMEBREW_PREFIX}/share/zsh/site-functions" ]]; then
  fpath=("${HOMEBREW_PREFIX}/share/zsh/site-functions" $fpath)
fi

if [[ -d "/run/current-system/sw/share/zsh/site-functions" ]]; then
  fpath=("/run/current-system/sw/share/zsh/site-functions" $fpath)
fi

# ==============================================================================
# COMPLETION ENGINE CONFIGURATION & BEHAVIOR
# ==============================================================================
zmodload zsh/complist
typeset -g compdump="${XDG_CACHE_HOME:-$HOME/.cache}/zcompdump"
autoload -Uz compinit

# Simplified cache validation (Requires global extended_glob already active)
if [[ -f $compdump(#qN.m-1) ]]; then
  compinit -C -d "$compdump"
else
  compinit -i -d "$compdump"
fi

# Background file tracking compile
{ [[ ! "$compdump.zwc" -nt "$compdump" ]] && zcompile "$compdump"; } &|

comp-rebuild() {
  local compdump="${XDG_CACHE_HOME:-${HOME}/.cache}/zcompdump"
  rm -f -- "$compdump" "$compdump.zwc"
  autoload -Uz compinit && compinit -i -d "$compdump"
  echo "Completion cache rebuilt."
}

_comp_options+=(globdots)

# Core layout styling rules
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' users root "${USER}"
zstyle ':completion:*' use-ip true
zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
zstyle ':completion:*:functions' ignored-patterns '_*'
zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-${HOME}/.cache}/zcompcache"

# Fuzzy and case transformations
zstyle ':completion:*' matcher-list \
  'm:{a-zA-Z}={A-Za-z}' \
  'r:|[._-]=* r:|=*' \
  'l:|=* r:|=*' \
  'm:{[:lower:]}={[:upper:]}' \
  'm:{[:upper:]}={[:lower:]}'

zstyle ':completion:*' special-dirs true

# Context formatting overrides (kill process mapping, manual outputs)
zstyle ':completion:*:*:*:*:processes' command "ps -u $USER -o pid,user,comm -w -w"
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# ==============================================================================
# ALIAS DEFINITIONS
# ==============================================================================
alias python-http-server="python3 -m http.server"
alias my-ip="curl ifconfig.co"
alias grep="grep --color=auto"

# Bat replacements
if command -v bat >/dev/null; then
  alias cat="bat -pp"
  alias less="bat --paging=always"
  alias more="bat --paging=always"
  export PAGER="less -RF"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"
fi

# Eza replacements vs legacy fallback mapping
if command -v eza >/dev/null; then
  alias ls="eza --icons=auto --group-directories-first"
  alias ll="eza -lh --icons=auto --group-directories-first --git"
  alias la="eza -lah --icons=auto --group-directories-first --git"
  alias tree="eza --tree --icons=auto --group-directories-first"
else
  alias tree="tree -C"
  if [[ "${OSTYPE}" == "darwin"* ]]; then
    alias ls="ls -GFh"
  else
    alias ls="ls --color=auto -Fh"
  fi
fi

# ==============================================================================
# KEYBINDINGS & VI MODE ADJUSTMENTS
# ==============================================================================
bindkey -v
export KEYTIMEOUT=1

bindkey "^?" backward-delete-char # Fix backspace behavior
bindkey '^r' history-incremental-search-backward
bindkey '^s' history-incremental-search-forward
bindkey '^p' up-line-or-history
bindkey '^n' down-line-or-history
bindkey '^w' backward-kill-word
bindkey '^a' beginning-of-line
bindkey '^e' end-of-line
bindkey '^k' kill-line
bindkey '^u' backward-kill-line
bindkey '^l' clear-screen

# Command line buffer actions
autoload edit-command-line && zle -N edit-command-line
bindkey '^v' edit-command-line
bindkey -M vicmd "^v" edit-command-line

# Menu navigation profiles
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'left' vi-backward-char
bindkey -M menuselect 'down' vi-down-line-or-history
bindkey -M menuselect 'up' vi-up-line-or-history
bindkey -M menuselect 'right' vi-forward-char
bindkey -M menuselect '^y' accept-line
bindkey -M menuselect '^[' undo

# Dynamic block configurations for keymap mutations
_set_cursor_shape() {
  case ${KEYMAP} in
  vicmd) print -n "\e[1 q" ;;
  viins | main | isearch) print -n "\e[5 q" ;;
  *) print -n "\e[5 q" ;;
  esac
}

zle-keymap-select() { _set_cursor_shape; }
zle-line-init() {
  zle -K viins
  _set_cursor_shape
}
zle -N zle-keymap-select
zle -N zle-line-init

autoload -Uz add-zsh-hook
add-zsh-hook precmd _set_cursor_shape

# Terminfo-driven key assignments (Word hopping & pages)
[[ -n "${terminfo[kLFT3]}" ]] && bindkey "${terminfo[kLFT3]}" backward-word
[[ -n "${terminfo[kLFT5]}" ]] && bindkey "${terminfo[kLFT5]}" backward-word
[[ -n "${terminfo[kRIT3]}" ]] && bindkey "${terminfo[kRIT3]}" forward-word
[[ -n "${terminfo[kRIT5]}" ]] && bindkey "${terminfo[kRIT5]}" forward-word
[[ -n "${terminfo[kpp]}" ]] && bindkey "${terminfo[kpp]}" beginning-of-buffer-or-history
[[ -n "${terminfo[knp]}" ]] && bindkey "${terminfo[knp]}" end-of-buffer-or-history
[[ -n "${terminfo[kcbt]}" ]] && bindkey "${terminfo[kcbt]}" reverse-menu-complete

# ==============================================================================
# THIRD-PARTY TOOLS & PROMPT EXTENSIONS
# ==============================================================================
autoload -Uz colors && colors

# Starship Prompt setup
if command -v starship >/dev/null; then
  eval "$(starship init zsh)"
else
  PROMPT='%n@%m %1~ %# '
fi

# Modern completion enhancements plugins
if [ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions" ]; then
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  bindkey '^y' autosuggest-accept
  . "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh"
fi

if [ -d "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting" ]; then
  . "${XDG_DATA_HOME:-${HOME}/.local/share}/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh"
fi

# Language runtimes and jump wrappers
if command -v fnm >/dev/null; then
  eval "$(fnm env --shell zsh)"
fi

if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd=cd zsh)"
fi

# Local environment variables definitions sandbox fallback loader
[[ -e ~/.zshrc.local.zsh ]] && . ~/.zshrc.local.zsh
