# Initialise Zinit if not installed
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
ZINIT_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit"
if [[ ! -d $ZINIT_HOME ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$ZINIT_DIR"
    command chmod g-rwX "$ZINIT_DIR"
    command git clone https://github.com/zdharma-continuum/zinit "$ZINIT_HOME" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "${ZINIT_HOME}/zinit.zsh"

zinit ice wait lucid
zinit for \
  light-mode agkozak/zsh-z \
  light-mode zsh-users/zsh-autosuggestions \
  light-mode zsh-users/zsh-completions \
  light-mode zdharma-continuum/history-search-multi-word \  # Ctrl-R activate
  light-mode zsh-users/zsh-history-substring-search

zinit ice wait lucid
zstyle :plugin:history-search-multi-word reset-prompt-protect 1
  
# historical backward/forward search with linehead string binded to ^P/^N
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end
bindkey -M emacs '^P' history-substring-search-up
bindkey -M emacs '^N' history-substring-search-down

# Settings
KEYTIMEOUT=1             # 10ms for key sequences
HISTFILE=$HOME/.zsh_history
HISTSIZE=4096
SAVEHIST=4096
setopt hist_ignore_dups   # ignore duplication command history list
setopt hist_ignore_space  # ignore when commands starts with space
setopt inc_append_history # append history list to the history file
setopt share_history      # share command history data (important for multiple parallel zsh sessions!)

# Exports
export VISUAL=nvim
export EDITOR=$VISUAL
export LANG=en_GB.UTF-8
export BROWSER=firefox
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export KERL_CONFIGURE_OPTIONS='--without-javac --without-odbc'
export KERL_BUILD_DOCS='yes'
export KERL_DOC_TARGETS='chunks'
export ERL_AFLAGS='-kernel shell_history enabled'
export PGDATABASE='mgp_dev' # frequently used database
export MANPAGER='nvim +Man!'
export PATH=$HOME/Downloads/android-sdk/android-studio:$PATH # $HOME/.cargo/bin:$PATH
export FZF_DEFAULT_COMMAND='rg --files --follow'
export FZF_DEFAULT_OPTS='--reverse'
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
alias ls='ls --color=auto'
alias e="exa --long --git --header --sort=type"
alias et="exa -T"
alias g="lazygit"
alias gd="git diff"
alias gs="git status"
alias gl="git log --oneline --decorate -20"
alias gla="git log --oneline --decorate --graph --all"
alias commit="git add -A; git commit -m"
alias nvimrc="$EDITOR ~/dotfiles/init.lua"
alias weather="curl wttr.in"
alias pac="pacman"
alias paci="sudo pacman --sync"
alias pacx="sudo pacman --remove"
alias pacX="sudo pacman --remove --nosave --recursive"
alias pacq="pacman --sync --info"
alias pacQ="pacman --query --info"
alias pacs="pacman --sync --search"
alias pacS="pacman --query --search"
alias pacman-list-orphans="sudo pacman --query --deps --unrequired"
alias pacman-remove-orphans="sudo pacman --remove --recursive \$(pacman --quiet --query --deps --unrequired)"
alias pacU="sudo pacman --sync --refresh --sysupgrade"
# confirm before overwriting something
alias cp="cp -i"
alias mv='mv -i'
alias rm='rm -i'
# easier to read disk
alias df='df -h'     # human-readable sizes
# get top process eating memory
alias psmem='ps auxf | sort -nr -k 4 | head -5'
# get top process eating cpu ##
alias pscpu='ps auxf | sort -nr -k 3 | head -5'
# systemd
alias mach_list_systemctl="systemctl list-unit-files --state=enabled"

# asdf
. $HOME/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath) # append completions to fpath
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit
eval "$(starship init zsh)"
