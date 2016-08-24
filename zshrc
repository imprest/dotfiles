# load zgen
source "${HOME}/.zgen/zgen.zsh"

# zgen
export ZGEN_RESET_ON_CHANGE=($HOME/.zshrc)

if ! zgen saved; then
	echo "Creating a zgen save"

  # Prezto General options (from zpreztorc)
  zgen prezto '*:*' case-sensitive 'yes'
  zgen prezto '*:*' color 'yes'
  # Prezto module options i.e. zgen prezto <modulename> <option> <value(s)>
  zgen prezto terminal auto-title 'yes'
	zgen prezto editor key-bindings 'emacs'
  zgen prezto tmux:auto-start local 'yes'
	zgen prezto prompt theme 'sorin'
  # Load Prezto and other modules not set above
  zgen prezto
  zgen prezto tmux
  zgen prezto environment
  zgen prezto archive
	zgen prezto command-not-found
  zgen prezto directory
	zgen prezto git
  zgen prezto history
  zgen prezto node
  zgen prezto pacman
  zgen prezto rsync
  zgen prezto spectrum
  zgeb prezto ssh
  zgen prezto utility
  zgen prezto terminal
  zgen prezto completion
	zgen prezto syntax-highlighting
	zgen prezto history-substring-search
	zgen prezto autosuggestions

  # Oh-My-Zsh plugins
  # zgen oh-my-zsh

  # Other plugins
  zgen load arzzen/calc.plugin.zsh # Simple calc
  zgen load supercrabtree/k # k i.e. dir listing done better
  # zgen load k4rthik/git-cal # github like contributions calendar on terminal
  zgen load djui/alias-tips # alias tips
  zgen load gusaiani/elixir-oh-my-zsh # Elixir plugin i.e. aliases
  zgen load rupa/z # z i.e. get statistics about recently used dir and jump to them
  zgen load junegunn/fzf shell
  zgen load andrewferrier/fzf-z # Recent used directories i.e. cd <Ctrl-G>

	zgen save
fi

## Exports & settings
KEYTIMEOUT=1 # 10ms for key sequences
WORDCHARS='*?_-.[]~=&;!#$%^(){}<>'
export VISUAL=nvim
export EDITOR=$VISUAL
export LANG=en_GB.UTF-8
export ZSH_PLUGINS_ALIAS_TIPS_TEXT='💡  '
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export PATH=$HOME/Downloads/android-sdk-linux/tools:$PATH
export PGDATABASE='legacy' # frequently used database

## Keybindings
bindkey '^ ' autosuggest-accept # Autosuggestion
bindkey '^u' backward-kill-line # Like bash

# Install tmux plugin manager if not installed
if "test ! -d ~/.tmux/plugins/tpm" \
   "run 'git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm'"

# fzf
. /usr/share/fzf/key-bindings.zsh
. /usr/share/fzf/completion.zsh

