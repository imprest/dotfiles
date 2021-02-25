-- Based of https://github.com/ojroques/dotfiles & https://oroques.dev/notes/neovim-init/
-- git clone https://github.com/savq/paq-nvim.git \
--    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
-------------------- HELPERS -------------------------------
local api, cmd, fn, g = vim.api, vim.cmd, vim.fn, vim.g
local o, wo, bo = vim.o, vim.wo, vim.bo

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

g['loaded_python_provider'] = 1
g['python3_host_prog'] = '/usr/bin/python3'
g['mapleader'] = ","

-------------------- PLUGINS -------------------------------
cmd 'packadd paq-nvim'               -- load the package manager
local paq = require('paq-nvim').paq  -- a convenient alias
paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
paq {'alvan/vim-closetag'}
paq {'akinsho/nvim-bufferline.lua'}
paq {'airblade/vim-gitgutter'}
paq {'airblade/vim-rooter'}
paq {'b3nj5m1n/kommentary'}
paq {'cohama/lexima.vim'}
paq {'dstein64/nvim-scrollview'}
paq {'elixir-editors/vim-elixir'}
paq {'farmergreg/vim-lastplace'}
paq {'joshdick/onedark.vim'}
paq {'junegunn/fzf'}
paq {'junegunn/fzf.vim'}
paq {'junegunn/vim-easy-align'}
paq {'justinmk/vim-gtfo'}            -- ,gof open file in filemanager
paq {'kristijanhusak/vim-dadbod-completion'}
paq {'kyazdani42/nvim-web-devicons'}
paq {'kyazdani42/nvim-tree.lua'}
paq {'lervag/vimtex'}
paq {'machakann/vim-sandwich'}       -- sr({ sd' <select text>sa'
paq {'mattn/emmet-vim'}
-- paq {'mfussenegger/nvim-dap'}        -- Debug Adapter Protocol
paq {'moll/vim-bbye'}
paq {'neovim/nvim-lspconfig'}
paq {'norcalli/nvim-colorizer.lua'}
paq {'norcalli/nvim-terminal.lua'}
paq {'nvim-lua/completion-nvim'}
paq {'nvim-treesitter/nvim-treesitter'}
paq {'nvim-treesitter/completion-treesitter'}
paq {'ojroques/nvim-bufdel'}
paq {'ojroques/nvim-hardline'}
paq {'ojroques/nvim-lspfuzzy'}
paq {'pbrisbin/vim-mkdir'}           -- :e this/does/not/exist/file.txt then :w
paq {'slashmili/alchemist.vim'}
paq {'steelsojka/completion-buffers'}
paq {'terryma/vim-smooth-scroll'}
paq {'tpope/vim-dadbod'}
paq {'tpope/vim-fugitive'}
paq {'Yggdroot/indentLine'}

-------------------- PLUGIN SETUP --------------------------
-- bufdel
map('n', '<leader>w', '<cmd>BufDel<CR>')
require('bufdel').setup {next = 'alternate'}
-- closetag
g['closetag_filenames'] = '*.html, *.vue, *.ex, *.eex, *.leex'
-- colorizer
require('colorizer').setup {'css'; 'javascript'; html = { mode = 'foreground'; }}
-- completion-nvim
g['completion_trigger_keyword_length'] = 2
g['completion_confirm_key'] = ""
map('i','<CR>','pumvisible() ? complete_info()["selected"] != "-1" ? "\\<Plug>(completion_confirm_completion)" : "\\<c-e>\\<CR>" : "\\<CR>"', {expr = true})
-- elixir
g['alchemist_tag_disable'] = 1
-- emmet
map('i', '<C-e>', '<C-y>,', {noremap=false, silent=true})
-- fzf
map('n', '<C-p>', '<cmd>Files<CR>')
map('n', '<leader>g', '<cmd>Commits<CR>')
map('n', '<C-f>', '<cmd>Rg<CR>')
map('n', 's', '<cmd>Buffers<CR>')
map('n', '<leader>m', '<cmd>History<CR>')
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
-- hardline
local fmt = string.format
local function pad(c, m)
  local padch = ' '
  return string.rep(padch, string.len(tostring(m)) - string.len(tostring(c)))
end
local function get_line()
  local nbline = fn.line('$')
  local line = fn.line('.')
  return fmt('%s%d', pad(line, nbline), line)
end
local function get_column()
  local col = fn.col('.')
  return fmt('%s%d', pad(col, 10), col)
end
local function get_item()
  return table.concat({'',get_line(), ':', get_column()})
end
require('hardline').setup {
  sections = {
    {class = 'mode', item = require('hardline.parts.mode').get_item},
    {class = 'high', item = require('hardline.parts.git').get_item, hide = 80},
    '%<',
    {class = 'med', item = require('hardline.parts.filename').get_item},
    {class = 'med', item ='%='},
    {class = 'low', item = require('hardline.parts.wordcount').get_item, hide = 80},
    {class = 'error', item = require('hardline.parts.lsp').get_error},
    {class = 'warning', item = require('hardline.parts.lsp').get_warning},
    {class = 'high', item = require('hardline.parts.filetype').get_item, hide = 80},
    {class = 'mode', item = get_item},
  },
}
-- kommentary
g['kommentary_create_default_mappings'] = false
map('n', '<leader>cc', '<Plug>kommentary_line_default', { noremap = false })
map('n', '<leader>c', '<Plug>kommentary_motion_default', { noremap = false })
map('v', '<leader>c', '<Plug>kommentary_visual_default', { noremap = false })
require('kommentary.config').setup()
-- nvim-bufferline
require('bufferline').setup{highlights = {buffer_selected = {gui = ""}}}
-- nvim-terminal
require('terminal').setup()
-- nvim-tree
map('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>')
g['nvim_tree_width'] = 26
-- vim-bbye
map('n', 'Q', '<cmd>Bdelete<CR>')
-- vim-easy-align
map('x', 'ga', '<Plug>(EasyAlign)', {noremap=false})
-- vim-dadbod
g['db'] = "postgresql://hvaria:@localhost/mgp_dev"
map('x', '<Plug>(DBExe)', 'db#op_exec()', {expr=true})
map('n', '<Plug>(DBExe)', 'db#op_exec()', {expr=true})
map('n', '<Plug>(DBExeLine)', 'db#op_exec() . \'_\'', {expr=true})
map('x', '<leader>p', '<Plug>(DBExe)', {noremap=false})
map('n', '<leader>p', '<Plug>(DBExe)', {noremap=false})
map('o', '<leader>p', '<Plug>(DBExe)', {noremap=false})
map('n', '<leader>p', '<Plug>(DBExeLine)', {noremap=false})
-- vim-sandwich
cmd 'runtime macros/sandwich/keymap/surround.vim'
-- vim-smooth-scroll
map('n', '<C-e>', '<C-u>')
map('n', '<C-u>', '<C-e>')
map('n', '<c-e>', ':call smooth_scroll#up(&scroll, 15, 2)<CR>', {silent=true})
map('n', '<c-d>', ':call smooth_scroll#down(&scroll, 15, 2)<CR>', {silent=true})
-- vimtex
g['vimtex_quickfix_mode'] = 0
g['vimtex_view_method'] = 'evince'

-------------------- OPTIONS -------------------------------
local indent = 2
local width = 96
cmd 'colorscheme onedark'
-- global options
o.hidden = true                           -- Enable background buffers
o.mouse = 'a'                             -- Allow the mouse 
o.completeopt = 'menuone,noinsert,noselect'  -- Completion options
o.ignorecase = true                       -- Ignore case
o.joinspaces = false                      -- No double spaces with join
o.pastetoggle = '<F2>'                    -- Paste mode
o.scrolloff = 5                           -- Lines of context
o.shiftround = true                       -- Round indent
o.sidescrolloff = 8                       -- Columns of context
o.smartcase = true                        -- Don't ignore case with capitals
o.splitbelow = true                       -- Put new windows below current
o.splitright = true                       -- Put new windows right of current
o.termguicolors = true                    -- True color support
o.updatetime = 200                        -- Delay before swap file is saved
o.wildmode = 'list:longest'               -- Command-line completion mode
o.backup = false
o.writebackup = false
o.swapfile = false
-- o.undodir = '~/.data/undofile'
o.undofile = true
-- window-local options
wo.colorcolumn = tostring(width)          -- Line length marker
wo.cursorline = true                      -- Highlight cursor line
wo.list = true                            -- Show some invisible characters
wo.number = true                          -- Show line numbers
wo.relativenumber = false                 -- Relative line numbers
wo.signcolumn = 'yes'                     -- Show sign column
wo.wrap = false                           -- Disable line wrap
-- buffer-local options
bo.expandtab = true                       -- Use spaces instead of tabs
bo.formatoptions = 'crqnj'                -- Automatic formatting options
bo.shiftwidth = indent                    -- Size of an indent
bo.smartindent = true                     -- Insert indents automatically
bo.tabstop = indent                       -- Number of spaces tabs count for
bo.textwidth = width                      -- Maximum width of text

-------------------- MAPPINGS ------------------------------
-- completion
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
map('i', '<Tab>','<Plug>(completion_smart_tab)', {noremap = false})
map('i', '<S-Tab>','<Plug>(completion_smart_s_tab)', {noremap = false})
-- common tasks
map('n', '<C-s>', '<cmd>update<CR>')
map('n', '<BS>', '<cmd>nohlsearch<CR>')
map('n', '<F3>', '<cmd>lua toggle_wrap()<CR>')
map('n', '<F4>', '<cmd>set spell!<CR>')
map('n', '<leader>t', '<cmd>split<bar>res 10 <bar>terminal<CR>')
map('i', '<C-u>', '<C-g>u<C-u>')
map('i', '<C-w>', '<C-g>u<C-w>')
-- move lines up/down
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
map('v', '<A-j>', ':m \'>+1<CR>gv=gv')
map('v', '<A-k>', ':m \'<-2<CR>gv=gv')
-- Escape
map('i', 'jk', '<ESC>')
map('t', 'jk', '<ESC>', {noremap = false})
map('t', '<ESC>', '&filetype == "fzf" ? "\\<ESC>" : "\\<C-\\>\\<C-n>"' , {expr = true})
-- Navigation & Window management
map('n', 'q', '<C-w>c')
map('n', '<leader>s', '<cmd>split<CR>')
map('n', '<leader>v', '<C-w>v<C-w>l')
map('n', 'H', '^')
map('n', 'L', 'g_')
map('n', 'F', '%')
map('v', 'L', 'g_')
map('n', '<leader><leader>', '<C-^>')
map('n', 'S', '<cmd>bn<CR>')
map('n', 'X', '<cmd>bp<CR>')
map('n', '<Right>', '<cmd>bn<CR>')
map('n', '<Left>', '<cmd>bp<CR>')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<S-Right>', '<C-w>2<')
map('n', '<S-Up>', '<C-w>2-')
map('n', '<S-Down>', '<C-w>2+')
map('n', '<S-Left>', '<C-w>2>')
map('n', '<leader><Down>', '<cmd>cclose<CR>')
map('n', '<leader><Left>', '<cmd>cprev<CR>')
map('n', '<leader><Right>', '<cmd>cnext<CR>')
map('n', '<leader><Up>', '<cmd>copen<CR>')
-- yank to system clipboard
map('', '<leader>y', '"+y')
-- reselect visual block after indent
map('v', '<', '<gv')
map('v', '>', '>gv')
-- quick substitue
map('n', '<leader>r', ':%s//gcI<Left><Left><Left><Left>')
map('v', '<leader>r', ':s//gcI<Left><Left><Left><Left>')

-------------------- LSP -----------------------------------
local lsp = require('lspconfig')
local lspfuzzy = require('lspfuzzy')
local on_attach = function(_, bufnr) require('completion').on_attach() end
local lspconfigs = {
  elixirls = {on_attach = on_attach, cmd = {"/home/hvaria/elixir-ls/language_server.sh"}},
}
for ls, cfg in pairs(lspconfigs) do lsp[ls].setup(cfg) end
lspfuzzy.setup {}
map('n', '<space>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
map('n', '<space>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
map('n', '<space>d', '<cmd>lua vim.lsp.buf.definition()<CR>')
map('n', '<space>f', '<cmd>lua vim.lsp.buf.formatting()<CR>')
map('n', '<space>k', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<space>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')
map('n', '<space>t', '<cmd>lua vim.lsp.buf.type_definition()<CR>')

-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
  ensure_installed = {"css", "erlang", "html", "javascript", "json", "ledger", "lua", "toml"},
  highlight = {enable = true}, indent = {enable = true}
}

-------------------- COMMANDS ------------------------------
function init_term()
  cmd 'setlocal nonumber norelativenumber'
  cmd 'setlocal nospell'
  cmd 'setlocal signcolumn=auto'
  cmd 'startinsert'
end

function toggle_wrap()
  wo.breakindent = not wo.breakindent
  wo.linebreak = not wo.linebreak
  wo.wrap = not wo.wrap
end

vim.tbl_map(function(c) cmd(string.format('autocmd %s', c)) end, {
  'TermOpen * lua init_term()',
  'TextYankPost * lua vim.highlight.on_yank {on_visual = false, timeout = 200}',
  'FileType elixir,eelixir iab pp \\|>',
  'FileType elixir,eelixir setlocal omnifunc=v:lua.vim.lsp.omnifunc',
  'FileType elixir,eelixir nnoremap <silent><buffer> <s-k> :call alchemist#exdoc()<bar>wincmd L<bar>vert res 84<bar>set nonumber<CR>',
  'BufWritePre *.{ex,exs} lua vim.lsp.buf.formatting_sync()',
  'FileType sql setlocal omnifunc=vim_dadbod_completion#omni',
  'BufEnter * lua require\'completion\'.on_attach()'
})
