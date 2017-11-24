" vim-plug (https://github.com/junegunn/vim-plug) settings
" Automatically install vim-plug and run PlugInstall if vim-plug not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

call plug#begin('~/.config/nvim/plugged')

" general
let g:mapleader = ','
Plug 'dietsche/vim-lastplace'
Plug 'mhinz/vim-startify'
  let g:startify_session_dir = '~/.data/sessions'
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1

" Autocompletion
Plug 'ervandew/supertab'
  let g:SuperTabDefaultCompletionType = "<c-n>"
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
  inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"
  let g:deoplete#enable_at_startup = 1
  let g:deoplete#omni#input_patterns = {}
  autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
  " Completion
  set completeopt=longest,menu " preview
  set omnifunc=syntaxcomplete#Complete
  augroup omnifuncs
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
  augroup end
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <C-k>     <Plug>(neosnippet_expand_or_jump)
  xmap <C-k>     <Plug>(neosnippet_expand_target)
  " SuperTab like snippets behavior.
  " Note: It must be "imap" and "smap".  It uses <Plug> mappings.
  imap <C-k>     <Plug>(neosnippet_expand_or_jump)
  smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
        \ "\<Plug>(neosnippet_expand_or_jump)" : "\<TAB>"
  set conceallevel=2 concealcursor=niv

" Linter. Execute code checks, find mistakes, in the background
Plug 'w0rp/ale'
  let g:ale_sign_error           = '✘'
  let g:ale_sign_warning         = '!'
  let g:ale_lint_on_text_changed = 'never'
  let g:ale_lint_on_enter        = 0
  let g:ale_linters              = {'elixir': ['credo'], 'javascript': ['eslint']}
  let g:ale_fixers               = {'javascript': ['eslint']}
  let g:ale_javascript_eslint_use_global = 1

" Project Management
Plug 'airblade/vim-rooter'
  let g:rooter_silent_chdir = 1
  let g:rooter_patterns = ['mix.exs', '.git/', 'package.json']
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
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

" Editing
Plug 'Raimondi/delimitMate'  " Automatically add closing quotes and braces
  au FileType vue let b:delimitMate_matchpairs = "(:),[:],{:}" " disable <> in vue
Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign']}
Plug 'junegunn/vim-peekaboo' " Show recently saved text in vim registers
Plug 'tpope/vim-commentary'  " gc i.e. toggle commenting code
Plug 'tpope/vim-repeat'      " allow added vim motion to be repeatable like vim-surround
Plug 'tpope/vim-speeddating' " <C-a> in numbers or dates <C-x> to do the opposite
Plug 'tpope/vim-surround'    " cs i.e. enable change surrounding motion
Plug 'terryma/vim-expand-region' " hit v repeatable to select surrounding
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
Plug 'chrisbra/unicode.vim'  " :UnicodeTable to search and copy unicode chars

" Folding
" Plug 'sts10/vim-zipper' " for folding
set nofoldenable
set fillchars=fold:\ , " get rid of '-' characters in folds

" Navigation
Plug 'justinmk/vim-gtfo'    " ,gof open file in filemanager
Plug 'majutsushi/tagbar'    " F9 to Toggle tabbar window
  nmap <F9> :TagbarToggle<CR>
Plug 'wesQ3/vim-windowswap' " <Leader>ww once to select window and again to swap window
Plug 'milkypostman/vim-togglelist' " <leader>l & q for location and quick list
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
  let g:fzf_layout = { 'down': '~21%' }
  let g:fzf_colors =
        \ { 'fg':      ['fg', 'Normal'],
        \   'bg':      ['bg', 'Normal'],
        \   'hl':      ['fg', 'Comment'],
        \   'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
        \   'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
        \   'hl+':     ['fg', 'Statement'],
        \   'info':    ['fg', 'PreProc'],
        \   'prompt':  ['fg', 'Conditional'],
        \   'pointer': ['fg', 'Exception'],
        \   'marker':  ['fg', 'Keyword'],
        \   'spinner': ['fg', 'Label'],
        \   'header':  ['fg', 'Comment'] }
  nnoremap <c-p>      :GFiles<CR>
  nnoremap <Leader>p  :Files<CR>
  noremap  <Leader>r  :History<CR>
  nnoremap <Leader>bt :BTags<CR>
  nnoremap <Leader>T  :Tags<CR>
  nnoremap <Leader>b  :Buffers<CR>

" Searching
Plug 'rking/ag.vim'
Plug 'Chun-Yang/vim-action-ag'
Plug 'osyo-manga/vim-anzu'
  nmap n <Plug>(anzu-n)
  nmap N <Plug>(anzu-N)
  nmap * <Plug>(anzu-star)
  nmap # <Plug>(anzu-sharp)
  nmap <Esc><Esc> <Plug>(anzu-clear-search-status)

" Git
Plug 'airblade/vim-gitgutter'
Plug 'junegunn/gv.vim'
Plug 'tpope/vim-fugitive'

" Vue & Javascript
Plug 'posva/vim-vue'
Plug 'carlitux/deoplete-ternjs' ", { 'do': 'sudo npm install -g tern' }
  let g:deoplete#sources#ternjs#filetypes = ['vue']
Plug '1995eaton/vim-better-javascript-completion'
Plug 'elzr/vim-json'
Plug 'othree/javascript-libraries-syntax.vim'
  let g:used_javascript_libs = 'vue'
  autocmd BufReadPre *.vue let b:javascript_lib_use_vue = 1
Plug 'othree/yajs.vim'

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript', 'vue'] }
Plug 'othree/html5.vim',    { 'for': ['html', 'javascript', 'vue']}
Plug 'alvan/vim-closetag'
  let g:closetag_filenames = '*.html, *.xhtml, *.vue'

" CSS
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss', 'vue']}
Plug 'othree/csscomplete.vim'

" Elixir & Erlang
Plug 'elixir-lang/vim-elixir'
Plug 'jimenezrick/vimerl'
Plug 'slashmili/alchemist.vim'
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'tpope/vim-endwise'
Plug 'ludovicchabant/vim-gutentags' " Easily manage tags files
  let g:gutentags_cache_dir = '~/.tags_cache'
Plug 'janko-m/vim-test'
  let g:test#strategy = 'neovim' "run tests in neovim strategy
Plug 'kassio/neoterm'
  set shell=/usr/bin/fish
  set noshelltemp " use pipes
  let g:neoterm_position = 'horizontal'
  let g:neoterm_automap_keys = ',tt'
  nnoremap <silent> ,th :call neoterm#close()<CR>
  nnoremap <silent> ,tl :call neoterm#clear()<CR>
  nnoremap <silent> ,tc :call neoterm#kill()<CR>
  nnoremap <Leader>c :below 10sp term://fish<CR>

" text objects
Plug 'glts/vim-textobj-comment'
Plug 'kana/vim-textobj-fold'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-user'
Plug 'wellle/targets.vim'

" Markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

" Eye candy
Plug 'lilydjwg/colorizer', { 'on': 'ColorToggle' }
  nmap <F5> :ColorToggle<CR>
Plug 'terryma/vim-smooth-scroll' " Ctrl-e and Ctrl-d to scroll up/down
  nnoremap <C-e> <C-u>
  nnoremap <C-u> <C-e>
  noremap <silent> <c-e> :call smooth_scroll#up(&scroll, 15, 2)<CR>
  noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>
  noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
  noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>
Plug 'Yggdroot/indentLine'
  let g:indentLine_enabled = 1
  let g:indentLine_char    = "\u250A" " '┆'
  let g:indent_guides_start_level = 1
  let g:indent_guides_guide_size = 1
  let g:indent_guides_enable_on_vim_startup = 0
  let g:indent_guides_color_change_percent = 3
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
  let g:airline_powerline_fonts     = 1
  let g:airline_detect_paste        = 1
  let g:airline_skip_empty_sections = 1
  let g:airline_left_sep            = ''
  let g:airline_right_sep           = ''
  let g:airline_skip_empty_sections = 1
  let g:airline_theme               = 'onedark'
  let g:airline#extensions#branch#enabled          = 1
  let g:airline#extensions#tabline#enabled         = 1
  let g:airline#extensions#tabline#left_alt_sep    = '|'
  let airline#extensions#tabline#ignore_bufadd_pat = '\c\vgundo|undotree|vimfiler|tagbar|nerd_tree'
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

" Colorschemes
Plug 'joshdick/onedark.vim'

call plug#end()

" Neovim Settings
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
set mouse=a
set termguicolors " Enable 24-bit colors in supported terminals
set background=dark
let g:onedark_allow_italics = 1
colorscheme onedark

" tab stuff
set tabstop=2
set softtabstop=2
set shiftwidth=2
set expandtab
set smartindent

" ui options
set title
set showmatch
set matchtime=2
set number
set lazyredraw
set noshowmode
set t_ut= " improve screen clearing by using the background colour
" alternative approach for lines that are too long
set colorcolumn=
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" autocomplete list options
set wildmode=list:full " show similar and all options
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

" whitespace, hidden characters & line breaks
set list      " Toggle showing hidden characters i.e. space
set linebreak " Wrap long lines at a character
set listchars+=tab:»·,trail:•,extends:❯,precedes:❮,conceal:Δ,nbsp:+
let &showbreak="↪ "

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
" common actions
nnoremap <Leader>d :bdelete<CR>
nnoremap <Leader><Leader> <c-^> " Swith between last two files
nnoremap Q @q                   " Use Q to execute default register
nnoremap <C-s> :<C-u>w<CR>      " Ctrl-S to save in most modes
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
" smash escape
inoremap jk <esc>
inoremap kj <esc>
" quickly move between open buffers
nnoremap <Right> :bnext<CR>
nnoremap <Left>  :bprev<CR>
" window keys
nnoremap <M-Right> :vertical resize -1<CR>
nnoremap <M-Up>    :resize +1<CR>
nnoremap <M-Down>  :resize -1<CR>
nnoremap <M-Left>  :vertical resize +1<CR>
nnoremap <C-Right> :vertical resize -5<CR>
nnoremap <C-Down>    :resize +5<CR>
nnoremap <C-Up>  :resize -5<CR>
nnoremap <C-Left>  :vertical resize +5<CR>
nnoremap <Leader>s :split<CR>
nnoremap <Leader>v <C-w>v<C-w>l
nnoremap <Leader>x :call CloseWindowOrKillBuffer()<CR>
" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv
" make Y consistent with C & D
nnoremap Y y$
" toggle highlight search
nnoremap <BS> :set hlsearch! hlsearch?<CR>
" Map ctrl-movement keys to window switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
" quickly replace string under cursor for line
nnoremap <Leader>R :s/\<<C-r><C-w>\>/
" Sort selected lines
vmap <Leader>s :sort<CR>
" start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)
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
" enable matchit (for matching tags with %)
let g:loaded_matchparen = 1
runtime macros/matchit.vim
" Make K or help open in vertical split
autocmd FileType help  wincmd L | vert res 80<CR>
autocmd FileType elixir nnoremap <buffer> <s-k> :call OpenExDoc()<CR>
" Opens alchemist exdoc
function! OpenExDoc()
  :call alchemist#exdoc() | wincmd L | vert res 80
  setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap
  \ modifiable nocursorline nofoldenable
  if exists('&relativenumber')
    setlocal norelativenumber
  endif
endfunction

" Auto Commands
augroup vimrc
  au!

  " Trim whitespace onsave
  autocmd BufWritePre * %s/\s\+$//e

  " For newly started terminal; start in insert mode
  autocmd TermOpen * :startinsert
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

silent call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])

