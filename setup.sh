#!/bin/bash

# packages
sudo pacman -Syu zsh gitg firefox firefox-i18n-en-gb \
  erlang rebar nodejs gvim the_silver_searcher ctags \
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
echo "export EDITOR='vim --servername psql --remote-tab-wait'" >> ~/.zshrc
echo "export pgdatabase='legacy'" >> ~/.zshrc
echo "export PATH='`ruby -e 'print Gem.user_dir'`/bin:$PATH'" >> ~/.zshrc

chsh -s /bin/zsh

# vim
mkdir ~/.vim
ln -sf `pwd`/vimrc ~/.vimrc

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# erlang
cd /usr/lib/erlang/lib
sudo git clone https://www.github.com/rustyio/sync
cd sync
sudo make
cd ~/.

