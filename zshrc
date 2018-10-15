# Check if zplug is installed
if [[ ! -d ~/.zplug ]]; then
  git clone https://github.com/zplug/zplug ~/.zplug
fi

source ~/.zplug/init.zsh

zplug "k4rthik/git-cal"
zplug "supercrabtree/k"
zplug "lib/completion", from:oh-my-zsh
zplug "plugins/colored-man-pages", from:oh-my-zsh
zplug "modules/pacman", from:prezto
zplug "zsh-users/zsh-completions"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-history-substring-search"
# zplug "themes/spaceship", from:oh-my-zsh, as:theme
zplug denysdovhan/spaceship-prompt, use:spaceship.zsh, from:github, as:theme
SPACESHIP_CHAR_SYMBOL='λ '
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_ELIXIR_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_EXEC_TIME_SHOW=false

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
export PATH=$HOME/development/flutter/bin:$PATH # $HOME/.cargo/bin:$PATH
export FZF_DEFAULT_COMMAND='rg --files --follow'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

## FZF FUNCTIONS ##

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
fo() {
  local files
  IFS=$'\n' files=($(fzf-tmux --query="$1" --multi --select-1 --exit-0))
  [[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

# fh [FUZZY PATTERN] - Search in command history
fh() {
  print -z $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed 's/ *[0-9]* *//')
}

# fbr [FUZZY PATTERN] - Checkout specified branch
# Include remote branches, sorted by most recent commit and limited to 30
fgb() {
  local branches branch
  branches=$(git for-each-ref --count=30 --sort=-committerdate refs/heads/ --format="%(refname:short)") &&
  branch=$(echo "$branches" |
           fzf-tmux -d $(( 2 + $(wc -l <<< "$branches") )) +m) &&
  git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
}

# Keybindings
bindkey -e                             # emacs like keybind (e.x. Ctrl-a, Ctrl-e)
bindkey '^ ' autosuggest-accept        # Autosuggestion
bindkey '^u' backward-kill-line        # Like bash
bindkey '^[[Z' reverse-menu-complete   # Shift-Tab

# Aliases
alias vim="nvim"
alias kk="k -h"
alias ka="k -h -A"
alias ks="k -h -A -t"
alias k.="ls -d .* --color"
alias gd="git diff"
alias gs="git status"
alias gl="git log"
