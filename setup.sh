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
sudo pacman -Syu fish neovim python-pynvim fzf fd ripgrep zoxide ghostty zed \
  ttf-jetbrains-mono exa trash-cli github-cli lazygit fd ncdu gvfs-google \
  curl git fop wxgtk inotify-tools postgresql vlc pdfarranger fastfetch wl-clipboard
# optional
# remmina freerdp gnome-characters fragments
# gnome-shell-extension-gsconnect gnome-shell-extension-dash-to-panel
# weechat simple-scan
# gnome-terminal text/background Gnome | palette Tango
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'Fira Code Retina 9'"
# size 9 in qterminal for fira mono retina 
# konsole font size JetBrains Mono SemiBold 10
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'Inconsolata SemiBold 12'"
# dconf write /org/gnome/terminal/legacy/profiles:/:<12312>/font "'JetBrains Mono SemiBold 10'"

# git
git config --global user.email "hardikvaria@gmail.com"
git config --global user.name  "Hardik Varia"

# ghostty
mkdir ~/.config/ghostty
ln -sf ~/dotfiles/config ~/.config/ghostty/config

# gnome-terminal with gtk.css
gsettings set org.gnome.Terminal.Legacy.Settings headerbar false
# curl -L https://raw.githubusercontent.com/catppuccin/gnome-terminal/v0.3.0/install.py | python3 -
dconf write /org/gnome/terminal/legacy/profiles:/:5083e06b-024e-46be-9cd2-892b814f1fc8/font "'Jet Brains Mono Bold 10.5'"
# 140 x 42
# hide scrollbar

# neovim
mkdir -p ~/.config/nvim
ln -sf ~/dotfiles/init.vim ~/.config/nvim/init.vim

# psql
ln -sf `pwd`/psqlrc ~/.psqlrc

# asdf -- get binary from github and put in .local/bin
# fish and fisher and asdf completions
curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher
ln -sf ~/dotfiles/config.fish ~/.config/fish/config.fish
ln -sf ~/dotfiles/fish_plugins ~/.config/fish/fish_plugins
mkdir -p ~/.config/fish/completions; and ln -s ~/.asdf/completions/asdf.fish ~/.config/fish/completions
chsh -s /bin/fish

# create a file in home dir ~/.npmrc with 'ignore-scripts=true'
echo 'ignore-scripts=true' > .npmrc
# node global packages
npm i -g neovim eslint
