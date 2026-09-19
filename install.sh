#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

link_file() {
  local src="$1"
  local dest="$2"

  if [[ -e "${dest}" && ! -L "${dest}" ]]; then
    echo "Backing up ${dest} to ${dest}.bak"
    mv "${dest}" "${dest}.bak"
  fi
  ln -sf "${src}" "${dest}"
}

mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}" \
  "${XDG_STATE_HOME:-${HOME}/.local/state}" \
  "${XDG_CACHE_HOME:-${HOME}/.cache}" \
  "${XDG_BIN_HOME:-${HOME}/.local/bin}"

for fileName in zshrc gitconfig vimrc bashrc bash_profile inputrc; do
  link_file "${DOTFILES_DIR}/${fileName}" "${HOME}/.${fileName}"
done

BIN_DIR="${XDG_BIN_HOME:-${HOME}/.local/bin}"

if compgen -G "${DOTFILES_DIR}/bin/*" > /dev/null; then
  for binFile in "${DOTFILES_DIR}/bin/"*; do
    link_file "${binFile}" "${BIN_DIR}/${binFile##*/}"
  done
  unset -v binFile
fi