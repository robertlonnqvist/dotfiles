# shellcheck disable=SC1090,SC1091

# Exit early, skip env and path stuff for non-interactive shells
[[ $- == *i* ]] || return

# ==============================================================================
# ENVIRONMENT & SHELL OPTIONS (Essential)
# ==============================================================================
export EDITOR=vim
[[ -z "${LANG}" ]] && export LANG=en_US.UTF-8

# ==============================================================================
# RUNTIME / PACKAGE MANAGER MANIFESTS (Homebrew)
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
# EXECUTABLE PATH SEEDING
# ==============================================================================
if [[ -d "${HOME}/.cargo/bin" ]]; then
  export PATH="${HOME}/.cargo/bin:${PATH}"
fi
if [[ -d "${HOME}/go/bin" ]]; then
  export PATH="${HOME}/go/bin:${PATH}"
fi
export PATH="${XDG_BIN_HOME:-${HOME}/.local/bin}:${PATH}"

# Shell adjustments
set -o vi
shopt -s checkwinsize
shopt -s nocaseglob

# History config
export HISTCONTROL=ignorespace:erasedups
export HISTSIZE=10000
export HISTFILESIZE=10000
export HISTFILE="${XDG_STATE_HOME:-${HOME}/.local/state}/bash_history"

# Disable flow control terminal freezing (Ctrl+s, Ctrl+q)
[[ -t 0 ]] && stty -ixon -ixoff

# Load runtime environment variables
export LS_COLORS="di=01;36:ln=35:so=32:pi=33:ex=31:bd=01;36:cd=01;33:su=01;31:sg=01;35:tw=00;32:ow=00;34"
if [[ "${OSTYPE}" == "darwin"* ]]; then
  export CLICOLOR=1
  export LSCOLORS="GxFxCxDxBxegedabagaced"
fi

# ==============================================================================
# COMPLETION ENGINE CONFIGURATION & BEHAVIOR
# ==============================================================================
if ! declare -F _completion_loader >/dev/null; then
  # Load global system bash completions
  if [[ -f /usr/share/bash-completion/bash_completion ]]; then
    . /usr/share/bash-completion/bash_completion
  fi

  # Load Homebrew explicit completions
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
# THIRD-PARTY TOOLS & PROMPT EXTENSIONS
# ==============================================================================
# Starship Prompt setup
if command -v starship >/dev/null; then
  eval "$(starship init bash)"
fi

# Language runtimes and jump wrappers
if command -v fnm >/dev/null; then
  eval "$(fnm env --shell bash)"
fi

if command -v zoxide >/dev/null; then
  eval "$(zoxide init --cmd=cd bash)"
fi

# Local environment variables definitions sandbox fallback loader
[[ -e ~/.bashrc.local.bash ]] && . ~/.bashrc.local.bash
