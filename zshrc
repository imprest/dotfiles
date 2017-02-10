# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
    git clone https://github.com/zplug/zplug ~/.zplug
fi

# Essential
source ~/.zplug/init.zsh # zplug update --self

# Prezto modules
zstyle ':prezto:*:*' case-sensitive 'yes'
zstyle ':prezto:*:*' color 'yes'
zstyle ':prezto:module:terminal' auto-title 'yes'
zstyle ':prezto:module:editor' key-bindings 'emacs'
zstyle ':prezto:module:pacman' frontend 'yaourt'
zstyle ':prezto:module:prompt' theme 'sorin'
zplug "modules/prompt", from:prezto
zplug "modules/tmux", from:prezto
zplug "modules/environment", from:prezto
zplug "modules/command-not-found", from:prezto
zplug "modules/directory", from:prezto
zplug "modules/git", from:prezto
zplug "modules/history", from:prezto
zplug "modules/node", from:prezto
zplug "modules/pacman", from:prezto
zplug "modules/spectrum", from:prezto
zplug "modules/ssh", from:prezto
zplug "modules/utility", from:prezto
zplug "modules/terminal", from:prezto
zplug "modules/completion", from:prezto
zplug "modules/syntax-highlighting", from:prezto
zplug "modules/history-substring-search", from:prezto
zplug "modules/autosuggestions", from:prezto

# Other plugins
zplug "arzzen/calc.plugin.zsh"    # Simple calc
zplug "supercrabtree/k"           # k i.e. dir listing done better
zplug "djui/alias-tips"           # alias tips
zplug "gusaiani/elixir-oh-my-zsh" # Elixir plugin i.e. aliases
zplug "knu/z", use:z.sh, defer:3  # z i.e. get statistics about recently used dir and jump to them
zplug "andrewferrier/fzf-z"       # Recent used directories i.e. cd <Ctrl-G>
zplug "b4b4r07/enhancd", use:"init.sh"

# Theme
# zplug "denysdovhan/spaceship-zsh-theme", as:theme

# Check for uninstalled plugins.
if ! zplug check; then
  printf "Install? [y/N]: "
  if read -q; then
    echo; zplug install
  else
    echo
  fi
fi

# Source plugins.
zplug load #--verbose

# Exports & settings
KEYTIMEOUT=1 # 10ms for key sequences
export VISUAL=nvim
export EDITOR=$VISUAL
export LANG=en_GB.UTF-8
export TERM='xterm-256color'
export ZSH_PLUGINS_ALIAS_TIPS_TEXT='💡  '
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export PATH=$HOME/Downloads/android-sdk-linux/tools:$PATH
export PGDATABASE='mgp' # frequently used database

# Keybindings
bindkey '^ ' autosuggest-accept # Autosuggestion
bindkey '^u' backward-kill-line # Like bash

# fzf
. /usr/share/fzf/key-bindings.zsh
. /usr/share/fzf/completion.zsh
export FZF_DEFAULT_COMMAND='tree -if'
export FZF_CTRL_T_COMMAND='tree -if'
export FZF_ALT_C_COMMAND='tree -ifd'

