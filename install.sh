#!/usr/bin/env bash

for file in inputrc bash_profile bashrc zshrc gitconfig vimrc
do
  ln -sf "${PWD}/${file}" "${HOME}/.${file}"
done
unset file
