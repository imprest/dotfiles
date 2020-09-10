" Setup stolen mainly from https://github.com/Arkham/vimfiles

" vim-plug (https://github.com/junegunn/vim-plug) settings
" Automatically install vim-plug and run PlugInstall if vim-plug not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

let g:loaded_python_provider = 1
let g:python3_host_prog = '/usr/bin/python3'
let mapleader = ","

"" PLUGIN MANAGEMENT {{{
call plug#begin('~/.config/nvim/plugged')

" Autocomplete & Snippets
Plug 'ervandew/supertab'
  let g:SuperTabDefaultCompletionType = "<c-n>"
Plug 'nvim-lua/completion-nvim'
Plug 'steelsojka/completion-buffers'
Plug 'kristijanhusak/vim-dadbod-completion'
Plug 'SirVer/ultisnips'
Plug 'honza/vim-snippets'
  let g:completion_enable_snippet = "UltiSnips"
  let g:completion_trigger_keyword_length = 2
  let g:completion_matching_strategy_list=['exact', 'substring', 'fuzzy']
  set completeopt=menuone,noinsert,noselect " Set completeopt to have a better completion experience
  set shortmess+=c                          " Avoid showing extra message when using completion
  "" Configure the completion chains
  let g:completion_chain_complete_list = {
        \'default' : {
        \ 'default' : [
        \  {'complete_items' : ['lsp', 'snippet', 'buffers']},
        \  {'mode' : 'file'}, {'mode' : '<c-p>' }, { 'mode' : '<c-n>' },
        \ ],
        \ 'comment' : [ {'complete_items' : ['buffer'] }],
        \ 'string' : [ {'complete_items' : ['buffer'] }],
        \ },
        \'vim' : [
        \ {'complete_items': ['snippet', 'buffer', 'buffers']},
        \ {'mode' : 'cmd'}
        \ ],
        \'sql': [
        \ {'complete_items': ['vim-dadbod-completion']},
        \],
        \}
  au BufEnter * lua require'completion'.on_attach()
  augroup CompletionTriggerCharacter
    autocmd!
    autocmd BufEnter * let g:completion_trigger_character = ['.']
    autocmd FileType sql setlocal omnifunc=vim_dadbod_completion#omni
    autocmd FileType sql let g:completion_trigger_character=['.','"']
    autocmd BufEnter *.ex,*.eex let g:completion_trigger_character = ['.', '@']
    autocmd BufEnter *.c,*.cpp let g:completion_trigger_character = ['.', '>', ':']
    autocmd BufEnter *.vim let g:completion_trigger_character = ['.', ':', '#', '[', '&', '$', '<', '"', "'"]
  augroup end

" Elixir
Plug 'airblade/vim-rooter'
  let g:rooter_silent_chdir = 1
  let g:rooter_patterns = ['mix.exs', '.git/', 'package.json']
Plug 'sheerun/vim-polyglot'
Plug 'janko-m/vim-test'
  let g:test#strategy = 'neovim'
Plug 'tpope/vim-endwise'
Plug 'neovim/nvim-lsp'
  nnoremap <silent> gd    <cmd>lua vim.lsp.buf.declaration()<CR>
  nnoremap <silent> <c-]> <cmd>lua vim.lsp.buf.definition()<CR>
  nnoremap <silent> K     <cmd>lua vim.lsp.buf.hover()<CR>
  nnoremap <silent> gD    <cmd>lua vim.lsp.buf.implementation()<CR>
  nnoremap <silent> S     <cmd>lua vim.lsp.buf.signature_help()<CR>
  nnoremap <silent> 1gD   <cmd>lua vim.lsp.buf.type_definition()<CR>
  nnoremap <silent> gr    <cmd>lua vim.lsp.buf.references()<CR>
  nnoremap <silent> g0    <cmd>lua vim.lsp.buf.document_symbol()<CR>
  nnoremap <silent> gW    <cmd>lua vim.lsp.buf.workspace_symbol()<CR>
Plug 'nvim-treesitter/nvim-treesitter'

" HTML, Vue, D3.js
Plug 'alvan/vim-closetag'
  let g:closetag_filenames = '*.html, *.xhtml, *.vue, *.eex, *.leex'
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript', 'vue', 'elixir', 'eelixir'] }
  imap <c-e> <c-y>,
Plug 'othree/yajs.vim' " Improved syntax hl and indentation
Plug 'othree/javascript-libraries-syntax.vim' " Autocompletion
  let g:used_javascript_libs = 'vue, d3'
Plug 'norcalli/nvim-colorizer.lua'

" Customize UI
Plug 'morhetz/gruvbox'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
  if !exists('g:airline_symbols')
    let g:airline_symbols = {}
  endif
  let g:airline_section_z = '%3l:%2c' "\'%3l:%2c %3p%%'
  let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
  let g:airline_highlighting_cache              = 1
  let g:airline_powerline_fonts                 = 1
  let g:airline_symbols.dirty                   = '!'
  let g:airline_skip_empty_sections             = 1
  let g:airline_left_sep                        = ''
  let g:airline_right_sep                       = ''
  let g:airline_exclude_preview                 = 1
  let g:airline#extensions#tabline#enabled      = 1
  let g:airline#extensions#tabline#left_sep     = ''
  let g:airline#extensions#tabline#left_alt_sep = ''
  let g:airline#extensions#tabline#formatter    ='unique_tail'
  let g:airline_mode_map = {
        \ '__' : '-',
        \ 'n'  : 'N',
        \ 'i'  : 'I',
        \ 'R'  : 'R',
        \ 't'  : 'T',
        \ 'c'  : 'C',
        \ 'v'  : 'V',
        \ 'V'  : 'V',
        \ ''   : 'V',
        \ 's'  : 'S',
        \ 'S'  : 'S',
        \ '' : 'S',
        \ }
  let g:airline#extensions#tabline#buffer_idx_mode = 1
  let g:airline#extensions#tabline#keymap_ignored_filetypes = ['nerdtree', 'terminal']
  nmap <leader>1 <Plug>AirlineSelectTab1
  nmap <leader>2 <Plug>AirlineSelectTab2
  nmap <leader>3 <Plug>AirlineSelectTab3
  nmap <leader>4 <Plug>AirlineSelectTab4
  nmap <leader>5 <Plug>AirlineSelectTab5
  nmap <leader>6 <Plug>AirlineSelectTab6
  nmap <leader>7 <Plug>AirlineSelectTab7
  nmap <leader>8 <Plug>AirlineSelectTab8
  nmap <leader>9 <Plug>AirlineSelectTab9

" Editing
Plug 'pbrisbin/vim-mkdir'       " :e this/does/notexist/file.txt :w Just works
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-unimpaired'
Plug 'tpope/vim-surround'       " cs({ ds' ysW' vlllS'
Plug 'scrooloose/nerdcommenter' " ,cc ,c<space> ,cn
Plug 'junegunn/vim-easy-align'
  xmap ga <Plug>(EasyAlign)
  nmap ga <Plug>(EasyAlign)

" Navigation
Plug 'moll/vim-bbye'            " delete buffers w/o closing the buffer pane
  nnoremap <Leader>d :Bdelete<CR>
Plug 'andymass/vim-matchup'     " drop-in replacement for matchit
Plug 'justinmk/vim-gtfo'        " ,gof open file in filemanager
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
  let g:fzf_layout = { 'down': '~25%' }
  nnoremap <C-p>     :Files<CR>
  nnoremap <Leader>b :Buffers<CR>
  nnoremap <Leader>m :History<CR>
Plug 'scrooloose/nerdtree'
  map <C-\> :NERDTreeToggle<CR>
  map <F2>  :NERDTreeToggle<CR>
  map <F3>  :NERDTreeFind<CR>
  let NERDTreeMinimalUI = 1
  let NERDTreeIgnore = ['\.git','\.hg','\.npm','\.rebar']
  let g:NERDTreeHighlightCursorline = 0
  let g:NERDTreeMouseMode = 3
Plug 'terryma/vim-smooth-scroll' " Ctrl-e and Ctrl-d to scroll up/down
  nnoremap <C-e> <C-u>
  nnoremap <C-u> <C-e>
  noremap <silent> <c-e> :call smooth_scroll#up(&scroll, 15, 2)<CR>
  noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>

" Search
Plug 'jremmen/vim-ripgrep'
  let g:rg_command = 'rg --vimgrep -S'
Plug 'osyo-manga/vim-anzu'

" Postgresql
Plug 'tpope/vim-dadbod'
  let g:db = "postgresql://hvaria:@localhost/mgp_dev"
  xnoremap <expr> <Plug>(DBExe)     db#op_exec()
  nnoremap <expr> <Plug>(DBExe)     db#op_exec()
  nnoremap <expr> <Plug>(DBExeLine) db#op_exec() . '_'
  xmap <leader>p  <Plug>(DBExe)
  nmap <leader>p  <Plug>(DBExe)
  omap <leader>p  <Plug>(DBExe)
  nmap <leader>pb <Plug>(DBExeLine)

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive' " Gdiff Gstatus (then select add via -) Gwrite Gedit

" Latex
" Plug 'lervag/vimtex' " Disable vim-polyglot i.e. let g:polyglot_disabled = ['latex']
" Plug 'donRaphaco/neotex'
"   let g:tex_flavour = 'latex'

call plug#end()
" }}}

"" CONFIGURATION {{{
" General
syntax enable
filetype plugin indent on
set shell=/bin/zsh                " Set the shell
set clipboard=unnamed             " use system clipboard
set termguicolors
" Activate colorizer for certain filetypes, needs to be after termguicolors
lua << EOF
require 'colorizer'.setup {
  'css';
  'scss';
  'javascript';
  html = {
    mode = 'foreground';
  }
}

local nvim_lsp = require'nvim_lsp'
nvim_lsp.elixirls.setup{
  cmd = { "/home/hvaria/elixir_ls/language_server.sh" };
}
EOF

" Style
set background=dark
silent! color gruvbox
set number                        " line numbers are cool
" set relativenumber              " relative numbers are cooler
set ruler                         " show the cursor position all the time
set nocursorline                  " disable cursor line
set showcmd                       " display incomplete commands
set novisualbell                  " no flashes please
set scrolloff=3                   " provide some context when editing
set hidden                        " allow backgrounding buffers without writing them, and
                                  " remember marks/undo for backgrounded buffers
" Mouse
set mouse=a                       " we love the mouse
set mousehide                     " but hide it when we're writing

" Whitespace
set wrap                          " wrap long lines
set tabstop=2                     " a tab is two spaces
set shiftwidth=2                  " an autoindent (with <<) is two spaces
set softtabstop=2                 " when deleting, treat spaces as tabs
set expandtab                     " use spaces, not tabs
set list                          " show invisible characters
set backspace=indent,eol,start    " backspace through everything in insert mode
set autoindent                    " keep indentation level when no indent is found

" Wild life
set wildmenu                      " wildmenu gives autocompletion to vim
set wildmode=list:longest,full    " autocompletion shouldn't jump to the first match
set wildignore+=*.scssc,*.sassc,*.csv,*.pyc,*.xls
set wildignore+=tmp/**,node_modules/**,bower_components/**

" List chars
set listchars=""                  " reset the listchars
set listchars=tab:▸\              " a tab should display as "▸ "
set listchars+=trail:.            " show trailing spaces as dots
set listchars+=extends:>          " the character to show in the last column when wrap is
                                  " off and the line continues beyond the right of the screen
set listchars+=precedes:<         " the character to show in the first column when wrap is
                                  " off and the line continues beyond the left of the screen
set fillchars+=vert:\             " set vertical divider to empty space

" Searching
nohlsearch                        " but don't highlight last search when reloading
set ignorecase                    " searches are case insensitive...
set smartcase                     " unless they contain at least one capital letter

" Windows
set splitright                    " create new horizontal split on the right
set splitbelow                    " create new vertical split below the current window

" Backup, undo and file management
set nobackup
set nowritebackup
set noswapfile
let g:data_dir = $HOME . '/.data/'
let g:undo_dir = g:data_dir . 'undofile'
if finddir(g:data_dir) == ''
  silent call mkdir(g:data_dir)
endif
if finddir(g:undo_dir) == ''
  silent call mkdir(g:undo_dir)
endif
unlet g:data_dir
unlet g:undo_dir
set undodir=$HOME/.data/undofile
set undofile
set undolevels=1000
set undoreload=1000
" }}}

"" KEYBINDINGS {{{
" Common keybindings
nnoremap ; :
noremap <c-s> :w<CR>
noremap <Leader>q :q!<CR> " Exit w/o saving
" Escape
inoremap jk <ESC>
inoremap <C-c> <Esc>
vnoremap <C-c> <Esc>
" Terminal
nnoremap <Leader>t :split<bar>:res 10 <bar>:term<CR>
tnoremap <Esc> <C-\><C-n>
tnoremap <C-v><Esc> <Esc>
" Navigation made easy
noremap  H ^
noremap  L g_
noremap  F %
vnoremap L g_
" Pane navigation
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
" quickly move between open buffers
nnoremap <Leader><Leader> <C-^>
nnoremap <Right> :bnext<CR>
nnoremap <Left>  :bprev<CR>
" window keys
nnoremap <M-Up>    :resize +1<CR>
nnoremap <M-Down>  :resize -1<CR>
nnoremap <M-Left>  :vertical resize +1<CR>
nnoremap <M-Right> :vertical resize -1<CR>
nnoremap <C-Up>    :resize +5<CR>
nnoremap <C-Down>  :resize -5<CR>
nnoremap <C-Left>  :vertical resize +5<CR>
nnoremap <C-Right> :vertical resize -5<CR>
nnoremap <Leader>s :split<CR>
nnoremap <Leader>v <C-w>v<C-w>l
nnoremap <Leader>x :call CloseWindowOrKillBuffer()<CR>
" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv
" make Y consistent with C & D
nnoremap Y y$
" reselect last paste
noremap gV `[v`]
" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Saner cmd line history
cnoremap <c-n> <down>
cnoremap <c-p> <up>
cnoremap <c-p> <up>
" toggle highlight search
nnoremap <BS> :set hlsearch!<CR>
nnoremap <CR> :nohlsearch<CR>
" Spelling
nnoremap <leader>sp :set spell<CR>
nnoremap <leader>sc ]s
" Paste mode
nnoremap <leader>pa :set nopaste!<CR>
" Clipboard functionality (paste from system)
vnoremap  <leader>y "+y
nnoremap  <leader>y "+y
"nnoremap  <leader>p "+p
"vnoremap  <leader>p "+p
" easy substitutions
nnoremap <Leader>r :%s///gc<Left><Left><Left><Left>
nnoremap <Leader>R :%s:::gc<Left><Left><Left><Left>
" easy global search
nnoremap <C-f> :Rg <C-R><C-W><CR>
vnoremap <C-f> y<Esc>:Rg <C-R>"<CR>

"" FUNCTIONS {{{
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
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"}}}

"" FILETYPE SETTINGS {{{
" Help buffer
augroup filetype_help
  au!
  au FileType help wincmd L | vert res 79<CR>  " Make K or help open in vertical split
  au FileType help nnoremap <buffer><cr> <c-]>
  au FileType help nnoremap <buffer><bs> <c-T>
  au FileType help nnoremap <buffer>q :q<CR>
augroup END

" Vue
augroup filetype_vue
  au!
  au BufReadPre *.vue let b:javascript_lib_use_vue = 1
  au FileType vue syntax sync fromstart
augroup END

" in Makefiles use real tabs, not tabs expanded to spaces
augroup filetype_make
  au!
  au FileType make setl ts=8 sts=8 sw=8 noet
augroup END

" make sure all markdown files have the correct filetype set and setup wrapping
augroup filetype_markdown
  au!
  au FileType markdown setl tw=75 | syntax sync fromstart
  au BufRead,BufNewFile *.{md,markdown,mdown,mkd,mkdn,txt} setf markdown
augroup END

" treat JSON files like JavaScript
augroup filetype_json
  au!
  au BufNewFile,BufRead *.json setf javascript
augroup END

" disable endwise for anonymous functions and pp -> |>
augroup filetype_elixir
  au!
  au FileType elixir,eelixir iab pp \|>
  au FileType elixir,eelixir setlocal omnifunc=v:lua.vim.lsp.omnifunc
  au BufWritePre *.{ex,exs} lua vim.lsp.buf.formatting_sync()
  au BufNewFile,BufRead *.{ex,exs}
    \ let b:endwise_addition = '\=submatch(0)=="fn" ? "end)" : "end"'
  au BufNewFile,BufRead *.{ex,exs}
    \ syn match elixirCustomOperators " def "  conceal cchar= " Space
  au BufNewFile,BufRead *.{ex,exs}
    \ syn match elixirCustomOperators " defp " conceal cchar=_
  au BufNewFile,BufRead *.{ex,exs} set concealcursor=nc
  au BufNewFile,BufRead *.{ex,exs} set conceallevel=1
augroup END

" delete Fugitive buffers when they become inactive
augroup filetype_fugitive
  au!
  au BufReadPost fugitive://* set bufhidden=delete
augroup END

" Vim
augroup filetype_vim
  au!
  au FileType vim setlocal fdm=indent keywordprg=:help
  " fold automatically with triple {
  au FileType vim,javascript,python,c setlocal foldmethod=marker nofoldenable
augroup END

" enable <CR> in command line window and quickfix
augroup enable_cr
  au!
  au CmdwinEnter * nnoremap <buffer> <CR> <CR>
  au BufWinEnter quickfix nnoremap <buffer> <CR> <CR>
augroup END

" disable automatic comment insertion
augroup auto_comments
  au!
  au FileType * setlocal formatoptions-=ro
augroup END

" Terminal window
augroup terminal_numbers
  au!
  au TermOpen * setlocal nonumber
  au TermOpen * :startinsert
  au BufEnter,BufNew term://* :startinsert
augroup END

" SCSS
augroup filetype_scss
  au!
  au FileType css,scss setlocal foldmethod=marker foldmarker={,}
augroup END

" remember last location in file, but not for commit messages,
" or when the position is invalid or inside an event handler,
" or when the mark is in the first line, that is the default
" position when opening a file. See :help last-position-jump
augroup last_position
  au!
  au BufReadPost *
    \ if &filetype !~ '^git\c' && line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif
augroup END
" }}}
