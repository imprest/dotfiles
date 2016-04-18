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
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
Plug 'haya14busa/incsearch.vim'
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/syntastic'

" editing
Plug 'junegunn/vim-easy-align'
Plug 'mbbill/undotree'
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

" eye candy
Plug 'myusuf3/numbers.vim'
Plug 'bling/vim-airline'
Plug 'vim-airline/vim-airline-themes'


" javascript
Plug 'guileen/vim-node-dict'
Plug 'moll/vim-node'
Plug 'othree/yajs.vim'
Plug 'othree/javascript-libraries-syntax.vim'
Plug '1995eaton/vim-better-javascript-completion'
Plug 'gavocanov/vim-js-indent'
Plug 'marijnh/tern_for_vim', { 'do': 'npm install' }
Plug 'digitaltoad/vim-jade'
Plug 'elzr/vim-json'
Plug 'mxw/vim-jsx'

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript'] }
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript'] }
Plug 'othree/html5.vim', { 'for': ['html', 'javascript'] }

" CSS
Plug 'hail2u/vim-css3-syntax', { 'for': ['css', 'scss']}
Plug 'othree/csscomplete.vim'

" Elixir & Erlang
Plug 'elixir-lang/vim-elixir'
Plug 'jimenezrick/vimerl'
Plug 'mattreduce/vim-mix'
Plug 'thinca/vim-ref'
Plug 'awetzel/elixir.nvim'

" Markdown
Plug 'plasticboy/vim-markdown', { 'for': 'markdown' }

call plug#end()

" Settings
set background=dark
colorscheme gruvbox

set tabstop=2
set shiftwidth=2
set expandtab
set smarttab
set number
set conceallevel=1
set listchars+=extends:❯,precedes:❮,conceal:Δ
set scrolloff=5

" searching
set ignorecase
set smartcase

" Auto Commands
" For Gnome-terminal change cursor depending on mode
augroup CURSOR
  au InsertEnter *
        \ if v:insertmode == 'i' |
        \   silent execute "!dconf list /org/gnome/terminal/legacy/profiles:/ | xargs -I '{}' dconf write /org/gnome/terminal/legacy/profiles:/'{}'cursor-shape \"'ibeam'\"" |
        \ elseif v:insertmode == 'r' |
        \   silent execute "!dconf list /org/gnome/terminal/legacy/profiles:/ | xargs -I '{}' dconf write /org/gnome/terminal/legacy/profiles:/'{}'cursor-shape \"'underline'\"" |
        \ endif
  au InsertLeave * silent execute "!dconf list /org/gnome/terminal/legacy/profiles:/ | xargs -I '{}' dconf write /org/gnome/terminal/legacy/profiles:/'{}'cursor-shape \"'block'\""
  au VimLeave * silent execute "!dconf list /org/gnome/terminal/legacy/profiles:/ | xargs -I '{}' dconf write /org/gnome/terminal/legacy/profiles:/'{}'cursor-shape \"'block'\""
augroup END

" Go back to previous position of cursor if any
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

" Keyboard mappings
let g:mapleader = ','
" quickly replace string under cursor
:nnoremap <Leader>s :%s/\<<C-r><C-w>\>/
" common actions
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
" smash escape insert mode
inoremap jk <esc>
inoremap kj <esc>
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
" completion
augroup omnifuncs
  autocmd!
  autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
  autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
  autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
  autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
  autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
augroup end
" CtrlP
let g:ctrlp_reuse_window='startify'
let g:ctrlp_extensions=['funky']
let g:ctrlp_custom_ignore = { 'dir': '\v[\/]\.(git|hg|svn)$' }
nnoremap <Leader>o :CtrlP<CR>
nnoremap <Leader>r :CtrlPMRUFiles<CR>
nnoremap <Leader>l :CtrlPLine<CR>
nnoremap <Leader>t :CtrlPTag<CR>
nnoremap <Leader>b :CtrlPBuffer<CR>
" tern
if exists('g:plugs["tern_for_vim"]')
  let g:tern_show_argument_hints = 'on_hold'
  let g:tern_show_signature_in_pum = 1
  autocmd FileType javascript setlocal omnifunc=tern#Complete
endif
" Airline options
let g:airline_powerline_fonts = 1
let g:airline_left_sep        = ''
let g:airline_right_sep       = ''
let g:airline_theme           = 'bubblegum'
let g:airline#extensions#branch#enabled          = 1
let g:airline#extensions#syntastic#enabled       = 1
let g:airline#extensions#tabline#enabled         = 1
let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <leader>1 <Plug>AirlineSelectTab1
nmap <leader>2 <Plug>AirlineSelectTab2
nmap <leader>3 <Plug>AirlineSelectTab3
nmap <leader>4 <Plug>AirlineSelectTab4
nmap <leader>5 <Plug>AirlineSelectTab5
nmap <leader>6 <Plug>AirlineSelectTab6
nmap <leader>7 <Plug>AirlineSelectTab7
nmap <leader>8 <Plug>AirlineSelectTab8
nmap <leader>9 <Plug>AirlineSelectTab9
" NERDTree
map <F2> :NERDTreeToggle<CR>
"set timeout
set timeoutlen=1000
"set ttimeout
set ttimeoutlen=50
"Emmet settings
let g:user__install_global = 0
autocmd FileType html,css EmmetInstall
"Beautify js, html, css with ctrl-f
map <c-f> :call JsBeautify()<cr>
" or
autocmd FileType javascript noremap <buffer>  <c-f> :call JsBeautify()<cr>
" for html
autocmd FileType html noremap <buffer> <c-f> :call HtmlBeautify()<cr>
" for css or scss
autocmd FileType css noremap <buffer> <c-f> :call CSSBeautify()<cr>
autocmd FileType scss noremap <buffer> <c-f> :call CSSBeautify()<cr>

