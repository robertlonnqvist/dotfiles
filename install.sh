#!/usr/bin/env bash

for fileName in inputrc bash_profile bashrc zshrc gitconfig vimrc
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
