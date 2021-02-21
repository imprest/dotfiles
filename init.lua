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
paq {'airblade/vim-gitgutter'}
paq {'airblade/vim-rooter'}
paq {'dstein64/nvim-scrollview'}
paq {'elixir-editors/vim-elixir'}
paq {'joshdick/onedark.vim'}
paq {'junegunn/fzf'}
paq {'junegunn/fzf.vim'}
paq {'justinmk/vim-gtfo'}            -- ,gof open file in filemanager
paq {'kristijanhusak/vim-dadbod-completion'}
paq {'kyazdani42/nvim-web-devicons'}
paq {'kyazdani42/nvim-tree.lua'}
paq {'lervag/vimtex'}
paq {'machakann/vim-sandwich'}       -- sr({ sd' <select text>sa'
-- paq {'mfussenegger/nvim-dap'}        -- Debug Adapter Protocol
paq {'neovim/nvim-lspconfig'}
paq {'norcalli/nvim-colorizer.lua'}
paq {'nvim-lua/completion-nvim'}
paq {'nvim-treesitter/nvim-treesitter'}
paq {'ojroques/nvim-bufdel'}
paq {'ojroques/nvim-lspfuzzy'}
paq {'pbrisbin/vim-mkdir'}           -- :e this/does/not/exist/file.txt then :w
paq {'savq/paq-nvim', opt = true}    -- paq-nvim manages itself
paq {'slashmili/alchemist.vim'}
paq {'steelsojka/completion-buffers'}
paq {'terryma/vim-smooth-scroll'}
paq {'tpope/vim-commentary'}
paq {'tpope/vim-fugitive'}
paq {'tpope/vim-dadbod'}
paq {'vim-airline/vim-airline'}
paq {'vim-airline/vim-airline-themes'}

-------------------- PLUGIN SETUP --------------------------
-- bufdel
map('n', '<leader>w', '<cmd>BufDel<CR>')
require('bufdel').setup {next = 'alternate'}
-- colorizer
require('colorizer').setup {'css'; 'javascript'; html = { mode = 'foreground'; }}
-- dirvish
g['dirvish_mode'] = [[:sort ,^.*[\/],]]
-- elixir
g['alchemist_tag_disable'] = 1
-- fzf
map('n', '<C-p>', '<cmd>Files<CR>')
map('n', '<leader>g', '<cmd>Commits<CR>')
map('n', '<leader>p', '<cmd>Rg<CR>')
map('n', 's', '<cmd>Buffers<CR>')
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
-- vim-sandwich
cmd 'runtime macros/sandwich/keymap/surround.vim'
-- vim-smooth-scroll
map('n', '<C-e>', '<C-u>')
map('n', '<C-u>', '<C-e>')
map('n', '<c-e>', ':call smooth_scroll#up(&scroll, 15, 2)<CR>')
map('n', '<c-d>', ':call smooth_scroll#down(&scroll, 15, 2)<CR>')
-- vimtex
g['vimtex_quickfix_mode'] = 0
g['vimtex_view_method'] = 'evince'
-- vim-airline
g['airline_theme'] = 'onedark'
g['airline_section_z'] = '%3l:%2c' -- '%3l:%2c %3p%%'
g['airline_powerline_fonts'] = 1
g['airline_left_sep'] = ''
g['airline_right_sep'] = ''
g['airline#parts#ffenc#skip_expected_string'] = 'utf-8[unix]'
g['airline_skip_empty_sections'] = 1
g['airline_exclude_preview'] = 1
g['airline#extensions#tabline#enabled'] = 1
g['airline#extensions#tabline#left_sep'] = ''
g['airline#extensions#tabline#left_alt_sep'] = ''

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
o.scrolloff = 4                           -- Lines of context
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
o.undodir ='$HOME/.data/undofile'
o.undofile = true
o.undolevels = 1000
o.undoreload = 1000
-- window-local options
wo.colorcolumn = tostring(width)          -- Line length marker
wo.cursorline = false                     -- Highlight cursor line
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
map('', '<leader>c', '"+y')
map('i', '<C-u>', '<C-g>u<C-u>')
map('i', '<C-w>', '<C-g>u<C-w>')
map('i', '<S-Tab>', 'pumvisible() ? "\\<C-p>" : "\\<S-Tab>"', {expr = true})
map('i', '<Tab>', 'pumvisible() ? "\\<C-n>" : "\\<Tab>"', {expr = true})
map('i', 'jk', '<ESC>')
map('n', '<C-s>', ':w<CR>')
map('n', '<C-l>', '<cmd>nohlsearch<CR>')
map('n', '<F3>', '<cmd>lua toggle_wrap()<CR>')
map('n', '<F4>', '<cmd>set spell!<CR>')
map('n', '<F5>', '<cmd>checktime<CR>')
map('n', '<F6>', '<cmd>set scrollbind!<CR>')
map('n', '<S-Down>', '<C-w>2<')
map('n', '<S-Left>', '<C-w>2-')
map('n', '<S-Right>', '<C-w>2+')
map('n', '<S-Up>', '<C-w>2>')
map('n', '<leader><Down>', '<cmd>cclose<CR>')
map('n', '<leader><Left>', '<cmd>cprev<CR>')
map('n', '<leader><Right>', '<cmd>cnext<CR>')
map('n', '<leader><Up>', '<cmd>copen<CR>')
map('n', '<leader>i', '<cmd>conf qa<CR>')
map('n', '<leader>o', 'm`o<Esc>0D``')
map('n', '<leader>s', ':%s//gcI<Left><Left><Left><Left>')
map('n', '<leader>t', '<cmd>terminal<CR>')
map('n', '<leader>u', '<cmd>update<CR>')
map('n', 'Q', '<cmd>lua warn_caps()<CR>')
map('n', 'S', '<cmd>bn<CR>')
map('n', 'U', '<cmd>lua warn_caps()<CR>')
map('n', 'X', '<cmd>bp<CR>')
map('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>')
map('t', '<ESC>', '&filetype == "fzf" ? "\\<ESC>" : "\\<C-\\>\\<C-n>"' , {expr = true})
map('t', 'jk', '<ESC>', {noremap = false})
map('v', '<leader>s', ':s//gcI<Left><Left><Left><Left>')

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
map('n', '<space>h', '<cmd>lua vim.lsp.buf.hover()<CR>')
map('n', '<space>m', '<cmd>lua vim.lsp.buf.rename()<CR>')
map('n', '<space>r', '<cmd>lua vim.lsp.buf.references()<CR>')
map('n', '<space>s', '<cmd>lua vim.lsp.buf.document_symbol()<CR>')

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
  opt('w', 'breakindent', not vim.wo.breakindent)
  opt('w', 'linebreak', not vim.wo.linebreak)
  opt('w', 'wrap', not vim.wo.wrap)
end

vim.tbl_map(function(c) cmd(string.format('autocmd %s', c)) end, {
  'TermOpen * lua init_term()',
  'TextYankPost * lua vim.highlight.on_yank {on_visual = false, timeout = 200}',
})
