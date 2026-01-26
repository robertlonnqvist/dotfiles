#!/bin/sh

set -eu

if [ $# -lt 1 ]; then
  echo "Usage: $0 [bash|zsh]"
  exit 1
fi

TARGET_SHELL="${1}"
DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"

link_file() {
  src="$1"
  dest="$2"

  if [ -e "${dest}" ] && [ ! -L "${dest}" ]; then
    echo "WARNING: ${dest} already exists and is not a symlink. Skipping!"
  else
    ln -sfn "${src}" "${dest}"
  fi
}

BIN_DIR="${XDG_BIN_HOME:-${HOME}/.local/bin}"
DATA_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}"

mkdir -p "${DATA_HOME}" \
  "${XDG_STATE_HOME:-${HOME}/.local/state}" \
  "${XDG_CACHE_HOME:-${HOME}/.cache}" \
  "${BIN_DIR}"

for fileName in gitconfig vimrc; do
  link_file "${DOTFILES_DIR}/${fileName}" "${HOME}/.${fileName}"
done

case "${TARGET_SHELL}" in
bash)
  link_file "${DOTFILES_DIR}/bashrc.bash" "${HOME}/.bashrc"
  link_file "${DOTFILES_DIR}/bash_profile.bash" "${HOME}/.bash_profile"
  link_file "${DOTFILES_DIR}/inputrc" "${HOME}/.inputrc"
  ;;

zsh)
  link_file "${DOTFILES_DIR}/zshrc.zsh" "${HOME}/.zshrc"

  sync_plugin() {
    repoUrl="$1"

    # Strip trailing '.git' if present, then extract the last URL segment
    cleanUrl="${repoUrl%.git}"
    pluginName=$(basename "${cleanUrl}")
    pluginDir="${DATA_HOME}/${pluginName}"

    if [ -d "${pluginDir}" ]; then
      echo "Updating ${pluginName}..."
      git -C "${pluginDir}" pull
    else
      echo "Installing ${pluginName}..."
      git clone "${repoUrl}" "${pluginDir}"
    fi
  }

  sync_plugin "https://github.com/zsh-users/zsh-completions.git"
  sync_plugin "https://github.com/zsh-syntax-highlighting/zsh-syntax-highlighting.git"
  sync_plugin "https://github.com/zsh-autosuggestions/zsh-autosuggestions.git"
  ;;
*)
  echo "Error: Unsupported shell '${TARGET_SHELL}'. Choose 'bash' or 'zsh'."
  exit 1
  ;;
esac

# starship ignores xdg dirs... ~/.config should be explicitly used
mkdir -p "${HOME}/.config"
link_file "${DOTFILES_DIR}/starship.toml" "${HOME}/.config/starship.toml"

if [ -d "${DOTFILES_DIR}/bin" ]; then
  for binFile in "${DOTFILES_DIR}/bin/"*; do
    if [ -e "$binFile" ]; then
      link_file "${binFile}" "${BIN_DIR}/$(basename "$binFile")"
    fi
  done
fi
