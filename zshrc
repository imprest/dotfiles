# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "k4rthik/git-cal"
zplug "arzzen/calc.plugin.zsh"
zplug "supercrabtree/k"
zplug "lib/completion", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "modules/pacman", from:prezto
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
zplug "themes/sorin", from:oh-my-zsh, as:theme

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

zplug 'zplug/zplug', hook-build:'zplug --self-manage'

# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# Settings
KEYTIMEOUT=1             # 10ms for key sequences
HISTFILE=$HOME/.zsh_history
HISTSIZE=4096
SAVEHIST=4096
setopt hist_ignore_dups  # ignore duplication command history list
setopt hist_ignore_space # ignore when commands starts with space
setopt share_history     # share command history data

# Exports
export VISUAL=nvim
export EDITOR=$VISUAL
export LANG=en_GB.UTF-8
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export ERL_AFLAGS='-kernel shell_history enabled'
export PGDATABASE='mgp_dev' # frequently used database
export PATH=$HOME/.yarn/bin:$PATH # $HOME/.cargo/bin:$PATH

# Keybindings
bindkey -e                             # emacs like keybind (e.x. Ctrl-a, Ctrl-e)
bindkey '^ ' autosuggest-accept        # Autosuggestion
bindkey '^u' backward-kill-line        # Like bash
bindkey '^[[Z' reverse-menu-complete # Shift-Tab
