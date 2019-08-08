" vim-plug (https://github.com/junegunn/vim-plug) settings
" Automatically install vim-plug and run PlugInstall if vim-plug not found
if empty(glob('~/.config/nvim/autoload/plug.vim'))
  silent !curl -fLo ~/.config/nvim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall | source $MYVIMRC
endif

let g:python3_host_prog = '/usr/bin/python3'

call plug#begin('~/.config/nvim/plugged')

" General
let g:mapleader = ','
Plug 'dietsche/vim-lastplace'

" Languages
Plug 'sheerun/vim-polyglot'

" AutoCompletion, linting, Lsp etc.
Plug 'ervandew/supertab'
  let g:SuperTabDefaultCompletionType = "<c-n>"
Plug 'neoclide/coc.nvim', {'tag': '*', 'branch': 'release'}
  nmap <silent> gd <Plug>(coc-definition)
  nmap <silent> gy <Plug>(coc-type-definition)
  nmap <silent> gi <Plug>(coc-implementation)
  nmap <silent> gr <Plug>(coc-references)
Plug 'Shougo/echodoc.vim'
  let g:echo_enable_at_startup = 1

" Vue & Javascript
Plug 'othree/yajs.vim' " Improved syntax highlighting and indentation
Plug 'othree/javascript-libraries-syntax.vim' " Autocompletion of Vue
  let g:used_javascript_libs = 'vue, d3'
  autocmd BufReadPre *.vue let b:javascript_lib_use_vue = 1
  autocmd FileType vue syntax sync fromstart
Plug 'evanleck/vim-svelte'

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript', 'vue', 'elixir', 'svelte'] }
Plug 'alvan/vim-closetag'
  let g:closetag_filenames = '*.html, *.xhtml, *.vue, *.eex, *.leex, *.svelte'
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript', 'vue', 'elixir', 'svelte'] }
  imap <c-e> <c-y>,

" Elixir & Erlang
Plug 'mhinz/vim-mix-format'
  let g:mix_format_on_save       = 1
  let g:mix_format_silent_errors = '--check-equivalent'
Plug 'tpope/vim-endwise'
Plug 'janko-m/vim-test'
  let g:test#strategy = 'neovim' " run tests in neovim strategy
  nmap <Leader>t :TestNearest
  nmap <Leader>f :TestFile
  " nmap <Leader>s :TestSuite
  augroup filetype_elixir
    au FileType elixir,eelixir iabbrev <buffer> pp \|>
  augroup END
Plug 'andymass/vim-matchup'

" Shell
Plug 'kassio/neoterm'
  set shell=/usr/bin/zsh
  set noshelltemp " use pipes
  let g:neoterm_autojump = 1
  nnoremap <silent> ,tl :Tclear<CR>
  nnoremap <Leader>c :botright Tnew <bar> :res 8 <bar> :set wfh<CR>
  nnoremap <Leader>cv :vert Tnew<CR>

" Snippets
Plug 'SirVer/ultisnips'
  let g:UltiSnipsJumpForwardTrigger="<c-f>"
  let g:UltiSnipsJumpBackwardTrigger="<c-b>"
Plug 'honza/vim-snippets'

" Project Management
Plug 'airblade/vim-rooter'
  let g:rooter_silent_chdir = 1
  let g:rooter_patterns = ['mix.exs', '.git/', 'package.json']
Plug 'scrooloose/nerdtree', { 'on': ['NERDTreeToggle', 'NERDTreeFind'] }
  map <C-\> :NERDTreeToggle<CR>
  map <F2>  :NERDTreeToggle<CR>
  map <F3>  :NERDTreeFind<CR>
  let g:NERDTreeMinimalUI=1
  let g:NERDTreeWinSize=20
  let g:NERDTreeStatusLine = ''
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
Plug 'pbrisbin/vim-mkdir'    " :e this/does/notexist/file.txt :w Just works
Plug 'jiangmiao/auto-pairs'  " Insert or delete brackets, parens, quotes in pairs
  let g:AutoPairsMapCR=0     " no funny stuff on carriage return
  let g:AutoPairsMultilineClose = 0
  au FileType vim let b:AutoPairs = {'(':')','[':']','{':'}',"'":"'",'`':'`'}
  au FileType rust let b:AutoPairs={'(': ')', '[': ']', '{': '}', "|": "|", '"': '"', '`': '`'}
  au FileType tex,markdown let b:AutoPairs={'(': ')', '[': ']', '{': '}', '"': '"', '`': '`', '$': '$'}
Plug 'godlygeek/tabular'
Plug 'tpope/vim-commentary'      " gc i.e. toggle commenting code
Plug 'tpope/vim-repeat'          " allow added vim motion to be repeatable like vim-surround
Plug 'machakann/vim-sandwich'    " surround motion ie saiw( foo -> (foo) | sd( for del | sdr({ (foo) -> {foo}
Plug 'terryma/vim-expand-region' " hit v repeatable to select surrounding
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
Plug 'stefandtw/quickfix-reflector.vim' " Edit quickfix list and commit changes to files

" Folding
set foldenable
set foldlevelstart=3               " Show most folds by default
set foldnestmax=5                  " You're writing bad code if you need to up this one
set foldmethod=syntax              " Fold based on syntax
set foldopen+=jump
let g:xml_sytax_folding = 1
nnoremap zr zr:echo &foldlevel<CR>
nnoremap zm zm:echo &foldlevel<CR>
nnoremap zR zR:echo &foldlevel<CR>
nnoremap zM zM:echo &foldlevel<CR>

" Navigation
Plug 'moll/vim-bbye'               " Delete buffers without closing windows or messing with layout
  nnoremap q :Bdelete<cr>
Plug 'justinmk/vim-gtfo'           " ,gof open file in filemanager
Plug 'wesQ3/vim-windowswap'        " <Leader>ww once to select window and again to swap window
Plug 'milkypostman/vim-togglelist' " <leader>l & q for location and quick list
Plug 'junegunn/fzf'
Plug 'junegunn/fzf.vim'
  let g:fzf_layout = { 'down': '~18%' }
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
  autocmd! FileType fzf
  autocmd  FileType fzf set laststatus=0 noshowmode noruler
        \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  nnoremap <c-p>      :Files<CR>
  noremap  <Leader>r  :History<CR>
  nnoremap <Leader>bt :BTags<CR>
  nnoremap <Leader>T  :Tags<CR>
  nnoremap <Leader>b  :Buffers<CR>
Plug 'jremmen/vim-ripgrep'
  let g:rg_command = 'rg --vimgrep -S'
Plug 'osyo-manga/vim-anzu'
  nmap n <Plug>(anzu-n)zz
  nmap N <Plug>(anzu-N)zz
  nmap * <Plug>(anzu-star)zz
  nmap # <Plug>(anzu-sharp)zz
  nmap <Esc><Esc> <Plug>(anzu-clear-search-status)
  nnoremap <silent> <C-o> <C-o>zz
  nnoremap <silent> <C-i> <C-i>zz

" Git
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive' " Gdiff Gstatus (then select add via  -) Gwrite Gedit

" text objects
Plug 'wellle/targets.vim'

" Eye candy
Plug 'lilydjwg/colorizer', { 'on': 'ColorToggle' }
  nmap <F5> :ColorToggle<CR>
Plug 'terryma/vim-smooth-scroll' " Ctrl-e and Ctrl-d to scroll up/down
  nnoremap <C-e> <C-u>
  nnoremap <C-u> <C-e>
  noremap <silent> <c-e> :call smooth_scroll#up(&scroll, 15, 2)<CR>
  noremap <silent> <c-d> :call smooth_scroll#down(&scroll, 15, 2)<CR>
  " noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
  " noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
  let g:airline_section_z = ' %3l:%2c %3p%%'
  let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
  let g:airline_highlighting_cache              = 1
  let g:airline_powerline_fonts                 = 1
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
  nmap <leader>1 <Plug>AirlineSelectTab1
  nmap <leader>2 <Plug>AirlineSelectTab2
  nmap <leader>3 <Plug>AirlineSelectTab3
  nmap <leader>4 <Plug>AirlineSelectTab4
  nmap <leader>5 <Plug>AirlineSelectTab5
  nmap <leader>6 <Plug>AirlineSelectTab6
  nmap <leader>7 <Plug>AirlineSelectTab7
  nmap <leader>8 <Plug>AirlineSelectTab8
  nmap <leader>9 <Plug>AirlineSelectTab9

" Latex
" Plug 'lervag/vimtex' " Disable vim-polyglot i.e. let g:polyglot_disabled = ['latex']
" Plug 'donRaphaco/neotex'
"   let g:tex_flavour = 'latex'

" Colorschemes
" Plug 'rakr/vim-one'
Plug 'mhartington/oceanic-next'

call plug#end()


" Neovim Settings
set numberwidth=5
set complete-=i
set nrformats-=octal
set laststatus=2
set cmdheight=1            " command line height
set tildeop                " Make ~ toggle case for whole line
set clipboard+=unnamedplus " Use system clipboard
set iskeyword+=-           " Makes foo-bar considered one word
set nocursorline
set mouse=a
set termguicolors          " Enable 24-bit colors in supported terminals
set background=dark
let g:oceanic_next_terminal_bold = 1
let g:oceanic_next_terminal_italic = 1
let g:airline_theme='oceanicnext'
colorscheme OceanicNext

" tab stuff
set expandtab shiftwidth=2 softtabstop=2
set shiftround
set smartindent

" ui options
set title
set showmatch matchtime=2 " show matching brackets/braces (2*1/10 sec)
set number
set noshowmode
set t_ut=                 " improve screen clearing by using the background colour
set diffopt+=iwhite       " Add ignorance of whitespace to diff
set diffopt+=vertical     " Always diff vertically
set synmaxcol=200         " Boost performance of rendering long lines
set inccommand=nosplit    " live substitution preview
set colorcolumn=          " alternative approach for lines that are too long
highlight OverLength ctermbg=red ctermfg=white guifg=NORMAL guibg=#592929
match OverLength /\%81v.\+/

" Autocomplete list options
set wildmenu
set wildmode=list:longest,full " show similar and all options
set wildignorecase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/tmp/*,*.so,*.swp,*.zip,*node_modules*,*.jpg,*.png,*.svg,*.ttf,*.woff,*.woff3,*.eot,*public/css/*,*public/js,*.scssc,*.csv,*.xls
set shortmess+=c     " shorten messages
set timeoutlen=300   " mapping timeout
set ttimeoutlen=10   " keycode timeout

" Split window behaviour
set splitbelow splitright

" disable error sounds
set noerrorbells
set novisualbell
set t_vb=

" scroll options
set scrolloff=3
set sidescrolloff=7
set sidescroll=5
set display+=lastline
set nostartofline " don't jump to the start of line when scrolling

" whitespace, hidden characters & line breaks
" set list      " Toggle showing hidden characters i.e. space
set linebreak   " Wrap long lines at a character
set listchars+=tab:▸\ ,trail:.,eol:¬,space:·,extends:❯,precedes:❮ ",conceal:Δ,nbsp:+
let &showbreak="↪ "
set breakindent " when wrapping, indent the lines
set breakindentopt=sbr
set wrap
set formatoptions+=rno1l

" searching
set ignorecase smartcase
set smartcase

" tags
set tags=tags;/
set showfulltag

" backup, undo and file management
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
" Automaticaly close nvim if NERDTree is only thing left open
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

" Keyboard mappings
" common actions
nnoremap <Leader>d :bdelete<CR>
nnoremap <Leader><Leader> <c-^> " Swith between last two files
nnoremap Q @q                   " Use Q to execute default register
nnoremap <C-s> :<C-u>w<CR>      " Ctrl-S to save in most modes
vnoremap <C-s> :<C-u>w<CR>
cnoremap <C-s> <C-u>w<CR>
inoremap <C-s> <esc>:w<CR>
command! Q q " Bind :Q to :q
command! Qall qall
command! QA qall
command! E e
nnoremap <Leader>* :%s/\<<c-r><c-w>\>//g<left><left> " replace the word under cursor
" Navigation made easy
noremap  H ^
noremap  L g_
noremap  F %
vnoremap L g_
" Change cursor position in insert mode
inoremap <C-h> <left>
inoremap <C-j> <up>
inoremap <C-k> <down>
inoremap <C-l> <right>
inoremap <C-u> <C-g>u<C-u> " Del from start of line to cursor position
" inoremap <C-b> <S-Left> " give to ultisnips
inoremap <C-w> <S-Right>
" Navigation between display lines
noremap  <silent> <Up>   gk
noremap  <silent> <Down> gj
noremap  <silent> k      gk
noremap  <silent> j      gj
noremap  <silent> <Home> g<Home>
noremap  <silent> <End>  g<End>
inoremap <silent> <Home> <C-o>g<Home>
inoremap <silent> <End>  <C-o>g<End>
" smash escape
inoremap jk <esc>
inoremap kj <esc>
" quickly move between open buffers
nnoremap <Right> :bnext<CR>
nnoremap <Left>  :bprev<CR>
" window keys
nnoremap <M-Up>    :resize +1<CR>
nnoremap <M-Down>  :resize -1<CR>
nnoremap <M-Left>  :vertical resize +1<CR>
nnoremap <M-Right> :vertical resize -1<CR>
nnoremap <C-Up>    :resize -5<CR>
nnoremap <C-Down>  :resize +5<CR>
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
" xclip needs to be installed for visual copy to system clipboard
vnoremap Y "+y
" toggle highlight search
nnoremap <BS> :set hlsearch! hlsearch? \| AnzuClearSearchStatus<CR>
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
" reselect last paste
noremap gV `[v`]
" find current word in quickfix
nnoremap <Leader>fw :execute "vimgrep ".expand("<cword>")." %"<CR>:copen<cr>
" find last search in quickfix
nnoremap <Leader>ff :execute 'vimgrep /'.@/.'/g %'<CR>:copen<cr>
" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
" Saner cmd line history
cnoremap <c-n> <down>
cnoremap <c-p> <up>
" Make K or help open in vertical split
nnoremap <silent> K :call <SID>show_documentation()<CR>
function! s:show_documentation()
  if (index(['vim', 'help'], &filetype) >= 0)
    execute 'h '.expand('<cword>')
  else
    call CocAction('doHover')
  endif
endfunction

" FileType settings {{{
augroup general
  au!
  au BufWritePre * %s/\s\+$//e " Trim whitespace onsave

  " Help buffer
  au FileType help nnoremap <buffer><cr> <c-]>
  au FileType help nnoremap <buffer><bs> <c-T>
  au FileType help nnoremap <buffer>q :q<CR>
augroup END

" Vim
augroup filetype_vim
  au FileType vim setlocal fdm=indent keywordprg=:help
  " fold automatically with triple {
  au FileType vim,javascript,python,c setlocal foldmethod=marker nofoldenable
augroup END

" Terminal window
augroup terminal
  au!
  au TermOpen * setlocal nonumber norelativenumber
  au TermOpen * :startinsert
  au BufEnter,BufNew term://* :startinsert
augroup END

" Disable automatic comment insertion
augroup auto_comments
  au!
  au FileType * setlocal formatoptions-=ro
augroup END

" enable <CR> in command line window and quickfix
augroup enable_cr
  au!
  au CmdWinEnter * nnoremap <buffer> <CR> <CR>
  au BufWinEnter quickfix nnoremap  <buffer> <CR> <CR>
augroup END

" Svelte
augroup filetype_svelte
  au!
  au BufNewFile,BufRead,BufReadPost *.svelte set syntax=html
augroup END

" SCSS
augroup filetype_scss
  au!
  au FileType css,scss setlocal foldmethod=marker foldmarker={,}
augroup END
" }}}

