" vim-plug (https://github.com/junegunn/vim-plug) settings
" Automatically install vim-plug and run PlugInstall if vim-plug not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

" general
Plug 'mhinz/vim-startify'
Plug 'dietsche/vim-lastplace'

" Autocompleteion
Plug 'ervandew/supertab'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'

" Linter. Execute code checks, find mistakes, in the background
Plug 'neomake/neomake'
  " Run Neomake when I save any buffer
  augroup localneomake
    autocmd! BufWritePost * Neomake
  augroup END
  " Don't tell me to use smartquotes in markdown ok?
  let g:neomake_markdown_enabled_makers = []

  " Configure a nice credo setup, courtesy https://github.com/neomake/neomake/pull/300
  let g:neomake_elixir_enabled_makers = ['mix', 'mycredo']
  function! NeomakeCredoErrorType(entry)
    if a:entry.type ==# 'F'      " Refactoring opportunities
      let l:type = 'W'
    elseif a:entry.type ==# 'D'  " Software design suggestions
      let l:type = 'I'
    elseif a:entry.type ==# 'W'  " Warnings
      let l:type = 'W'
    elseif a:entry.type ==# 'R'  " Readability suggestions
      let l:type = 'I'
    elseif a:entry.type ==# 'C'  " Convention violation
      let l:type = 'W'
    else
      let l:type = 'M'           " Everything else is a message
    endif
    let a:entry.type = l:type
  endfunction

  let g:neomake_elixir_mycredo_maker = {
        \ 'exe': 'mix',
        \ 'args': ['credo', 'list', '%:p', '--format=oneline'],
        \ 'errorformat': '[%t] %. %f:%l:%c %m,[%t] %. %f:%l %m',
        \ 'postprocess': function('NeomakeCredoErrorType')
        \ }

" Project Management
Plug 'airblade/vim-rooter'
Plug 'scrooloose/nerdtree', { 'on':  ['NERDTreeToggle', 'NERDTreeFind'] }

" Editing
Plug 'AndrewRadev/splitjoin.vim'
Plug 'Raimondi/delimitMate'
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign']}
Plug 'junegunn/vim-peekaboo'
Plug 'mbbill/undotree',         { 'on': 'UndotreeToggle' }
Plug 'nathanaelkane/vim-indent-guides' " `,ig` to toggle
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired' " cos : set spelling cox : set cursor con : set number etc
nnoremap coi :IndentLinesToggle
Plug 'vim-scripts/camelcasemotion'
Plug 'terryma/vim-expand-region'
vmap v <Plug>(expand_region_expand)
vmap <C-v> <Plug>(expand_region_shrink)
" Plug 'dhruvasagar/vim-table-mode'
" Plug 'sts10/vim-zipper'
Plug 'chrisbra/unicode.vim'

" Navigation
Plug 'ctrlpvim/ctrlp.vim'
Plug 'justinmk/vim-gtfo'
Plug 'majutsushi/tagbar'
Plug 'christoomey/vim-tmux-navigator'

" Searching
Plug 'osyo-manga/vim-anzu'
Plug 'rking/ag.vim'
Plug 'Chun-Yang/vim-action-ag'

" Git
Plug 'junegunn/gv.vim'
Plug 'tpope/vim-fugitive'

" Javascript
Plug '1995eaton/vim-better-javascript-completion'
Plug 'digitaltoad/vim-jade'
Plug 'elzr/vim-json'
Plug 'guileen/vim-node-dict'
Plug 'marijnh/tern_for_vim', { 'do': 'npm install' }
Plug 'moll/vim-node'
Plug 'mxw/vim-jsx'
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'othree/yajs.vim'

" Typescript
Plug 'jason0x43/vim-js-indent'
Plug 'leafgarland/typescript-vim'
Plug 'Quramy/tsuquyomi'

" Elm
Plug 'lambdatoast/elm.vim'
nnoremap <leader>el :ElmEvalLine<CR>
vnoremap <leader>es :<C-u>ElmEvalSelection<CR>
nnoremap <leader>em :ElmMakeCurrentFile<CR>
augroup elm
  autocmd!
  autocmd BufNewFile,BufRead *.elm setlocal tabstop=4
  autocmd BufNewFile,BufRead *.elm setlocal shiftwidth=4
  autocmd BufNewFile,BufRead *.elm setlocal softtabstop=4
augroup END

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript'] }
Plug 'mattn/emmet-vim',     { 'for': ['html', 'javascript', 'css'] }
Plug 'othree/html5.vim',    { 'for': ['html', 'javascript'] }

" CSS
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss']}
Plug 'othree/csscomplete.vim'

" Elixir & Erlang
Plug 'elixir-lang/vim-elixir', { 'for': ['eelixir', 'elixir']}
Plug 'jimenezrick/vimerl'
Plug 'slashmili/alchemist.vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'tpope/vim-endwise', { 'for': ['elixir']}
Plug 'ludovicchabant/vim-gutentags' " Easily manage tags files
  let g:gutentags_cache_dir = '~/.tags_cache'
Plug 'janko-m/vim-test'
  nmap <silent> <leader>t :TestNearest<CR>
  nmap <silent> <leader>T :TestFile<CR>
  nmap <silent> <leader>a :TestSuite<CR>
  nmap <silent> <leader>l :TestLast<CR>
  nmap <silent> <leader>g :TestVisit<CR>
  " run tests in neovim strategy
  let g:test#strategy = 'neovim'

" text objects
Plug 'glts/vim-textobj-comment'
Plug 'kana/vim-textobj-fold'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-user'
Plug 'wellle/targets.vim'

" Markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Latex
Plug 'lervag/vimtex'

" Eye candy
Plug 'Yggdroot/indentLine'
Plug 'bling/vim-airline'
Plug 'lilydjwg/colorizer', { 'on': 'ColorToggle' }
" Plug 'myusuf3/numbers.vim'
Plug 'terryma/vim-smooth-scroll'
Plug 'vim-airline/vim-airline-themes'

" Colorschemes
Plug 'rakr/vim-one'
Plug 'tomasr/molokai'

call plug#end()

" Neovim Settings
"set cc=80
set numberwidth=5
set ruler
set autoread
set complete-=i
set nrformats-=octal
set laststatus=2
set showtabline=2
set cmdheight=1
set tildeop " Make ~ toggle case for whole line
set clipboard+=unnamedplus " Use system clipboard
set iskeyword+=- " Makes foo-bar considered one word

" Colors
set termguicolors " Enable 24-bit colors in supported terminals
" let g:hybrid_custom_term_colors = 1
" let g:hybrid_reduced_contrast   = 1
set background=dark
"let g:one_allow_italics = 1
"let g:rehash256 = 1   " Molokai theme option
"let ayucolor="dark   " for dark version of theme
colorscheme molokai

" ui options
let $NVIM_TUI_ENABLE_CURSOR_SHAPE=1
set title
set showmatch
set matchtime=2
set number
set lazyredraw
set noshowmode
set t_ut= " improve screen clearing by using the background colour

" autocomplete list options
set wildmode=longest,list,full " show similar and all options
set wildignorecase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/tmp/*,*.so,*.swp,*.zip,*node_modules*,*.jpg,*.png,*.svg,*.ttf,*.woff,*.woff3,*.eot,*public/css/*,*public/js
set timeoutlen=300 " mapping timeout
set ttimeoutlen=10 " keycode timeout

" Split window behaviour
set splitbelow
set splitright

" disable error sounds
set noerrorbells
set novisualbell
set t_vb=

" scroll options
set scrolloff=7
set sidescrolloff=5
set display+=lastline

" whitespace & hidden characters
set nowrap
set list      " Toggle showing hidden characters i.e. space
set listchars+=tab:»·,trail:•,extends:❯,precedes:❮,conceal:Δ,nbsp:+
set conceallevel=1
set concealcursor=i
set breakindent " Wrap lines will be indented
set linebreak   " Wrap long lines at a character
let &showbreak="↪ "

" tab stuff
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smarttab
set autoindent
set smartindent

" fold stuff
set nofoldenable
set fillchars=fold:\ , " get rid of '-' characters in folds

" searching
set ignorecase smartcase
set smartcase
let g:ag_working_path_mode="r"
if executable('ag')
  let g:ackprg = "ag --nogroup --column --smart-case --follow"
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
endif

" tags
set tags=tags;/
set showfulltag
" tagbar elixir support
let g:tagbar_type_elixir = {
      \ 'ctagstype' : 'elixir',
      \ 'kinds' : [
      \ 'f:functions',
      \ 'functions:functions',
      \ 'c:callbacks',
      \ 'd:delegates',
      \ 'e:exceptions',
      \ 'i:implementations',
      \ 'a:macros',
      \ 'o:operators',
      \ 'm:modules',
      \ 'p:protocols',
      \ 'r:records'
      \ ]
      \ }

" shell
set shell=/usr/bin/zsh
set noshelltemp " use pipes

" backup, undo and file management
set backup
let g:data_dir = $HOME . '/.data/'
let g:backup_dir = g:data_dir . 'backup'
let g:swap_dir = g:data_dir . 'swap'
let g:undo_dir = g:data_dir . 'undofile'
if finddir(g:data_dir) == ''
  silent call mkdir(g:data_dir)
endif
if finddir(g:backup_dir) == ''
  silent call mkdir(g:backup_dir)
endif
if finddir(g:swap_dir) == ''
  silent call mkdir(g:swap_dir)
endif
if finddir(g:undo_dir) == ''
  silent call mkdir(g:undo_dir)
endif
unlet g:backup_dir
unlet g:swap_dir
unlet g:data_dir
unlet g:undo_dir
set undodir=$HOME/.data/undofile
set backupdir=$HOME/.data/backup
set directory=$HOME/.data/swap
set noswapfile
set undofile
set undolevels=1000
set undoreload=1000

" Functions
function! CloseWindowOrKillBuffer()
  let number_of_windows_to_this_buffer = len(filter(range(1, winnr('$')), "winbufnr(v:val) == bufnr('%')"))

  " never bdelete a nerd tree
  if matchstr(expand("%"), 'NERD') == 'NERD'
    wincmd c
    return
  endif

  if number_of_windows_to_this_buffer > 1
    wincmd c
  else
    bdelete
  endif
endfunction

" Keyboard mappings
let g:mapleader = ','
" common actions
nnoremap <Leader>q :q<CR>
nnoremap <Leader>d :bdelete<CR>
nnoremap <Leader><Leader> <c-^> " Swith between last two files
" nnoremap ; :               " Use ; for commands X Conflicts with sneak
nnoremap Q @q              " Use Q to execute default register
nnoremap <C-s> :<C-u>w<CR> " Ctrl-S to save in most modes
vnoremap <C-s> :<C-u>w<CR>
cnoremap <C-s> <C-u>w<CR>
" Navigation made easy
noremap H ^
noremap L g_
noremap F %
vnoremap L g_
" Navigation between display lines
noremap <silent> <Up>   gk
noremap <silent> <Down> gj
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> <Home> g<Home>
noremap <silent> <End>  g<End>
inoremap <silent> <Home> <C-o>g<Home>
inoremap <silent> <End> <C-o>g<End>
" smooth scrolling
nnoremap <C-e> <C-u>
nnoremap <C-u> <C-e>
noremap <silent> <c-e> :call smooth_scroll#up(&scroll, 15, 2)<CR>
noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>
noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>
" smash escape
inoremap jk <esc>
inoremap kj <esc>
" quickly move between open buffers
nnoremap <Right> :bnext<CR>
nnoremap <Left>  :bprev<CR>
" window keys
nnoremap <M-Left>  :vertical resize -1<CR>
nnoremap <M-Up>    :resize -1<CR>
nnoremap <M-Down>  :resize +1<CR>
nnoremap <M-Right> :vertical resize +1<CR>
nnoremap <Leader>s :split<CR>
nnoremap <Leader>v <C-w>v<C-w>l
nnoremap <Leader>x :call CloseWindowOrKillBuffer()<CR>
" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv
" make Y consistent with C & D
nnoremap Y y$
" Map ctrl-movement keys to window switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
nnoremap <silent> <BS> :TmuxNavigateLeft<cr> " Hack for neovim tmux issue
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
" Open terminal below
nnoremap <Leader>c :below 10sp term://zsh<CR>
" quickly replace string under cursor for line
nnoremap <Leader>R :s/\<<C-r><C-w>\>/
" Sort selected lines
vmap <Leader>s :sort<CR>
" start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)
" colorizer
nmap <F5> :ColorToggle<CR>
" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
" Tagbar
nmap <F9> :TagbarToggle<CR>
" Move cursor to middle after each search i.e. auto-center
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz
" reselect last paste
noremap gV `[v`]
" find current word in quickfix
nnoremap <Leader>fw :execute "vimgrep ".expand("<cword>")." %"<CR>:copen<cr>
" find last search in quickfix
nnoremap <Leader>ff :execute 'vimgrep /'.@/.'/g %'<CR>:copen<cr>
" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Make K or help open in vertical split
" nnoremap K :vsp <CR>:execute(expand(&keywordprg).' '.expand("<cword>"))<CR>
autocmd FileType help  wincmd L | vert
autocmd FileType ExDoc wincmd L | vert

" Plugin Configurations
" SuperTab
let g:SuperTabDefaultCompletionType = "<c-n>"
" Deoplete
let g:deoplete#enable_at_startup = 1
let g:deoplete#disable_auto_complete = 0
autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
if !exists('g:deoplete#omni#input_patterns')
  let g:deoplete#omni#input_patterns = {}
endif
" Completion
set completeopt=longest,menu " preview
set omnifunc=syntaxcomplete#Complete
augroup omnifuncs
  autocmd!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  autocmd FileType typescript setlocal completeopt-=menu
augroup end
" Rooter
let g:rooter_silent_chdir = 1
let g:rooter_patterns = ['mix.exs', '.git/', 'package.json']
" Peekaboo
let g:peekaboo_window = 'vertical botright 50new'

"" Typescript
" Disable leafgarland/typescript indenting and use jason0x43/vim-js-indent
let g:typescript_indent_disable = 1
" let g:tsuquyomi_completion_detail = 1

" Vim-Startify
let g:startify_session_dir = '~/.data/sessions'
let g:startify_change_to_vcs_root = 1
let g:startify_show_sessions = 1

" CtrlP
let g:ctrlp_reuse_window='startify'
let g:ctrlp_extensions=['funky']
let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s' " Use ag
let g:ctrlp_custom_ignore = { 'dir': '\v[\/]\.(git|hg|svn)$' }
nnoremap <Leader>o :CtrlP<CR>
noremap  <Leader>r :CtrlPMRUFiles<CR>
nnoremap <Leader>l :CtrlPLine<CR>
nnoremap <Leader>t :CtrlPBufTag<CR>
nnoremap <Leader>T :CtrlPTag<CR>
nnoremap <Leader>bp :CtrlPBuffer<CR>
" tern
if exists('g:plugs["tern_for_vim"]')
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript setlocal omnifunc=tern#Complete
endif
" enable matchit (for matching tags with %)
let g:loaded_matchparen = 1
runtime macros/matchit.vim
" Anzu
nmap n <Plug>(anzu-n)
nmap N <Plug>(anzu-N)
nmap * <Plug>(anzu-star)
nmap # <Plug>(anzu-sharp)
nmap <Esc><Esc> <Plug>(anzu-clear-search-status)

" Airline options
let g:airline_powerline_fonts     = 1
let g:airline_detect_paste        = 1
let g:airline_skip_empty_sections = 1
let g:airline_left_sep            = ''
let g:airline_right_sep           = ''
let g:airline_skip_empty_sections = 1
let g:airline_theme               = 'molokai'
let g:airline_extensions = ['branch', 'tabline', 'quickfix', 'ctrlp', 'tagbar', 'hunks', 'anzu', 'neomake', 'whitespace']
let g:airline#extensions#branch#enabled          = 1
let g:airline#extensions#tabline#enabled         = 1
let g:airline#extensions#tabline#left_alt_sep    = '|'
let g:airline#extensions#tabline#fnamemod        = ':t'
let airline#extensions#tabline#ignore_bufadd_pat = '\c\vgundo|undotree|vimfiler|tagbar|nerd_tree|zsh|*:zsh'
call airline#parts#define_raw('linenr', '%l')
"call airline#parts#define_accent('linenr', 'bold')
let g:airline_section_z = airline#section#create(['%3p%% ',
      \ g:airline_symbols.linenr .' ', 'linenr', ':%2c'])
let g:airline_mode_map = {
    \ '__' : '-',
    \ 'n'  : 'N',
    \ 'i'  : 'I',
    \ 'R'  : 'R',
    \ 'c'  : 'C',
    \ 'v'  : 'V',
    \ 'V'  : 'V',
    \ '' : 'V',
    \ 's'  : 'S',
    \ 'S'  : 'S',
    \ '' : 'S',
    \ }

" IndentLine
let g:indentLine_enabled = 0
let g:indentLine_char    = "\u250A" " '┆'
let g:indent_guides_start_level = 1
let g:indent_guides_guide_size = 1
let g:indent_guides_enable_on_vim_startup = 0
let g:indent_guides_color_change_percent = 3

" NERDTree
map <C-\> :NERDTreeToggle<CR>
map <F2>  :NERDTreeToggle<CR>
map <F3>  :NERDTreeFind<CR>
let NERDTreeIgnore = ['\.git','\.hg','\.npm','\node_modules','\.rebar']
augroup nerd_loader
  autocmd!
  autocmd VimEnter * silent! autocmd! FileExplorer
  autocmd BufEnter,BufNew *
        \  if isdirectory(expand('<amatch>'))
        \|   call plug#load('nerdtree')
        \|   execute 'autocmd! nerd_loader'
        \| endif
augroup END
"Emmet settings
let g:user_emmet_install_global = 0
autocmd FileType html,css EmmetInstall

" Auto Commands
augroup vimrc
  au!

  " Trim whitespace onsave
  autocmd BufWritePre * %s/\s\+$//e

  " For terminal start in insert mode
  au BufEnter * if &buftype == 'terminal' | :startinsert | endif
augroup END

augroup MyFileTypes
  au!
  au filetype vim setlocal fdm=indent keywordprg=:help

  " Help System Speedups
  autocmd filetype help nnoremap <buffer><cr> <c-]>
  autocmd filetype help nnoremap <buffer><bs> <c-T>
  autocmd filetype help nnoremap <buffer>q :q<CR>

  autocmd filetype qf setlocal wrap
augroup END

augroup markdown
  au!
  au FileType markdown setlocal textwidth=80
  au FileType markdown setlocal formatoptions=tcrq
augroup END

