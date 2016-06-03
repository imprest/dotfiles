call plug#begin('~/.config/nvim/plugged')

" colorschemes
Plug 'morhetz/gruvbox'
Plug 'ryanoasis/vim-devicons'

" general
Plug 'ervandew/supertab'
Plug 'benekastah/neomake'
Plug 'Shougo/deoplete.nvim'
Plug 'Shougo/neosnippet-snippets'
Plug 'Shougo/neosnippet.vim'
Plug 'mhinz/vim-startify'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'haya14busa/incsearch.vim'
Plug 'kien/ctrlp.vim'
Plug 'Yggdroot/indentLine'
Plug 'majutsushi/tagbar'

" Project Management
Plug 'airblade/vim-rooter'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }

" editing
Plug 'junegunn/vim-easy-align', { 'on': ['<Plug>(EasyAlign)', 'EasyAlign']}
Plug 'mbbill/undotree',         { 'on': 'UndotreeToggle' }
Plug 'tpope/vim-commentary'
Plug 'airblade/vim-gitgutter'
Plug 'nathanaelkane/vim-indent-guides' " `,ig` to toggle
Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'justinmk/vim-sneak'
Plug 'vim-scripts/camelcasemotion'

" searching
Plug 'junegunn/vim-pseudocl'
Plug 'junegunn/vim-oblique'

" git
Plug 'tpope/vim-fugitive'
Plug 'junegunn/gv.vim'

" eye candy
Plug 'myusuf3/numbers.vim'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'lilydjwg/colorizer', { 'on': 'ColorToggle' }

" javascript
Plug 'guileen/vim-node-dict'
Plug 'moll/vim-node'
Plug 'othree/yajs.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug '1995eaton/vim-better-javascript-completion'
Plug 'marijnh/tern_for_vim', { 'do': 'npm install' }
Plug 'digitaltoad/vim-jade'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'

" typescript
Plug 'leafgarland/typescript-vim'
Plug 'jason0x43/vim-js-indent'

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript'] }
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript'] }
Plug 'othree/html5.vim', { 'for': ['html', 'javascript'] }

" CSS
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss']}
Plug 'othree/csscomplete.vim'

" Elixir & Erlang
Plug 'tpope/vim-endwise'
Plug 'elixir-lang/vim-elixir'
Plug 'jimenezrick/vimerl'
Plug 'mattreduce/vim-mix'
Plug 'thinca/vim-ref'
Plug 'slashmili/alchemist.vim'

" text objects
Plug 'wellle/targets.vim'
Plug 'kana/vim-textobj-user'
Plug 'glts/vim-textobj-comment'
Plug 'kana/vim-textobj-fold'
Plug 'kana/vim-textobj-indent'
Plug 'kana/vim-textobj-function'

" Markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

call plug#end()

" Settings
let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1
let $NVIM_TUI_ENABLE_TRUE_COLOR   = 1
set background=dark
colorscheme gruvbox

set number
set complete-=i
set nrformats-=octal
set conceallevel=1
set listchars+=tab:>\ ,trail:-,extends:❯,precedes:❮,conceal:Δ,nbsp:+
set scrolloff=7
set sidescrolloff=5
set lazyredraw
set noshowmode
set laststatus=2
set showtabline=2
set cmdheight=1
set display+=lastline

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

" searching
set ignorecase
set smartcase

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
set undofile
set undolevels=1000
set undoreload=1000

" Keyboard mappings
let g:mapleader = ','
" common actions
nnoremap <Leader>q :q<CR>
nnoremap <Leader>d :bdelete<CR>
nnoremap ; :
nnoremap Q @q
nnoremap <C-s> :<C-u>w<CR>
vnoremap <C-s> :<C-u>w<CR>
cnoremap <C-s> <C-u>w<CR>
" Navigation made easy
noremap H ^
noremap L g_
" Navigation between display lines
noremap <silent> <Up>   gk
noremap <silent> <Down> gj
noremap <silent> k gk
noremap <silent> j gj
noremap <silent> <Home> g<Home>
noremap <silent> <End>  g<End>
inoremap <silent> <Home> <C-o>g<Home>
inoremap <silent> <End> <C-o>g<End>
" smash escape insert mode
inoremap jk <esc>
inoremap kj <esc>
" buffer keys
nnoremap <Leader>bb :b#<CR>
nnoremap <Leader>bn :bn<CR>
nnoremap <Leader>bp :bp<CR>
nnoremap <Leader>bf :bf<CR>
nnoremap <Leader>bl :bl<CR>
nnoremap <Leader>bw :w<CR>:bd<CR>
nnoremap <Leader>bd :bd!<CR>
" quickly move between open buffers
nnoremap <Right> :bnext<CR>
nnoremap <Left>  :bprev<CR>
" window keys
nnoremap <M-Right> :vertical resize -1<CR>
nnoremap <M-Up>    :resize -1<CR>
nnoremap <M-Down>  :resize +1<CR>
nnoremap <M-Left>  :vertical resize +1<CR>
nnoremap <Leader>s  :split<CR>
nnoremap <Leader>v  <C-w>v<C-w>l
nnoremap <Leader>x  :close<CR>
" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv
" make Y consistent with C & D
nnoremap Y y$
" toggle highlight search
nnoremap <BS> :set hlsearch! hlsearch?<CR>
" Map ctrl-movement keys to window switching
map <silent> <C-h> <C-w>h
map <silent> <C-j> <C-w>j
map <silent> <C-k> <C-w>k
map <silent> <C-l> <C-w>l
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
" indent whole file according to syntax rules
noremap <F9> gg=G<C-o><C-o>
" start interactive EasyAlign in visual mode
vmap <Enter> <Plug>(EasyAlign)
" neomake
nmap <Leader><Space>o :lopen<CR>
nmap <Leader><Space>c :lclose<CR>
nmap <Leader><Space>, :ll<CR>
nmap <Leader><Space>n :lnext<CR>
nmap <Leader><Space>p :lprev<CR>
" colorizer
nmap <Leader>C :ColorToggle<CR>
" tern
autocmd FileType javascript nnoremap <silent> <buffer> gb :TernDef<CR>
" Tagbar
nmap <F8> :TagbarToggle<CR>
" Move cursor to middle after each search
autocmd! User Oblique       normal! zz
autocmd! User ObliqueStar   normal! zz
autocmd! User ObliqueRepeat normal! zz

" Plugin Configurations
" Relative Numbers
let g:enable_numbers = 0
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
" Neomake
let g:neomake_javascript_enabled_makers = ['tsc']
let g:neomake_warning_sign = {
      \ 'text': 'W',
      \ 'texthl': 'WarningMsg',
      \ }
let g:neomake_error_sign = {
      \ 'text': 'E',
      \ 'texthl': 'ErrorMsg',
      \ }
" Typescript
let g:typescript_indent_disable = 1
" let g:tsuquyomi_completion_detail = 1
" CtrlP
let g:ctrlp_reuse_window='startify'
let g:ctrlp_extensions=['funky']
let g:ctrlp_custom_ignore = { 'dir': '\v[\/]\.(git|hg|svn)$' }
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*node_modules*,*.jpg,*.png,*.svg,*.ttf,*.woff,*.woff3,*.eot,*public/css/*,*public/js
nnoremap <Leader>o :CtrlP<CR>
noremap  <Leader>r :CtrlPMRUFiles<CR>
nnoremap <Leader>l :CtrlPLine<CR>
nnoremap <Leader>t :CtrlPTag<CR>
nnoremap <Leader>b :CtrlPBuffer<CR>
" tern
if exists('g:plugs["tern_for_vim"]')
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript setlocal omnifunc=tern#Complete
endif
" enable matchit (for matching tags with %)
runtime macros/matchit.vim
" Airline options
let g:airline_powerline_fonts     = 1
let g:airline_detect_paste        = 1
let g:airline_skip_empty_sections = 1
let g:airline_theme               = 'bubblegum'
let g:airline_extensions = ['branch', 'tabline']
let g:airline#extensions#branch#enabled          = 1
let g:airline#extensions#tabline#enabled         = 1
let g:airline#extensions#tabline#left_sep        = ''
let g:airline#extensions#tabline#left_alt_sep    = '¦'
let g:airline#extensions#tabline#buffer_idx_mode = 1
let airline#extensions#tabline#ignore_bufadd_pat = '\c\vgundo|undotree|vimfiler|tagbar|nerd_tree|zsh'
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
" IndentLine
let g:indentLine_enabled = 1
" let g:indentLine_char    = '┆'
let g:indentLine_char    = "\u250A"
" NERDTree
map <F2> :NERDTreeToggle<CR>
let NERDTreeIgnore = ['\.git','\.hg','\.npm','\node_modules','\.rebar']
"set timeout
set timeoutlen=1000
"set ttimeout
set ttimeoutlen=50
"Emmet settings
let g:user__install_global = 0
autocmd FileType html,css EmmetInstall

" Auto Commands
augroup vimrc
  au!

  " Trim whitespace onsave
  autocmd BufWritePre * %s/\s\+$//e

  " Jump to last known position of cursor in file
  autocmd BufReadPost *
        \ if line("'\"") > 0 && line ("'\"") <= line("$") |
        \   exe 'normal! g`"zvzz' |
        \ endif

  " For terminal start in insert mode
  au BufEnter * if &buftype == 'terminal' | :startinsert | endif
augroup END
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
autocmd FileType scss noremap <buffer> <c-f> :call CSSBeautify()<cr>

