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
g['maplocalleader'] = ";"

-------------------- PACKER  -------------------------------
local execute = vim.api.nvim_command

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
  execute 'packadd packer.nvim'
end

vim.api.nvim_exec(
  [[
  augroup Packer
    autocmd!
    autocmd BufWritePost init.lua PackerCompile
  augroup end
]],
  false
)

-------------------- PLUGINS -------------------------------
require('packer').startup{ function()
  use 'wbthomason/packer.nvim'      -- Let packer manage packer
  use 'alvan/vim-closetag'          -- Close html tags
  use {'akinsho/nvim-bufferline.lua', requires = {'ojroques/nvim-bufdel'}}
  use 'airblade/vim-rooter'
  use 'b3nj5m1n/kommentary'
  use 'cohama/lexima.vim'
  use 'elixir-editors/vim-elixir'
  use 'farmergreg/vim-lastplace'
  use 'haya14busa/is.vim'
  use 'joshdick/onedark.vim'
  use {'ibhagwan/fzf-lua', requires = {'vijaymarupudi/nvim-fzf'}}
  use 'junegunn/vim-easy-align'
  use 'justinmk/vim-gtfo'            -- ,gof open file in filemanager
  use {
    'kyazdani42/nvim-tree.lua',
    requires = 'kyazdani42/nvim-web-devicons',
    config = function() require'nvim-tree'.setup {} end
  }
  use {'kristijanhusak/vim-dadbod-completion', 
    requires = {
      {'tpope/vim-dadbod'},
      {'kyazdani42/nvim-web-devicons'}
    }
  }
  use 'leafOfTree/vim-svelte-plugin'
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require("gitsigns").setup()
    end
  }
  use 'lervag/vimtex'
  use 'machakann/vim-sandwich'       -- sr({ sd' <select text>sa'
  use 'moll/vim-bbye'
  use 'neovim/nvim-lspconfig'
  use 'williamboman/nvim-lsp-installer'
  -- autocomplete and snippets
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      {'hrsh7th/cmp-nvim-lsp'               },
      {'hrsh7th/cmp-buffer'                 },
      {'hrsh7th/cmp-path'                   },
      {'hrsh7th/cmp-vsnip'                  },
      {'hrsh7th/vim-vsnip'                  },
      {'rafamadriz/friendly-snippets'       },
      {'kdheepack/cmp-latex-symbols'      },
      {'hrsh7th/cmp-nvim-lsp-signature-help'}
    }
  }
  use {
    "folke/trouble.nvim",
    requires = "kyazdani42/nvim-web-devicons",
    config = function()
      require("trouble").setup {}
    end
  }
  use 'norcalli/nvim-colorizer.lua'
  use 'norcalli/nvim-terminal.lua'
  use 'nvim-lualine/lualine.nvim'
  use 'ojroques/nvim-lspfuzzy'
  use 'pbrisbin/vim-mkdir'           -- :e this/does/not/exist/file.txt then :w
  use 'phaazon/hop.nvim'
  use 'terryma/vim-smooth-scroll'
  use 'terryma/vim-expand-region'
  use {
    'TimUntersberger/neogit', 
    config = function() require("neogit").setup{} end,
    requires = {'nvim-lua/plenary.nvim'}
  }
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  -- use {'mfussenegger/nvim-dap'}        -- Debug Adapter Protocol
  -- use 'lukas-reineke/indent-blankline.nvim'
  -- use 'dstein64/nvim-scrollview'    -- Show a terminal scroll line on right side
  use 'yamatsum/nvim-cursorline'
end,
  config = {
    display = {
      open_fn = function()
        return require("packer.util").float({border = {"╭", "─", "╮", "│", "╯", "─", "╰", "│"}})
      end,
      working_sym = "",
      error_sym = "",
      done_sym = "",
      moved_sym = ""
    }
  }
}
-------------------- PLUGIN SETUP --------------------------
o.termguicolors = true                    -- True color support
-- bufdel
map('n', '<leader>w', '<cmd>BufDel<CR>')
require('bufdel').setup {next = 'alternate'}
-- closetag
g['closetag_filenames'] = '*.html, *.vue, *.ex, *.eex, *.leex, *.heex, *.svelte'
-- colorizer
require('colorizer').setup {'css'; 'javascript'; html = { mode = 'foreground'; }}
-- fzf
map('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files()<CR>")
map('n', '<leader>o', '<cmd>lua require("fzf-lua").files()<CR>')
map('n', 'gl', '<cmd>lua require("fzf-lua").blines()<CR>')
map('n', '<leader>g', '<cmd>lua require("fzf-lua").git_commits()<CR>')
map('n', '<C-f>', '<cmd>lua require("fzf-lua").grep()<CR>')
map('n', '<leader>b', "<cmd>lua require('fzf-lua').buffers()<CR>")
map('n', '<leader>r', '<cmd>lua require("fzf-lua").oldfiles()<CR>')
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
-- lualine
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    -- component_separators = { left = '', right = ''},
    -- section_separators = { left = '', right = ''},
    component_separators = { "", ""},
    section_separators = { "", ""},
    disabled_filetypes = { "NvimTree", "Telescope" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {'mode', 
    lualine_b = {'branch', 'diff',
                  {'diagnostics', sources={'nvim_lsp'}}},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = {'quickfix', 'nvim-tree', 'fzf'}
}
-- hop
require('hop').setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5 }
map('n', 's', '<cmd>HopChar2<CR>', {noremap=false})
-- indent-blankline
-- g.indentLine_fileTypeExclude = {"json"}
-- g.indentLine_char = "│"
-- kommentary
g['kommentary_create_default_mappings'] = false
map('n', '<leader>cc', '<Plug>kommentary_line_default'  , { noremap = false })
map('n', '<leader>c' , '<Plug>kommentary_motion_default', { noremap = false })
map('v', '<leader>c' , '<Plug>kommentary_visual_default', { noremap = false })
local config = require('kommentary.config')
config.configure_language(
  "default",
  {
    prefer_single_line_comments = true
  }
)
config.configure_language("typescriptreact", {
  hook_function = function()
    pre_comment_hook = require('ts_context_commentstring.internal').update_commentstring()
  end,
  prefer_single_line_comments = true,
})
-- nvim-bufferline
require('bufferline').setup{
  options = {
    show_close_icon = false,
    show_buffer_close_icons = false,
    show_buffer_icons = true,
    -- separator_style = {"", ""},
    -- offsets = {{filetype = "NvimTree", text = "File Explorer", text_align = "center" }},
  },
  -- highlights = {
  --   buffer_selected = { guifg = "", guibg = "" },
  --   fill = { guibg = "#282c34" , guifg = "#282c34" },
  --   buffer_selected = { gui = "bold" },
  --   pick_visible = { guibg = "#282c34", guifg = "#282c34"},
  --   pick= { guibg = "#282c34", guifg = "#282c34"},
  --   buffer_visible = { guibg = "#282c34", guifg = "#3e3e3e"}
  -- }
}
-- nvim-terminal
require('terminal').setup()
-- nvim-tree
require'nvim-tree'.setup {
  auto_close = true;
  nvim_tree_hide_dotfiles = true;
  nvim_tree_gitignore             = 1;
  nvim_tree_group_empty           = 1;
  nvim_tree_disable_window_picker = 1;
}
map('n', '<F2>'  , '<cmd>NvimTreeToggle<CR>')
map('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>')
-- vim-bbye
map('n', '<leader>x', '<cmd>Bdelete<CR>')
-- vim-easy-align
map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})
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
map('n', '<c-e>', ':call smooth_scroll#up(&scroll, 15, 4)<CR>', {silent=true})
map('n', '<c-d>', ':call smooth_scroll#down(&scroll, 15, 4)<CR>', {silent=true})
-- vimtex
g['vimtex_quickfix_mode'] = 0
g['vimtex_compiler_method'] = 'tectonic'
g['vimtex_view_general_viewer'] = 'evince'

-------------------- OPTIONS -------------------------------
local width = 96
cmd 'colorscheme onedark'
-- global options
o.hidden = true                           -- Enable background buffers
o.mouse = 'a'                             -- Allow the mouse 
o.completeopt = 'menu,menuone,noselect'   -- Completion options
o.ignorecase = true                       -- Ignore case
o.joinspaces = false                      -- No double spaces with join
o.scrolloff = 5                           -- Lines of context
o.shiftround = true                       -- Round indent
o.sidescrolloff = 8                       -- Columns of context
o.smartcase = true                        -- Don't ignore case with capitals
o.splitbelow = true                       -- Put new windows below current
o.splitright = true                       -- Put new windows right of current
o.updatetime = 200                        -- Delay before swap file is saved
o.wildmode = 'list:longest'               -- Command-line completion mode
o.shortmess = 'IFc'                       -- Avoid showing extra message on completion
o.showmode = false
o.fillchars = "eob: "
o.inccommand = 'split'
o.backup = false
o.writebackup = false
o.swapfile = false
o.undofile = true
o.undodir = '/home/hvaria/.nvim/undo'
-- window-local options
-- wo.colorcolumn = tostring(width)       -- Line length marker
wo.cursorline = false                     -- Highlight cursor line
wo.list = true                            -- Show some invisible characters
wo.relativenumber = false                 -- Relative line numbers
wo.number = true                          -- Show line numbers
wo.signcolumn = 'yes'                     -- Show sign column
wo.wrap = true                            -- Disable line wrap
wo.foldmethod = 'expr'
wo.foldexpr = 'nvim_treesitter#foldexpr()'
wo.foldlevel = 99
-- buffer-local options
bo.expandtab = true                       -- Use spaces instead of tabs
bo.formatoptions = 'crqnj'                -- Automatic formatting options
bo.shiftwidth = 2                         -- Size of an indent
bo.smartindent = true                     -- Insert indents automatically
bo.tabstop = 2                            -- Number of spaces tabs count for
bo.textwidth = width                      -- Maximum width of text

-------------------- MAPPINGS ------------------------------
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
map('n', 'n', 'nzz', {silent=true})
map('n', 'N', 'Nzz', {silent=true})
map('n', '*', '*zz', {silent=true})
map('n', '#', '#zz', {silent=true})
map('n', 'g*', 'g*zz', {silent=true})
map('n', 'g#', 'g#zz', {silent=true})
map('n', '<C-o>', '<C-o>zz', {silent=true})
map('n', '<C-i>', '<C-i>zz', {silent=true})
-- yank to / paste from system clipboard
map('v', '<leader>y', '"+y')
map('n', '<leader>p', '"+p')
map('n', '<leader>P', '"+P')
map('v', '<leader>p', '"+p')
map('v', '<leader>P', '"+P')
-- reselect visual block after indent
map('v', '<', '<gv')
map('v', '>', '>gv')
-- quick substitue
map('n', '<leader>S', ':%s//gcI<Left><Left><Left><Left>')
map('v', '<leader>S', ':s//gcI<Left><Left><Left><Left>')

-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
  ensure_installed = {"css", "erlang", "elixir", "html", "javascript", "json", "ledger", "lua", "toml", "zig"},
  highlight = {enable = true}, indent = {enable = false} -- indent is experimental
}

-------------------- LSP w/ Compe---------------------------
g.completion_enable_snippet = 'vim-vsnip'
-- A callback that will get called when a buffer connects to the language server.
-- Here we create any key maps that we want to have on that buffer.
local on_attach = function(_, bufnr)
  require 'lsp_signature'.on_attach()

  map('n', '<space>,', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>')
  map('n', '<space>;', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>')
  map("n", "<space>f", "<cmd>lua vim.lsp.buf.formatting()<cr>")
  map("n", "<space>l", "<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<cr>")
  map("n", "<space>d", "<cmd>lua vim.lsp.buf.definition()<cr>")
  map("n", "<space>k", "<cmd>lua vim.lsp.buf.hover()<cr>")
  map("n", "<space>r", "<cmd>lua vim.lsp.buf.references()<cr>")
  map("n", "<space>s", "<cmd>lua vim.lsp.buf.document_symbol()<cr>")
  map("n", "<space>t", "<cmd>lua vim.lsp.buf.type_definition()<cr>")
  map("n", "<space>i", "<cmd>lua vim.lsp.buf.implementation()<cr>")
  map("n", "<space>h", "<cmd>lua vim.lsp.buf.signature_help()<cr>")
  map('n', '<space>re', '<cmd>lua vim.lsp.buf.rename()<CR>')
  map('n', '<space>ca', '<cmd>lua vim.lsp.buf.code_action()<CR>')

  -- Expand
  cmd "imap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'"
  cmd "smap <expr> <C-j> vsnip#expandable() ? '<Plug>(vsnip-expand)' : '<C-j>'"
  -- Expand or jump
  cmd "imap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
  cmd "smap <expr> <C-l> vsnip#available(1) ? '<Plug>(vsnip-expand-or-jump)' : '<C-l>'"
  -- NOTE: Order is important. You can't lazy load lexima.vim
  g['lexima_no_defualt_rules'] = true
  g['lexima_enable_endwise_rules'] = 1
  -- vim.fn.call('lexima#set_default_rules()')
  cmd "inoremap <silent><expr> <c-space> compe#complete()"
  cmd "inoremap <silent><expr> <cr> compe#confirm(lexima#expand('<LT>CR>', 'i'))"
  cmd "inoremap <silent><expr> <C-e> compe#close('<C-e>')"
  cmd "inoremap <silent><expr> <C-f> compe#scroll({ 'delta': +4 })"
  cmd "inoremap <silent><expr> <C-d> compe#scroll({ 'delta': -4 })"
  
  -- Neovim doesn't support snippets out of the box, so we need to mutate the
  -- capabilities we send to the language server to let them know we want snippets.
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = {
      'documentation',
      'detail',
      'additionalTextEdits'
    }
  }
end


-- Setup our autocompletion. These configuration options are the default ones
-- copied out of the documentation.
local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-b>'] = cmp.mapping(cmp.mapping.scroll_docs(-4), {'i', 'c'}),
    ['<C-f>'] = cmp.mapping(cmp.mapping.scroll_docs( 4), {'i', 'c'}),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-y>'] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
    ['<C-e>'] = cmp.mapping({
      i = cmp.mapping.abort(),
      c = cmp.mapping.close(),
    }),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
  },
  sources = cmp.config.sources({
    { name = "path" },
    { name = "buffer" },
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "vsnip" },
    { name = "spell" },
    { name = "tags" },
    { name = "vim_dadbod_completion" },
    { name = "latex_symbols" }
  })
})
-- Use buffer source for `/` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline('/', {
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Setup lspconfig.
local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp.protocol.make_client_capabilities())
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
require('lspconfig')['elixir'].setup {
  capabilities = capabilities
}

-- Tab completion
local t = function(str)
  return vim.api.nvim_replace_termcodes(str, true, true, true)
end

local check_back_space = function()
  local col = vim.fn.col('.') - 1
  return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
end

-- Use (s-)tab to:
--- move to prev/next item in completion menuone
--- jump to prev/next snippet's placeholder
_G.tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-n>"
  elseif vim.fn['vsnip#available'](1) == 1 then
    return t "<Plug>(vsnip-expand-or-jump)"
  elseif check_back_space() then
    return t "<Tab>"
  else
    return vim.fn['compe#complete']()
  end
end
_G.s_tab_complete = function()
  if vim.fn.pumvisible() == 1 then
    return t "<C-p>"
  elseif vim.fn['vsnip#jumpable'](-1) == 1 then
    return t "<Plug>(vsnip-jump-prev)"
  else
    -- If <S-Tab> is not working in your terminal, change it to <C-h>
    return t "<S-Tab>"
  end
end

vim.api.nvim_set_keymap("i", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<Tab>", "v:lua.tab_complete()", {expr = true})
vim.api.nvim_set_keymap("i", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
vim.api.nvim_set_keymap("s", "<S-Tab>", "v:lua.s_tab_complete()", {expr = true})
-- Map compe confirmation and complete functions
-- vim.api.nvim_set_keymap("i", '<cr>', 'comple#confirm("<cr>")', { expr = true })
vim.api.nvim_set_keymap("i", "<CR>", "compe#confirm({ 'keys': '<CR>', 'select': v:true })", { expr = true })
vim.api.nvim_set_keymap("i", '<c-space>', 'comple#complete()', { expr = true })

------------------ LSP-INSTALL -----------------------------
local lsp_installer = require("nvim-lsp-installer")
lsp_installer.on_server_ready(function (server) 
  local opts = {}
  if server.name == "elixir" then
    opts.dialyzerEnabled = true
    opts.fetchDeps = false
  end

  server:setup({
    capabilities = capabilities,
    on_attach = on_attach,
    settings = { elixirLS = opts }
  })
  vim.cmd [[ do User LspAttachBuffers ]]
end)

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
  'TextYankPost * lua vim.highlight.on_yank { hi_group="IncSearch", timeout=150, on_visual=true }',
  'FileType elixir,eelixir iab pp \\|>',
  'BufWritePre *.{ex,exs} lua vim.lsp.buf.formatting()',
  'FileType svelte,html,markdown setlocal wrap',
  "FileType html,markdown,text nnoremap <expr> j v:count ? 'j' : 'gj'",
  "FileType html,markdown,text nnoremap <expr> k v:count ? 'k' : 'gk'",
  "FileType html,markdown,text vnoremap <expr> j v:count ? 'j' : 'gj'",
  "FileType html,markdown,text vnoremap <expr> k v:count ? 'k' : 'gk'"
})
