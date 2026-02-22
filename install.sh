#!/usr/bin/env bash

for fileName in zshrc gitconfig vimrc bashrc bash_profile inputrc
do
  filePath="${HOME}/.${fileName}"
  if [[ -L "${filePath}" ]] || [[ ! -e "${filePath}" ]]
  then
    ln -sf "${PWD}/${fileName}" "${filePath}"
  else
    echo "Skipping ${filePath}, expected a symlink"
  fi
done
unset -v fileName filePath

mkdir -p "${XDG_DATA_HOME:-${HOME}/.local/share}" \
         "${XDG_STATE_HOME:-${HOME}/.local/state}" \
         "${XDG_CACHE_HOME:-${HOME}/.cache}" \
         "${XDG_BIN_HOME:-${HOME}/.local/bin}"
