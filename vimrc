""" TOC
" 1. Customize
" 2. Setup Neobundle
" 3. Functions
" 4. NeoBundle Packages
" 5. Vim Tweaks
" 6. Keyboard Shortcuts
" 7. Autocmd
" 8. Fin

""" Customize =============================
let s:settings = {}
let s:settings.default_indent=2
let s:settings.colorscheme='railscasts'
let s:cache_dir = '~/.vim/.cache'
if exists("g:loaded_restore_view")
  finish
endif
let g:loaded_restore_view = 1
if !exists("g:skipview_files")
  let g:skipview_files = []
endif
""" End Customize =========================

""" Setup Neobundle =======================
set nocompatible

" Initialize neobunle
set rtp+=~/.vim/bundle/neobundle.vim
call neobundle#begin(expand('~/.vim/bundle/'))
NeoBundleFetch 'Shoujo/neobundle.vim'
""" End Setup Neobundle ===================

""" Functions =============================
function! s:get_cache_dir(suffix)
  return resolve(expand(s:cache_dir . '/' . a:suffix))
endfunction

function! Preserve(command)
  " preparation: save last search and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  execute a:command
  " clean up: restore previous search history and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

function! StripTrailingWhitespace()
  call Preserve("%s/\\s\\+$//e")
endfunction

function! EnsureExists(path)
  if !isdirectory(expand(a:path))
    call mkdir(expand(a:path))
  endif
endfunction

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

function! MakeViewCheck()
  if &buftype != '' | return 0 | endif
  if expand('%') =~ '\[.*\]' | return 0 | endif
  if empty(glob(expand('%:p'))) | return 0 | endif
  if &modifiable == 0 | return 0 | endif
  if len($TEMP) && expand('%:p:h') == $TEMP | return 0 | endif
  if len($TEMP) && expand('%:p:h') == $TMP | return 0 | endif

  let file_name = expand('%:p')
  for ifiles in g:skipview_files
    if file_name =~ ifiles
      return 0
    endif
  endfor

  return 1
endfunction
""" End Functions =========================

""" NeoBundle Packages ====================
""""""" Core Bundles
NeoBundle 'honza/vim-snippets'
NeoBundle 'Shougo/neosnippet-snippets'
NeoBundle 'Shougo/neosnippet.vim'
  let g:neosnippet#snippets_directory='~/.vim/bundle/vim-snippets/snippets'
  let g:neosnippet#enable_snipmate_compatibility=1
  imap <expr><TAB> neosnippet#expandable_or_jumpable()?"\<Plug>(neosnippet_expand_or_jump)":(pumvisible()?"\<C-n>":"\<TAB>")
  smap <expr><TAB> neosnippet#expandable_or_jumpable()?"\<Plug>(neosnippet_expand_or_jump)":"\<TAB>"
  imap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
  smap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
  " For snippet_complete marker
  if has('conceal')
    set conceallevel=1
    set concealcursor=i
    set listchars+=conceal:Δ
  endif
NeoBundle 'Shougo/neocomplete.vim', {'autoload':{'insert':1}}
  let g:neocomplete#enable_at_startup=1
  let g:neocomplete#data_directory='~/.vim/.cache/neocomplete'
NeoBundle 'Shougo/vimshell'
  let g:vimshell_editor_command='vim'
  let g:vimshell_right_prompt='getcwd()'
  let g:vimshell_data_directory='~/.vim/.cache/vimshell'
  nnoremap <Leader>c :new \| :VimShell<CR>
NeoBundle 'Shougo/vimproc', {'build' : {'unix' : 'make -f make_unix.mak'}}
NeoBundle 'mhinz/vim-startify'
  let g:startify_session_dir = '~/.vim/.cache/sessions'
  let g:startify_change_to_vcs_root = 1
  let g:startify_show_sessions = 1
  nnoremap <F1> :Startify<CR>
NeoBundle 'matchit.zip'
NeoBundle 'bling/vim-airline'
  set laststatus=2 " enable airline even if no splits
  " let g:airline_theme='powerlineish' " 'luna' 'tomorrow' 'powerlineish'
  " let g:Powerline_symbols = 'fancy'
  let g:airline_powerline_fonts  = 1
  let g:airline_detect_paste     = 1
  let g:airline_enable_branch    = 1
  let g:airline_enable_syntastic = 1
  let g:airline_linecolumn_prefix = '␊ '
  let g:airline_linecolumn_prefix = '␤ '
  let g:airline_linecolumn_prefix = '¶ '
  let g:airline_branch_prefix = '⎇ '
  let g:airline_paste_symbol  = 'ρ'
  let g:airline_paste_symbol  = 'Þ'
  let g:airline_paste_symbol  = '∥'
  let g:airline#extensions#tabline#enabled      = 1
  let g:airline#extensions#tabline#left_sep     = ''
  let g:airline#extensions#tabline#left_alt_sep = '¦'
  let g:airline_mode_map = {
    \ 'n' : 'N',
    \ 'i' : 'I',
    \ 'R' : 'REPLACE',
    \ 'v' : 'VISUAL',
    \ 'V' : 'V-LINE',
    \ 'c' : 'CMD ',
    \ '': 'V-BLCK',
    \ }
NeoBundle 'tpope/vim-surround'
NeoBundle 'tpope/vim-repeat'
NeoBundle 'tpope/vim-dispatch'
NeoBundle 'tpope/vim-eunuch'
NeoBundle 'tpope/vim-unimpaired'
  nmap <c-up> [e
  nmap <c-down> ]e
  vmap <c-up> [egv
  vmap <c-down> ]egv
NeoBundle 'bufkill.vim'

""""""" Git Bundles
NeoBundle 'tpope/vim-fugitive'
  nnoremap <silent> <Leader>gs :Gstatus<aR>
  nnoremap <silent> <Leader>gd :Gdiff<CRu
  nnoremap <silent> <Leader>gc :Gcommit<CR>
  nnoremap <silent> <Leader>gb :Gblame<CR>
  nnoremap <silent> <Leader>gl :Glog<CR>
  nnoremap <silent> <Leader>gp :Git push<CR>
  nnoremap <silent> <Leader>gw :Gwrite<CR>
  nnoremap <silent> <Leader>gr :Gremove<CR>
  autocmd BufReadPost fugitive://* set bufhidden=delete
NeoBundle 'gregsexton/gitv', {'depends':['tpope/vim-fugitive'], 'autoload':{'commands':'Gitv'}}
  nnoremap <silent> <Leader>gv :Gitv<CR>
  nnoremap <silent> <Leader>gV :Gitv!<CR>
NeoBundle 'mhinz/vim-signify'
  let g:signify_update_on_bufenter=0

""""""" Editing Bundles
NeoBundle 'editorconfig/editorconfig-vim', {'autoload':{'insert':1}}
NeoBundle 'tpope/vim-endwise'
NeoBundle 'tpope/vim-speeddating'
NeoBundle 'thinca/vim-visualstar'
NeoBundle 'tomtom/tcomment_vim'
NeoBundle 'terryma/vim-expand-region'
  vmap v <Plug>(expand_region_expand)
  vmap <C-v> <Plug>(expand_region_shrink)
NeoBundle 'terryma/vim-multiple-cursors'
NeoBundle 'jiangmiao/auto-pairs'
NeoBundle 'justinmk/vim-sneak'
  let g:sneak#streak=1
NeoBundle 'godlygeek/tabular', {'autoload':{'commands':'Tabularize'}} "{{{
  nmap <Leader>a& :Tabularize /&<CR>
  vmap <Leader>a& :Tabularize /&<CR>
  nmap <Leader>a= :Tabularize /=<CR>
  vmap <Leader>a= :Tabularize /=<CR>
  nmap <Leader>a: :Tabularize /:<CR>
  vmap <Leader>a: :Tabularize /:<CR>
  nmap <Leader>a:: :Tabularize /:\zs<CR>
  vmap <Leader>a:: :Tabularize /:\zs<CR>
  nmap <Leader>a, :Tabularize /,<CR>
  vmap <Leader>a, :Tabularize /,<CR>
  nmap <Leader>a<Bar> :Tabularize /<Bar><CR>
  vmap <Leader>a<Bar> :Tabularize /<Bar><CR>
NeoBundleLazy 'tpope/vim-scriptease', {'autoload':{'filetypes':['vim']}}
NeoBundle 'scrooloose/syntastic'
  let g:syntastic_error_symbol = '✗'
  let g:syntastic_style_error_symbol = '✠'
  let g:syntastic_warning_symbol = '∆'
  let g:syntastic_style_warning_symbol = '≈'
NeoBundle 'Shougo/vinarise.vim'
NeoBundle 'cohama/lexima.vim'

""""""" Navigation Bundles
NeoBundle 'haya14busa/incsearch.vim'
  map / <Plug>(incsearch-forward)
  map ? <Plug>(incsearch-backward)
  map g/ <Plug>(incsearch-stay)
NeoBundle 'rking/ag.vim'
  if executable('ag')
    let g:ackprg = "ag --nogroup --column --smart-case --follow"
  endif
NeoBundleLazy 'mbbill/undotree', {'autoload':{'commands':'UndotreeToggle'}}
  let g:undotree_SplitLocation='botright'
  let g:undotree_SetFocusWhenToggle=1
  nnoremap <silent> <F5> :UndotreeToggle<CR>
NeoBundleLazy 'EasyGrep', {'autoload':{'commands':'GrepOptions'}}
  let g:EasyGrepRecursive=1
  let g:EasyGrepAllOptionsInExplorer=1
  let g:EasyGrepCommand=1
  nnoremap <Leader>vo :GrepOptions<CR>
NeoBundleLazy 'scrooloose/nerdtree', {'autoload':{'commands':['NERDTreeToggle','NERDTreeFind']}}
  let NERDTreeShowHidden=1
  let NERDTreeQuitOnOpen=0
  let NERDTreeShowLineNumbers=1
  let NERDTreeChDirMode=0
  let NERDTreeShowBookmarks=1
  let NERDTreeIgnore=['\.git','\.hg','\.npm','\node_modules','\.rebar']
  let NERDTreeBookmarksFile='~/.vim/.cache/NERDTreeBookmarks'
  nnoremap <F2> :NERDTreeToggle<CR>
  nnoremap <F3> :NERDTreeFind<CR>
NeoBundle 'majutsushi/tagbar', {'autoload':{'commands':'TagbarToggle'}}
  nnoremap <silent> <F9> :TagbarToggle<CR>

""""""" TextObj
NeoBundle 'kana/vim-textobj-user'
NeoBundle 'kana/vim-textobj-indent'
NeoBundle 'kana/vim-textobj-entire'
NeoBundle 'lucapette/vim-textobj-underscore'

""""""" Erlang & Elixir Bundle
NeoBundle 'jimenezrick/vimerl'
  let erlang_folding     = 1
  let erlang_show_errors = 0
  let erlang_skel_header = {'author': 'Hardik Varia <hardikvaria@gmail.com>',
                        \  'owner' : 'Hardik Varia'}
  autocmd FileType erlang setlocal expandtab tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType erlang setlocal cc=80
NeoBundle 'edkolev/erlang-motions.vim'
" NeoBundle 'elixir-lang/vim-elixir.vim'

""""""" Markdown
NeoBundle 'jtratner/vim-flavored-markdown', {'autoload':{'filetypes':['markdown']}}
  let g:markdown_fenced_languages=['ruby', 'javascript', 'elixir', 'clojure', 'sh', 'html', 'sass', 'scss', 'haml']
  autocmd BufNewFile,BufReadPost *.md,*.markdown set filetype=markdown
  autocmd FileType markdown set tw=80

""""""" Web Bundle
NeoBundle 'lukaszb/vim-web-indent', {'autoload':{'filetypes':['html', 'javascript','scss']}}
NeoBundle 'cakebaker/scss-syntax.vim', {'autoload':{'filetypes':['scss','sass']}}
NeoBundle 'hail2u/vim-css3-syntax', {'autoload':{'filetypes':['css','scss','sass']}}
NeoBundle 'ap/vim-css-color', {'autoload':{'filetypes':['css','scss','sass','less','styl']}}
NeoBundle 'othree/html5.vim', {'autoload':{'filetypes':['html']}}
NeoBundle 'gregsexton/MatchTag', {'autoload':{'filetypes':['html','xml']}}
NeoBundle 'mattn/emmet-vim', {'autoload':{'filetypes':['html','xml','xsl','xslt','xsd','css','sass','scss','less','mustache']}}
  function! s:zen_html_tab()
    let line = getline('.')
    if match(line, '<.*>') < 0
      return "\<c-y>,"
    endif
    return "\<c-y>n"
  endfunction
  autocmd FileType xml,xsl,xslt,xsd,css,sass,scss,less,mustache imap <buffer><tab> <c-y>,
  autocmd FileType html imap <buffer><expr><tab> <sid>zen_html_tab()

""""""" Javascript Bundle
NeoBundle 'marijnh/tern_for_vim', {'autoload':{'filetypes':['javascript']},'build':{'unix':'npm install'}}
NeoBundle 'pangloss/vim-javascript', {'autoload':{'filetypes':['javascript']}}
NeoBundle 'jelera/vim-javascript-syntax', {'autoload':{'filetypes':['javascript']}}
  au FileType javascript call JavaScriptFold()
NeoBundle 'maksimr/vim-jsbeautify', {'autoload':{'filetypes':['javascript']}}
  nnoremap <Leader>fjs :call JsBeautify()<CR>
NeoBundle 'othree/javascript-libraries-syntax.vim', {'autoload':{'filetypes':['javascript','coffee','ls','typescript']}}
NeoBundle 'mustache/vim-mustache-handlebars', {'autoload':{'filetypes':['handlebars', 'html']}}
NeoBundle 'mmalecki/vim-node.js', {'autoload':{'filetypes':['javascript']}}
NeoBundle 'Shutnik/jshint2.vim', {'autoload':{'filetypes':['javascript']}}
NeoBundle 'leshill/vim-json', {'autoload':{'filetypes':['javascript','json']}}
NeoBundle 'burnettk/vim-angular', {'autoload':{'filetypes':['javascript','html']}}
  let g:angular_find_ignore = ['build/','dist/']
NeoBundle 'matthewsimo/angular-vim-snippets', {'autoload':{'filetypes':['javascript','html']}}
" sudo npm intall -g jshint html5 etc etc

""""""" Navigation
NeoBundle 'ctrlpvim/ctrlp.vim', { 'depends': 'tacahiroy/ctrlp-funky' }
  let g:ctrlp_clear_cache_on_exit = 1
  let g:ctrlp_follow_symlinks = 1
  let g:ctrlp_max_files = 20000
  let g:ctrlp_cache_dir = s:get_cache_dir('ctrlp')
  let g:ctrlp_reuse_window = 'startify'
  let g:ctrlp_extensions = ['funky']
  let g:ctrlp_match_window_bottom = 1    " Show at bottom of window
  let g:ctrlp_working_path_mode = 'ra'   " Our working path is our VCS project or the current directory
  let g:ctrlp_mru_files = 1              " Enable Most Recently Used files feature
  let g:ctrlp_jump_to_buffer = 2         " Jump to tab AND buffer if already open
  let g:ctrlp_open_new_file = 'v'        " open selections in a vertical split
  let g:ctrlp_open_multiple_files = 'vr' " opens multiple selections in vertical splits to the right
  let g:ctrlp_arg_map = 0
  let g:ctrlp_dotfiles = 0               " do not show (.) dotfiles in match list
  let g:ctrlp_showhidden = 0             " do not show hidden files in match list
  let g:ctrlp_split_window = 0
  let g:ctrlp_max_height = 40            " restrict match list to a maxheight of 40
  let g:ctrlp_working_path_mode = ''
  let g:ctrlp_dont_split = 'NERD_tree_2' " don't split these buffers
  let g:ctrlp_custom_ignore = {
    \ 'dir': '\v[\/]\.(git|hg|svn|gitkeep)$',
    \ 'file': '\v\.(exe|so|dll|log|gif|jpg|jpeg|png|psd|DS_Store|ctags|gitattributes)$'
    \ }
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'
  let g:ctrlp_prompt_mappings = {
    \ 'AcceptSelection("e")': ['<c-e>', '<c-space>'],
    \ 'AcceptSelection("h")': ['<c-x>', '<c-cr>', '<c-s>'],
    \ 'AcceptSelection("t")': ['<c-t>'],
    \ 'AcceptSelection("v")': ['<cr>'],
    \ 'PrtSelectMove("j")': ['<c-j>', '<down>', '<s-tab>'],
    \ 'PrtSelectMove("k")': ['<c-k>', '<up>', '<tab>'],
    \ 'PrtHistory(-1)': ['<c-n>'],
    \ 'PrtHistory(1)': ['<c-p>'],
    \ 'ToggleFocus()': ['<c-tab>'],
    \}
  nmap \ [ctrlp]
  nnoremap [ctrlp] <nop>

  nnoremap [ctrlp]r :CtrlPMRUFiles<cr>
  nnoremap [ctrlp]t :CtrlPBufTag<cr>
  nnoremap [ctrlp]T :CtrlPTag<cr>
  nnoremap [ctrlp]l :CtrlPLine<cr>
  nnoremap [ctrlp]o :CtrlPFunky<cr>
  nnoremap [ctrlp]b :CtrlPBuffer<cr>
NeoBundle 'tpope/vim-vinegar' " navigate up a directory with '-' in netrw, among other things

""""""" Colorscheme
NeoBundle 'chankaward/vim-railscasts-theme'

""""""" Latex
" NeoBundle 'coot/atp_vim'
" NeoBundle 'xuhdev/vim-latex-live-preview'
""" End NeoBundle Packages ================

""" VIM Tweaks ============================
"""""" base
set mouse=a
set mousehide
set history=1000
set ruler
set ttyfast
set viewoptions=folds,options,cursor,unix,slash
set encoding=utf-8
if exists('$TMUX')
  set clipboard=
else
  set clipboard=unnamed
endif
set hidden
set autoread
set nrformats-=octal
set showcmd
set tags=tags;/
set showfulltag
set modeline
set modelines=5
set shell=/usr/bin/zsh
set noshelltemp "use pipes
augroup AutoView
  autocmd!
  " Autosave & Load Views
  autocmd BufWritePost,BufWinLeave ?* if MakeViewCheck() | silent! mkview | endif
  autocmd BufWinEnter ?* if MakeViewCheck() | silent! loadview | endif
augroup END

""""""" whitespace
set backspace=indent,eol,start
set autoindent
set expandtab
set smarttab
let &tabstop=s:settings.default_indent
let &softtabstop=s:settings.default_indent
let &shiftwidth=s:settings.default_indent
set list
set listchars=tab:│\ ,trail:•,extends:❯,precedes:❮
set shiftround
set linebreak
let &showbreak='↪ '

""""""" scroll options
set scrolloff=3
set display+=lastline

""""""" autocomplete list options
set wildmenu
set wildmode=list:full
set wildignorecase
set wildignore+=*/.git/*,*/.hg/*,*/.svn/*,*/.idea/*,*/.DS_Store
set splitbelow
set splitright

""""""" disable sounds
set noerrorbells
set novisualbell
set t_vb=

""""""" searching
set hlsearch
set incsearch
set ignorecase
set smartcase
if executable('ag')
  set grepprg=ag\ --nogroup\ --column\ --smart-case\ --nocolor\ --follow
  set grepformat=%f:%l:%c:%m
endif

""""""" vim file/folder management
""""""" persistant undo
if exists('+undofile')
  set undofile
  let &undodir = s:get_cache_dir('undo')
endif

""""""" backups
set backup
let &backupdir = s:get_cache_dir('backup')

""""""" swap files
let &directory = s:get_cache_dir('swap')
set noswapfile

call EnsureExists(s:cache_dir)
call EnsureExists(&undodir)
call EnsureExists(&backupdir)
call EnsureExists(&directory)

""""""" ui options
set showmatch
set matchtime=2
set number
set lazyredraw
set noshowmode
set foldenable
set foldmethod=syntax
set foldlevelstart=99
let g:xml_syntax_folding=1

set t_Co=256
set background=dark
let &t_AB="\e[48;5;%dm" " Force 256 colors harder
let &t_AF="\e[38;5;%dm"
set t_ut= " improve screen clearing by using the background colour
set term=screen-256color
let $TERM='screen-256color'

if has('gui_running')
  " open maximized
  set guioptions="agimrLt"
  set guioptions-=T

  if has('gui_gtk')
    set gfn=Ubuntu\ Mono\ Bold\ 12
  endif
endif
""" End VIM Tweaks ========================

""" Keyboard shortcuts ====================
""""""" key bindings
let mapleader = ","
let g:mapleader = ","
""""""" formatting shortcuts
nmap <Leader>fef :call Preserve("normal gg=G")<CR>
nmap <Leader>f$ :call StripTrailingWhitespace()<CR>
vmap <Leader>s :sort<CR>
""""""" common actions shortcuts
nnoremap <Leader>q :q<CR>
nnoremap <Leader>w :w<CR>
nnoremap <Leader>o :CtrlP<CR>
nmap <Leader><Leader> V
""""""" toggle paste
map <F6> :set invpaste<CR>:set paste?<cr>
""""""" remap alt keys for navigation
nnoremap <Left> :bprev<CR>
nnoremap <Right> :bnext<CR>
""""""" smash escape
inoremap jk <esc>
inoremap kj <esc>
""""""" Easier to type
noremap H ^
noremap L $
noremap F %
vnoremap L g_
""""""" change cursor position in insert mode
inoremap <C-h> <left>
inoremap <C-l> <right>
inoremap <C-u> <C-g>u<C-u>
""""""" sane regex
nnoremap / /\v
vnoremap / /\v
nnoremap ? ?\v
vnoremap ? ?\v
nnoremap :s/ :s/\v
""""""" command-line window
nnoremap q: q:i
nnoremap q/ q/i
nnoremap q? q?i
""""""" folds
nnoremap zr zr:echo &foldlevel<CR>
nnoremap zm zm:echo &foldlevel<CR>
nnoremap zR zR:echo &foldlevel<CR>
nnoremap zM zM:echo &foldlevel<CR>
""""""" screen line scroll
nnoremap <silent> j gj
nnoremap <silent> k gk
""""""" auto center
nnoremap <silent> n nzz
nnoremap <silent> N Nzz
nnoremap <silent> * *zz
nnoremap <silent> # #zz
nnoremap <silent> g* g*zz
nnoremap <silent> g# g#zz
nnoremap <silent> <C-o> <C-o>zz
nnoremap <silent> <C-i> <C-i>zz
""""""" reselect visual block after indent
vnoremap < <gv
vnoremap > >gv
""""""" reselect last paste
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'
""""""" find current word in quickfix
nnoremap <Leader>fw :execute "vimgrep ".expand("<cword>")." %"<CR>:copen<cr>
""""""" find last search in quickfix
nnoremap <Leader>ff :execute 'vimgrep /'.@/.'/g %'<CR>:copen<cr>
""""""" shortcuts for windows
nnoremap <Leader>v <C-w>v<C-w>l
nnoremap <Leader>s <C-w>s
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
nnoremap <C-k> <C-w>k
nnoremap <C-j> <C-w>j
""""""" tab shortcuts
map <Leader>tn :tabnew<CR>
map <Leader>tc :tabclose<CR>
""""""" quick buffer open
nnoremap gb :ls<CR>:e #
""""""" Close window/buffer function and shortcut
nnoremap <silent> Q :call CloseWindowOrKillBuffer()<CR>
""""""" make Y consistent with C and D. See :help Y
nnoremap Y y$
""""""" toggle list and hlsearch
nmap <Leader>l :set list! list?<CR>
nnoremap <BS> :set hlsearch! hlsearch?<CR>
""""""" Vim Dispatch
nnoremap <Leader>tag :Dispatch ctags -R<CR>
""""""" Move visual block
vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv
""" End Keyboard shortcuts ================


""" Auto Commands =========================
" autocmd
" go back to previous position of cursor if any
autocmd BufReadPost *
  \ if line("'\"") > 1 && line("'\"") <= line("$") |
  \ exe 'normal! g`"zvzz' |
  \ endif
autocmd FileType js,scss,css,erlang autocmd BufWritePre <buffer> call StripTrailingWhitespace()
autocmd FileType css,scss setlocal foldmethod=marker foldmarker={,}
autocmd FileType css,scss nnoremap <silent> <Leader>S vi{:sort<CR>
autocmd FileType markdown setlocal nolist
autocmd FileType vim setlocal fdm=indent keywordprg=:help
autocmd BufNewFile,BufRead relx.config setlocal filetype=erlang
""" End Auto Commands =====================

""" Fin ===================================
call neobundle#end()
filetype plugin indent on
syntax enable
exec 'colorscheme '.s:settings.colorscheme
NeoBundleCheck
