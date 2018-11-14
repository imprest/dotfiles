#!/bin/bash

# Download and install manjaro gnome edition

# Disable not needed services
sudo systemctl disable avahi-daemon

# select fastest mirrors
sudo pacman-mirrors -f 0

# run mhwd for nvidia drivers
# i.e. disable via bubblebee and acpi_rev_override=1 in /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="quiet nouveau.modeset=0 acpi_rev_override=1"
# sudo update-grub
#
# Add the following lines to new file -> /etc/modprobe.d/blacklist.conf
# blacklist nouveau
# options nouveau modeset=0
#
# check via
# cat /proc/acpi/bbswitch
# dmesg | grep bbswitch
# sudo mhwd -i pci video-hybrid-intel-nvidia-bumblebee

# remove following packages
sudo pacman -Rns konversation inkscape cantata skanlite kget \
  gnome-icon-theme oxygen oxygen-kde4 oxygen-icons gnome-themes-extra

# packages
sudo pacman -Syu zsh neovim python-neovim fzf ripgrep ctags npm \
  yay otf-fira-code erlang elixir inotify-tools postgresql
# optional
# weechat

# yay packages
# yay -S otf-fantasque-sans-mono # size 12 in konsole or 10.5 for fira retina
# yay -S dbview

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim
ln -sf ~/dotfiles/ctags ~/.ctags
nvim +PlugInstal +qall
nvim +UpdateRemotePlugins +qall

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# zsh and zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln -sf ~/dotfiles/zshrc ~/.zshrc
chsh -s /usr/bin/zsh

# node global packages
sudo npm install -g @vue/cli eslint neovim prettier
