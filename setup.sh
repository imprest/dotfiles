#!/bin/bash

# packages
sudo pacman -Syu zsh gitg \
  neovim python-neovim the_silver_searcher ctags \
  erlang elixir npm \
  thunderbird thunderbird-i18n-en-gb clamav simple-scan gnucash freerdp gimp \
  otf-fira-mono otf-fira-sans

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name "Hardik Varia"

# zsh
mkdir ~/.zprezto
git clone --recursive https://github.com/sorin-ionescu/prezto.git ~/.zprezto/
ln -sf ~/.zprezto/runcoms/zlogin    ~/.zlogin
ln -sf ~/.zprezto/runcoms/zlogout   ~/.zlogout
ln -sf ~/.zprezto/runcoms/zpreztorc ~/.zpreztorc
ln -sf ~/.zprezto/runcoms/zprofile  ~/.zprofile
ln -sf ~/.zprezto/runcoms/zshenv    ~/.zshenv
ln -sf ~/.zprezto/runcoms/zshrc     ~/.zshrc

echo "export pgdatabase='legacy'" >> ~/.zshrc

chsh -s /bin/zsh

# Neovim

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

