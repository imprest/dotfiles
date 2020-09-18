### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing %F{33}DHARMA%F{220} Initiative Plugin Manager (%F{33}zdharma/zinit%F{220})…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f%b" || \
        print -P "%F{160}▓▒░ The clone has failed.%f%b"
fi

source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit's installer chunk

zinit load rupa/z
zinit light supercrabtree/k
zinit snippet OMZ::lib/completion.zsh
zinit snippet OMZ::plugins/colored-man-pages
zinit snippet PZT::modules/pacman
zinit ice as"program" atclone"perl Makefile.PL PREFIX=$ZPFX" \
    atpull'%atclone' make'install' pick"$ZPFX/bin/git-cal"
zinit load k4rthik/git-cal
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-autosuggestions
zinit load zdharma/history-search-multi-word # Ctrl-R to activate
zstyle :plugin:history-search-multi-word reset-prompt-protect 1
zinit light denysdovhan/spaceship-prompt
SPACESHIP_CHAR_SYMBOL='λ '
SPACESHIP_PROMPT_ADD_NEWLINE=false
SPACESHIP_PROMPT_SEPARATE_LINE=false
SPACESHIP_ELIXIR_SHOW=false
SPACESHIP_PACKAGE_SHOW=false
SPACESHIP_NODE_SHOW=false
SPACESHIP_EXEC_TIME_SHOW=false
zinit light zsh-users/zsh-history-substring-search

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
export BROWSER=firefox
export LESS='--tabs=4 --no-init --LONG-PROMPT --ignore-case --quit-if-one-screen --RAW-CONTROL-CHARS'
export KERL_CONFIGURE_OPTIONS='--without-javac --without-odbc'
export KERL_BUILD_DOCS='yes'
export KERL_DOC_TARGETS='chunks'
export ERL_AFLAGS='-kernel shell_history enabled'
export PGDATABASE='mgp_dev' # frequently used database
export PATH=$HOME/Downloads/android-sdk/android-studio:$PATH # $HOME/.cargo/bin:$PATH
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
alias gl="git log --oneline --decorate -20"
alias gla="git log --oneline --decorate --graph --all"
alias commit="git add -A; git commit -m"

# asdf
. $HOME/.asdf/asdf.sh
fpath=(${ASDF_DIR}/completions $fpath) # append completions to fpath
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit
