#!/bin/bash

# packages
sudo pacman -Syu zsh gitg firefox firefox-i18n-en-gb \
  elixir vim the_silver_searcher ctags \
  thunderbird thunderbird-i18n-en-gb clamav simple-scan gnucash freerdp gimp \
  ethtool intel-ucode

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

echo "export MYVIMRC='~/.vim/vimrc'" >> ~/.zshrc
echo "export pgdatabase='legacy'" >> ~/.zshrc

chsh -s /bin/zsh

# node pacakges
sudo npm install -g jshint

# vim
mkdir ~/.vim
cd ~/.
curl https://raw.githubusercontent.com/Shougo/neobundle.vim/master/bin/install.sh | sh
cd ~/dotfiles
ln -sf `pwd`/vimrc ~/.vimrc
vim +NeoBundleInstall +qall

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

