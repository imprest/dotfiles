#!/bin/bash

# packages
sudo pacman -Syu fish tmux gitg fzf \
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

# fish and omf
curl -L http://get.oh-my.fish | fish
mkdir -p ~/.config/omf
ln -sf ~/dotfiles/omf/bundle ~/.config/omf/
ln -sf ~/dotfiles/omf/channel ~/.config/omf/
ln -sf ~/dotfiles/omf/init.fish ~/.config/omf/
ln -sf ~/dotfiles/omf/theme ~/.config/omf/

# atom
ln -sf ~/dotfiles/atom ~/.atom

echo "# Now for some manual stuff, sorry!"
echo "## nvim"
echo "To install the nvim plugins, open up vim and type ':PlugInstall'\n"

