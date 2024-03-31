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
sudo pacman -Syu fish neovim python-pynvim fzf ripgrep bat zoxide alacritty \
  ttf-firacode-nerd ttf-firacode exa trash-cli lazygit fd ncdu\
  erlang elixir fop wxgtk inotify-tools postgresql
# optional
# weechat pdfarranger
# gnome-terminal text/background Gnome | palette Tango
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'Fira Code Retina 9'"
# size 9 in qterminal for fira mono retina 
# konsole font size JetBrains Mono SemiBold 10
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'Inconsolata SemiBold 12'"
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'JetBrains Mono SemiBold 10'"

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# alacritty
ln -sf ~/dotfiles/alacritty.toml ~/.alacritty.toml

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# fish and fisher
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
ln -sf ~/dotfiles/config.fish ~/.config/fish/config.fish
ln -sf ~/dotfiles/fish_plugins ~/.config/fish/fish_plugins
chsh -s /bin/fish

# create a file in home dir ~/.npmrc with 'ignore-scripts=true'
echo 'ignore-scripts=true' > .npmrc
# node global packages
npm i -g neovim pnpm
