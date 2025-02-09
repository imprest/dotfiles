# Ref: https://github.com/lpil/lpil/blob/main/dotfiles/home/.config/fish/config.fish
# Terminal
set --export EDITOR "nvim"
set --export TERM xterm
set --export LANG en_GB.UTF-8
set --export BROWSER firefox

# open man pages using nvim as pager
set --export MANPAGER 'nvim +Man!'

# Disable greeting
set fish_greeting

# Postgres config
set --export PGHOST localhost
set --export PGUSER postgres
set --export PGPASSWORD postgres
set --export PGDATABASE 'serp_dev' # common db

# Erlang config
set --export ERL_AFLAGS "-kernel shell_history enabled"

# Erlang installer config
set --export KERL_CONFIGURE_OPTIONS "--without-javac --without-odbc"
set --export KERL_BUILD_DOCS "yes"
set --export KERL_DOC_TARGETS "chunks"

# asdf version manager
source $HOME/.asdf/asdf.fish

# Fzf config
set --export FZF_DEFAULT_COMMAND "rg --files --follow"
set --export FZF_DEFAULT_OPTS "--reverse"
set --export FZF_CTRL_T_COMMAND "rg --files --follow"
set fzf_directory_opts --bind "ctrl-o:execute($EDITOR {} &> /dev/tty)"

# Path
set fish_user_paths \
    "$HOME/.asdf/shims" \
    "$HOME/.cache/rebar3/bin" \
    "$HOME/.cargo/bin" \
    "$HOME/.local/bin" \
    "$HOME/bin"
# Aliases
alias vim="nvim"
alias v="nvim"
alias n="nvim"
alias ls="ls --color=auto"
alias e="eza --long --git --header --sort=type --icons"
alias et="eza -T --icons"
alias g="lazygit"
alias gd="git diff"
alias ga="git add -A; git commit -m"
alias gs="git status"
alias gl="git log --oneline --decorate -20"
alias gla="git log --oneline --decorate --graph --all"
alias nvimrc="$EDITOR ~/dotfiles/init.lua"
alias less='less -R'
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
alias pacman-new-configs='sudo find / -regex /"\(proc\|tmp\|run\)" -prune -o -type f -regex ".*\.pac\(new\|save\|orig\)" -print && echo "sudo nvim -d pacman.conf pacman.conf.new # to audit config changes"'
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

# zoxide
if type -q zoxide
    zoxide init fish | source
end

# Prompt
set __fish_git_prompt_showdirtystate yes
set __fish_git_prompt_showuntrackedfiles yes
set __fish_git_prompt_color_branch green

set __fish_git_prompt_char_dirtystate '*'
set __fish_git_prompt_char_stagedstate '+'
set __fish_git_prompt_char_untrackedfiles '?'

function fish_prompt -d "Write out the prompt"
    set laststatus $status

    if set -q VIRTUAL_ENV
        printf "(%s) " (basename "$VIRTUAL_ENV")
    end

    printf '%s%s %s%s%s%s%s' \
        (set_color green) (echo $USER) \
        (set_color yellow) (echo $PWD | sed -e "s|^$HOME|~|") \
        (set_color white) (__fish_git_prompt) \
        (set_color white)
    if test $laststatus -eq 0
        printf " %s\$ %s" (set_color grey) (set_color normal)
    else
        printf " %s✘ %s\$ %s" (set_color -o red) (set_color grey) (set_color normal)
    end
end

# https://github.com/rust-lang-nursery/rustfmt/issues/1687
if type -q rustc
    set --export LD_LIBRARY_PATH $LD_LIBRARY_PATH:(rustc --print sysroot)/lib
end

function dotenv --description 'Load environment variables from .env file'
    set -l envfile ".env"
    if [ (count $argv) -gt 0 ]
        set envfile $argv[1]
    end

    if test -e $envfile
        for line in (cat $envfile | grep -v "^#" | grep "=")
            set -xg (echo $line | cut -d = -f 1) (echo $line | cut -d = -f 2-)
        end
    end
end

# fo [FUZZY PATTERN] - Open the selected file with the default editor
#   - Bypass fuzzy finder if there's only one match (--select-1)
#   - Exit if there's no match (--exit-0)
function fo 
  set files (fzf-tmux --query=$argv --multi --select-1 --exit-0) 
  if test $status -eq 0; and test -n $files; and test -e $files 
    $EDITOR $files
  end
end
