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
Plug 'mhinz/vim-startify'
  let g:startify_session_dir        = '~/.data/sessions'
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions      = 1

" Languages
Plug 'sheerun/vim-polyglot'

" Vue & Javascript
Plug 'othree/javascript-libraries-syntax.vim' " Autocompletion of Vue
  let g:used_javascript_libs = 'vue'
  autocmd BufReadPre *.vue let b:javascript_lib_use_vue = 1
  autocmd FileType vue syntax sync fromstart

" HTML
Plug 'gregsexton/MatchTag', { 'for': ['html', 'javascript', 'vue'] }
Plug 'alvan/vim-closetag'
  let g:closetag_filenames = '*.html, *.xhtml, *.vue'
Plug 'mattn/emmet-vim', { 'for': ['html', 'javascript', 'vue'] }
  imap <c-e> <c-y>,

" Elixir & Erlang
Plug 'slashmili/alchemist.vim'
  let g:alchemist#elixir_erlang_src = "/usr/lib/elixir"
Plug 'mhinz/vim-mix-format'
  let g:mix_format_on_save       = 1
  let g:mix_format_silent_errors = '--check-equivalent'
Plug 'neomake/neomake'
  let g:neomake_elixir_enabled_makers = ['mix'] ",credo']
  let g:neomake_javascript_enabled_makers = ['eslint']
  let g:neomake_error_sign         = {'text': '✘'}
  let g:neomake_warning_sign       = {'text': '!'}
  let g:neomake_echo_current_error = 0
  let g:neomake_open_list          = 2
  " Run Noemake for the following buffers
  augroup neomake
    autocmd! BufWritePre *.ex,*.exs Neomake
  augroup END
Plug 'powerman/vim-plugin-AnsiEsc'
Plug 'tpope/vim-endwise'
Plug 'ludovicchabant/vim-gutentags' " Easily manage tags files
  let g:gutentags_cache_dir = '~/.tags_cache'
  let g:gutentags_ctags_exclude=["node_modules","plugged","tmp","temp","log","vendor","**/db/migrate/*","bower_components","dist","build","coverage","spec","public","app/assets","*.json"]
  " Enter is go to definition (ctags)
  nnoremap <CR> <C-]>
  " In quickfix,  <CR> to jump to error under the cursor
  autocmd FileType qf  nnoremap <buffer> <CR> <CR>
  " same for vim type windows
  autocmd FileType vim nnoremap <buffer> <CR> <CR>
  let g:alchemist_tag_map = '<CR>'
  let g:alchemist_tag_stack_map = '<C-T>'
Plug 'janko-m/vim-test'
  let g:test#strategy = 'neovim' " run tests in neovim strategy
Plug 'BurningEther/iron.nvim', { 'do': ':UpdateRemotePlugins' }
  let g:iron_map_defaults = 0 " deactivate default mappings
  let g:iron_repl_open_cmd = 'below 10sp | set nonumber'
  augroup ironmapping
    autocmd!
    autocmd Filetype elixir nnoremap <localleader>r :IronRepl<cr>
    autocmd Filetype elixir vmap <buffer> <localleader>t <Plug>(iron-send-motion)
    autocmd Filetype elixir nmap <buffer> <localleader>p <Plug>(iron-repeat-cmd)
  augroup END


" Shell
set shell=/usr/bin/zsh
set noshelltemp " use pipes
nnoremap <Leader>c :below 10sp term://zsh<CR>
nnoremap <Leader>cv :vsplit term://zsh<CR>

" Autocompletion
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Shougo/neosnippet'
Plug 'Shougo/neosnippet-snippets'
  let g:deoplete#enable_at_startup = 1
  let g:enable_smart_case          = 1
  let g:deoplete#enable_camel_case = 1
  set completeopt+=menuone
  set shortmess+=c " suppress 'match x of y', 'The only match' and 'Pattern not found' messages
  " <C-h>, <BS>: close popup and delete backword char.
  inoremap <expr><C-h> deoplete#smart_close_popup()."\<C-h>"
  inoremap <expr><BS>  deoplete#smart_close_popup()."\<C-h>"
  " <C-i> to expand selected snippet in popup menu
  imap <C-i> <Plug>(neosnippet_expand_or_jump)
  smap <C-i> <Plug>(neosnippet_expand_or_jump)
  xmap <C-i> <Plug>(neosnippet_expand_target)
  " set tab complete to work like SuperTab
  imap <expr><TAB> neosnippet#expandable_or_jumpable()?"\<Plug>(neosnippet_expand_or_jump)":(pumvisible()?"\<C-n>":"\<TAB>")
  smap <expr><TAB> neosnippet#expandable_or_jumpable()?"\<Plug>(neosnippet_expand_or_jump)":"\<TAB>"
  imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
  smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
  " For conceal markers.
  if has('conceal')
    set conceallevel=2
  endif

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
Plug 'jiangmiao/auto-pairs' " Insert or delete brackets, parens, quotes in pairs
let g:AutoPairsMapCR=0      " no funny stuff on carriage return
let g:AutoPairsMultilineClose = 0
au FileType vim let b:AutoPairs = {'(':')','[':']','{':'}',"'":"'",'`':'`'}
au FileType rust let b:AutoPairs={'(': ')', '[': ']', '{': '}', "|": "|", '"': '"', '`': '`'}
au FileType tex,markdown let b:AutoPairs={'(': ')', '[': ']', '{': '}', '"': '"', '`': '`', '$': '$'}
Plug 'junegunn/vim-easy-align'
Plug 'tpope/vim-commentary'      " gc i.e. toggle commenting code
Plug 'tpope/vim-repeat'          " allow added vim motion to be repeatable like vim-surround
Plug 'machakann/vim-sandwich'    " surround motion ie saiw( foo -> (foo) | sd( for del | sdr({ (foo) -> {foo}
Plug 'terryma/vim-expand-region' " hit v repeatable to select surrounding
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
Plug 'chrisbra/unicode.vim'      " :UnicodeTable to search and copy unicode chars

" Folding
set foldenable
set fillchars=diff:⣿,vert:│,fold:· " Subtitute characters shown in certain modes
set foldlevelstart=9               " Show most folds by default
set foldnestmax=5                  " You're writing bad code if you need to up this one
set foldmethod=syntax              " Fold based on syntax
set foldopen+=jump
let g:xml_sytax_folding = 1
nnoremap zr zr:echo &foldlevel<CR>
nnoremap zm zm:echo &foldlevel<CR>
nnoremap zR zR:echo &foldlevel<CR>
nnoremap zM zM:echo &foldlevel<CR>

" Navigation
Plug 'justinmk/vim-gtfo'    " ,gof open file in filemanager
Plug 'majutsushi/tagbar'    " F9 to Toggle tabbar window
  nmap <F9> :TagbarToggle<CR>
  let g:tagbar_width     = 40
  let g:tagbar_autoclose =  0
  let g:tagbar_autofocus =  1
  let g:tagbar_compact   =  1
Plug 'wesQ3/vim-windowswap'        " <Leader>ww once to select window and again to swap window
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
  nnoremap <c-p>      :Files<CR>
  noremap  <Leader>r  :History<CR>
  nnoremap <Leader>bt :BTags<CR>
  nnoremap <Leader>T  :Tags<CR>
  nnoremap <Leader>b  :Buffers<CR>

" Searching
Plug 'mileszs/ack.vim' " :Ack <word to search>
  if executable('rg')
    let g:ackprg = "rg --column --smart-case --follow"
    set grepprg=rg\ --vimgrep
  endif
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
  noremap <silent> <c-b> :call smooth_scroll#up(&scroll*2, 15, 4)<CR>
  noremap <silent> <c-f> :call smooth_scroll#down(&scroll*2, 15, 4)<CR>
Plug 'Yggdroot/indentLine'
  let g:indentLine_faster                   = 1
  let g:indentLine_setConceal               = 0
  let g:indentLine_enabled                  = 0
  let g:indentLine_char                     = "\u250A" " '┆'
  let g:indent_guides_start_level           = 1
  let g:indent_guides_guide_size            = 1
  let g:indent_guides_enable_on_vim_startup = 0
  let g:indentLine_setColors                = 0
Plug 'ap/vim-buftabline'
  let g:buftabline_numbers = 2
  let g:buftabline_indicators = 1
  nmap <leader>1 <Plug>BufTabLine.Go(1)
  nmap <leader>2 <Plug>BufTabLine.Go(2)
  nmap <leader>3 <Plug>BufTabLine.Go(3)
  nmap <leader>4 <Plug>BufTabLine.Go(4)
  nmap <leader>5 <Plug>BufTabLine.Go(5)
  nmap <leader>6 <Plug>BufTabLine.Go(6)
  nmap <leader>7 <Plug>BufTabLine.Go(7)
  nmap <leader>8 <Plug>BufTabLine.Go(8)
  nmap <leader>9 <Plug>BufTabLine.Go(9)
  nmap <leader>0 <Plug>BufTabLine.Go(10)
  hi default link BufTabLineCurrent Lightline
  hi default link BufTabLineActive Directory
  hi default link BufTabLineHidden Directory
  hi default link BufTabLineFill Directory
Plug 'itchyny/lightline.vim'
let g:responsive_width_mid=70
let g:responsive_width_small=50
let g:omit_fileencoding='utf-8'
let g:omit_fileformat='unix'
let g:lightline={
    \ 'colorscheme': 'ayu',
    \ 'active': {
    \     'left': [
    \         ['mode'],
    \         ['fugitive', 'neomake'],
    \         ['filename', 'readonly', 'modified']
    \     ],
    \     'right': [
    \         ['percent', 'windownr'],
    \         ['lineno'],
    \         ['filetype', 'fileformat', 'fileencoding']
    \     ]
    \ },
    \ 'inactive': {
    \     'left': [
    \         ['filename']
    \     ],
    \     'right': [
    \         ['windownr']
    \     ]
    \ },
    \ 'component_function': {
    \     'fileencoding': 'LightLineFileencoding',
    \     'fileformat':   'LightLineFileformat',
    \     'filetype':     'LightLineFiletype',
    \     'fugitive':     'LightLineFugitive',
    \     'neomake':      'LightLineNeomake',
    \     'lineno':       'LightLineLineno',
    \     'mode':         'LightLineMode',
    \     'percent':      'LightLinePercent',
    \     'readonly':     'LightLineReadonly',
    \ },
    \ 'separator': { 'left': '', 'right': '' },
    \ 'subseparator': { 'left': '|', 'right': '|' },
    \ }

function! LightLineMode()
    return winwidth(0) > g:responsive_width_small ? lightline#mode() : ''
endfunction

function! LightLineFugitive()
    if winwidth(0) > g:responsive_width_mid && exists('*fugitive#head')
        let l:head=fugitive#head()
        return l:head !=# '' ? ' '.l:head : ''
    endif
    return ''
endfunction

function! LightLineNeomake()
    if winwidth(0) > g:responsive_width_mid && exists('*neomake#statusline#LoclistStatus')
        let l:status=neomake#statusline#LoclistStatus()
        return l:status
    endif
    return ''
endfunction

function! LightLineReadonly()
    return winwidth(0) > g:responsive_width_mid ?
        \ (&filetype !~? 'help' && &readonly ? '' : '') : ''
endfunction

function! LightLineModified()
    return winwidth(0) > g:responsive_width_mid ?
        \ (&filetype !~? 'help' ? '' : &modified ? '+' : &modifiable ? '' : '-') : ''
endfunction

function! LightLineFiletype()
    return winwidth(0) > g:responsive_width_mid ?
        \ (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightLineFileformat()
    return winwidth(0) > g:responsive_width_mid ?
        \ (&fileformat !=# g:omit_fileformat ? &fileformat : '') : ''
endfunction

function! LightLineLineno()
    return winwidth(0) > g:responsive_width_small ?
        \ printf(' %d:%-2d', line('.'), col('.')) : ''
endfunction

function! LightLinePercent()
    return winwidth(0) > g:responsive_width_mid ?
        \ printf('%2d%%', line('.') * 100 / line('$')) : ''
endfunction

function! LightLineFileencoding()
    return winwidth(0) > g:responsive_width_mid ?
        \ (&fileencoding !=# '' ?
        \ (&fileencoding !=# g:omit_fileencoding ? &fileencoding : '') :
        \ (&encoding !=# g:omit_fileencoding ? &encoding : '')) : ''
endfunction


" Latex
" Plug 'donRaphaco/neotex'
"   let g:tex_flavour = 'latex'

" Colorschemes
" Plug 'drewtempelmeyer/palenight.vim'
Plug 'ayu-theme/ayu-vim'

call plug#end()

" Neovim Settings
set numberwidth=5
set ruler
set autoread
set complete-=i
set nrformats-=octal
set laststatus=2
set cmdheight=1            " command line height
set tildeop                " Make ~ toggle case for whole line
" set clipboard+=unnamedplus " Use system clipboard
set iskeyword+=-           " Makes foo-bar considered one word
set cursorline
set mouse=a
set termguicolors          " Enable 24-bit colors in supported terminals
set background=dark
" let g:palenight_terminal_italics = 1
let ayucolor = "mirage"
colorscheme ayu

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
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
match OverLength /\%81v.\+/

" autocomplete list options
set wildmenu
set wildmode=list:longest,list:full " show similar and all options
set wildignorecase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/tmp/*,*.so,*.swp,*.zip,*node_modules*,*.jpg,*.png,*.svg,*.ttf,*.woff,*.woff3,*.eot,*public/css/*,*public/js
set shortmess+=aoOTI " shorten messages
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
set listchars+=tab:——,trail:·,eol:$,space:· ",extends:❯,precedes:❮,conceal:Δ,nbsp:+
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
set nobackup
set nowritebackup
set noswapfile
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
inoremap <C-b> <S-Left>
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
" Saner cmd line history
cnoremap <c-n> <down>
cnoremap <c-p> <up>
" Make K or help open in vertical split
autocmd FileType help  wincmd L | vert res 80<CR>
autocmd FileType elixir nnoremap <buffer> <s-k> :call OpenExDoc()<CR>
autocmd FileType elixir nnoremap <buffer> <leader>d :call alchemist#exdef()<CR>
" Opens alchemist exdoc
function! OpenExDoc()
  :call alchemist#exdoc() | wincmd L | vert res 80
  setlocal nonumber buftype=nofile bufhidden=wipe nobuflisted noswapfile nowrap modifiable nocursorline nofoldenable
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
  autocmd BufEnter,BufNew term://* set nonumber
  autocmd BufEnter,BufNew term://* :startinsert
augroup END

augroup MyFileTypes
  au!
  au FileType css,scss setlocal foldmethod=marker foldmarker={,}
  au filetype vim setlocal fdm=indent keywordprg=:help
  au FileType vim setlocal fdm=indent keywordprg=:help

  " Help System Speedups
  autocmd filetype help nnoremap <buffer><cr> <c-]>
  autocmd filetype help nnoremap <buffer><bs> <c-T>
  autocmd filetype help nnoremap <buffer>q :q<CR>

  autocmd filetype qf setlocal wrap
augroup END

