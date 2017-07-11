set -xg PATH $HOME/Downloads/android-sdk-linux/tools $PATH
set -xg VISUAL nvim
set -xg EDITOR nvim
set -xg LANG en_GB.UTF-8
set -xg TERM 'xterm-256color'
set -xg PGDATABASE 'mgp' # frequently used database

set fish_greeting ""

# Awesome balias
balias pacU 'sudo yaourt -Syu'
balias paci 'sudo yaourt -S'
balias pacs 'yaourt -Ss'
balias pacX 'pacman -R'
