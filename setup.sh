#!/bin/bash

# packages
sudo pacman -Syu zsh tmux gitg fzf \
  neovim python-neovim the_silver_searcher ctags \
  erlang elixir npm \
  noto-fonts-cjk noto-fonts-emoji \
  postgresql pgadmin3 \
  thunderbird thunderbird-i18n-en-gb clamav simple-scan gnucash freerdp gimp

# yaourt packages
yaourt -S gitsh

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# tmux
ln -sf ~/dotfiles/tmux.conf ~/.tmux.conf

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# zsh
ln -sf ~/dotfiles/zshrc ~/.zshrc
chsh -s /bin/zsh
cd ~
git clone https://github.com/tarjoilija/zgen.git .zgen
