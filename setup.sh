#!/bin/bash

# Download and install manjaro kde edition

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
sudo pacman -Syu plasma-wayland-session \
  neovim python-neovim fzf ripgrep \
  yay erlang elixir inotify-tools postgresql \
  weechat

# yay packages
yay -S otf-fantasque-sans-mono # size 12 in konsole
# yay -S dbview

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# zsh and zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
ln -sf ~/dotfiles/zshrc ~/.zshrc
chsh -s /usr/bin/zsh

echo "# Now for some manual stuff, sorry!"
echo "## nvim"
echo "To install the nvim plugins, open up vim and type ':PlugInstall'\n"

