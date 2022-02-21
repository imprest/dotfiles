#!/bin/bash

# Download and install manjaro gnome edition

# Disable not needed services
sudo systemctl disable avahi-daemon

# select fastest mirrors
sudo pacman-mirrors -f 5

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

# packages
sudo pacman -Syu zsh neovim python-pynvim fzf ripgrep ttf-fira-code exa starship trash-cli\
  erlang elixir fop wxgtk inotify-tools postgresql
# size 9 in qterminal for fira mono retina 
# gnome-terminal text/background Gnome | palette Tango
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'Fira Code Retina 10'"
# optional
# weechat pdfarranger

# yay packages
# yay -S tectonic

# starship.toml
ln -sf `pwd`/starship.toml ~/.config/starship.toml

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim
nvim +PackerSync

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# zsh and zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln -sf ~/dotfiles/zshrc ~/.zshrc
chsh -s /usr/bin/zsh

# node global packages
npm i -g neovim
