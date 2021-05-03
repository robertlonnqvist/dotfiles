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

# keybindings (use sed -n l)
# delete path segments
autoload -U select-word-style && select-word-style bash
# emacs bindings
bindkey -e

# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[Shift-Tab]="${terminfo[kcbt]}"
key[Ctrl-Left]="${terminfo[kRIT5]}"
key[Ctrl-Right]="${terminfo[kLFT5]}"
key[Alt-Left]="${terminfo[kRIT3]}"
key[Alt-Right]="${terminfo[kLFT3]}"

# setup key accordingly
[[ -n "${key[Home]}"       ]] && bindkey -- "${key[Home]}"       beginning-of-line
[[ -n "${key[End]}"        ]] && bindkey -- "${key[End]}"        end-of-line
[[ -n "${key[Insert]}"     ]] && bindkey -- "${key[Insert]}"     overwrite-mode
[[ -n "${key[Backspace]}"  ]] && bindkey -- "${key[Backspace]}"  backward-delete-char
[[ -n "${key[Delete]}"     ]] && bindkey -- "${key[Delete]}"     delete-char
[[ -n "${key[Up]}"         ]] && bindkey -- "${key[Up]}"         up-line-or-history
[[ -n "${key[Down]}"       ]] && bindkey -- "${key[Down]}"       down-line-or-history
[[ -n "${key[Left]}"       ]] && bindkey -- "${key[Left]}"       backward-char
[[ -n "${key[Right]}"      ]] && bindkey -- "${key[Right]}"      forward-char
[[ -n "${key[PageUp]}"     ]] && bindkey -- "${key[PageUp]}"     beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"   ]] && bindkey -- "${key[PageDown]}"   end-of-buffer-or-history
[[ -n "${key[Shift-Tab]}"  ]] && bindkey -- "${key[Shift-Tab]}"  reverse-menu-complete
[[ -n "${key[Ctrl-Left]}"  ]] && bindkey -- "${key[Ctrl-Left]}"  forward-word
[[ -n "${key[Ctrl-Right]}" ]] && bindkey -- "${key[Ctrl-Right]}" backward-word
[[ -n "${key[Alt-Left]}"   ]] && bindkey -- "${key[Alt-Left]}"   forward-word
[[ -n "${key[Alt-Right]}"  ]] && bindkey -- "${key[Alt-Right]}"  backward-word

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
	autoload -Uz add-zle-hook-widget
	function zle_application_mode_start { echoti smkx }
	function zle_application_mode_stop { echoti rmkx }
	add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
	add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

# ctrl+u - delete from cursor to the beginning of the line
bindkey '^u' backward-kill-line

# up down history search
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   history-beginning-search-backward-end
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" history-beginning-search-forward-end

# enable edit command in editor
autoload -z edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# paths
declare -U path
if [[ -d ~/.local/bin ]]; then
  path=(~/.local/bin $path[@])
fi
if [[ -d ~/.node_modules/bin ]]; then
  path=(~/.node_modules/bin $path[@])
fi
if [[ -d "${GOPATH:-${HOME}/go}/bin" ]]; then
  path=("${GOPATH:-${HOME}/go}/bin" $path[@])
fi
if [[ -d ~/.cargo/bin ]]; then
  path=(~/.cargo/bin $path[@])
fi
if [[ -d /opt/homebrew/bin ]]; then
  path=(/opt/homebrew/bin $path[@])
fi
export PATH

# my editor
export EDITOR=vim

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

  # https://github.com/Homebrew/homebrew-core/issues/33275
  fpath[(i)/usr/local/share/zsh/site-functions]=()
  if [[ -e /usr/local/share/zsh/site-functions ]]; then
    fpath+=(/usr/local/share/zsh/site-functions)
  fi
  fpath[(i)/opt/homebrew/share/zsh/site-functions]=()
  if [[ -e /opt/homebrew/share/zsh/site-functions ]]; then
    fpath+=(/opt/homebrew/share/zsh/site-functions)
  fi
  # end fix

  if [[ -e /usr/local/share/zsh-completions ]]; then
    fpath+=(/usr/local/share/zsh-completions)
  fi
  if [[ -e /opt/homebrew/share/zsh-completions ]]; then
    fpath+=(/opt/homebrew/share/zsh-completions)
  fi

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
zstyle ':completion:*' users root ${USER}
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

# prompt
setopt prompt_subst

if ! declare -f __git_ps1 2>&1 >/dev/null ; then
  if [[ -e /opt/homebrew/etc/bash_completion.d/git-prompt.sh ]]; then
    . /opt/homebrew/etc/bash_completion.d/git-prompt.sh
  elif [[ -e /usr/local/etc/bash_completion.d/git-prompt.sh ]]; then
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

PROMPT="$(__build_prompt)%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%}%s)$ %{$reset_color%}"
if declare -f __git_ps1 2>&1 >/dev/null ; then
  precmd() {
    __git_ps1 "$(__build_prompt)" '%(?:%{$fg_bold[green]%}:%{$fg_bold[red]%}%s)$ %{$reset_color%}' '%s '
  }
fi

if [[ -f ~/.zshrc.local.zsh ]]; then
  . ~/.zshrc.local.zsh
fi
