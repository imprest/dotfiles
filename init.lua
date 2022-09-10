-- Based of https://github.com/ojroques/dotfiles & https://oroques.dev/notes/neovim-init/
-- git clone https://github.com/savq/paq-nvim.git \
--    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
-------------------- HELPERS -------------------------------
local vim = vim
local api, cmd, fn, g, lsp = vim.api, vim.cmd, vim.fn, vim.g, vim.lsp
local o, wo, b, map, autocmd = vim.o, vim.wo, vim.b, vim.keymap.set, vim.api.nvim_create_autocmd
-- local bo = vim.bo

g['loaded_python_provider'] = 1
g['python3_host_prog'] = '/usr/bin/python3'
g['mapleader'] = ','
g['maplocalleader'] = ";"

-------------------- PACKER  -------------------------------
local execute = api.nvim_command

local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({ 'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path })
  execute 'packadd packer.nvim'
end

api.nvim_exec(
  [[
    augroup Packer
      autocmd!
      autocmd BufWritePost init.lua PackerCompile
    augroup end
  ]],
  false
)

-------------------- PLUGINS -------------------------------
local packer = require('packer')
local use = packer.use
packer.startup { function()
  use 'wbthomason/packer.nvim' -- Let packer manage packer
  -- use 'dstein64/vim-startuptime' -- :StartupTime
  -- use 'Shatur/neovim-session-manager'
  -- use 'tanvirtin/monokai.nvim'
  -- use 'navarasu/onedark.nvim'
  use 'cohama/lexima.vim'
  use 'tiagovla/tokyodark.nvim'
  use 'karb94/neoscroll.nvim'
  use 'alvan/vim-closetag' -- Close html tags
  use { 'akinsho/nvim-bufferline.lua', tag = "v2.*", requires = { 'ojroques/nvim-bufdel' } }
  use 'airblade/vim-rooter'
  use 'elixir-editors/vim-elixir'
  use 'farmergreg/vim-lastplace'
  use { 'ibhagwan/fzf-lua', requires = { 'vijaymarupudi/nvim-fzf' } }
  use 'junegunn/vim-easy-align' -- visual select then ga<char> to align
  use 'justinmk/vim-gtfo' -- gof open file in filemanager
  use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
  use { 'kristijanhusak/vim-dadbod-completion', requires = 'tpope/vim-dadbod' }
  use 'leafOfTree/vim-svelte-plugin'
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' },
    config = function()
      require("gitsigns").setup({ current_line_blame = false })
    end
  }
  use 'lervag/vimtex'
  use 'machakann/vim-sandwich' -- sr({ sd' <select text>sa'
  use 'mg979/vim-visual-multi'
  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'b0o/SchemaStore.nvim'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use { 'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      }
    end
  }
  use 'williamboman/nvim-lsp-installer'
  -- autocomplete and snippets
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      { 'windwp/nvim-autopairs' },
      { 'hrsh7th/cmp-nvim-lsp' },
      { 'hrsh7th/cmp-nvim-lua' },
      { 'hrsh7th/cmp-buffer' },
      { 'hrsh7th/cmp-path' },
      { 'L3MON4D3/LuaSnip' },
      { 'saadparwaiz1/cmp_luasnip' },
      { 'rafamadriz/friendly-snippets' },
      { 'ray-x/lsp_signature.nvim' },
      { 'kdheepak/cmp-latex-symbols' },
      { 'onsails/lspkind-nvim' }
    }
  }
  -- lsp-diagnostics
  use 'NvChad/nvim-colorizer.lua'
  use 'nvim-lualine/lualine.nvim'
  use { 'j-hui/fidget.nvim', config = function()
    require('fidget').setup {}
  end }
  use 'olambo/vi-viz'
  use 'pbrisbin/vim-mkdir' -- :e this/does/not/exist/file.txt then :w
  use { 'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  -- use {'mfussenegger/nvim-dap'}        -- Debug Adapter Protocol
  use { 'akinsho/toggleterm.nvim', tag = 'v1.*', config = function()
    require('toggleterm').setup {
      open_mapping = [[<A-t>]],
      shading_factor = 2,
      direction = 'float',
    }
  end }
  use { 'folke/which-key.nvim',
    config = function()
      require("which-key").setup {
        plugins = {
          spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints i.e. z=
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          presets = {
            operators = false, -- adds help for operators like d, y, ...
            motions = false, -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true, -- default bindings on <c-w>
            nav = true, -- misc bindings to work with windows
            z = true, -- bindings for folds, spelling and others prefixed with z
            g = true, -- bindings for prefixed with g
          },
        },
      }
    end
  }
end,
  config = {
    display = { open_fn = function() return require("packer.util").float() end }
  }
}
-------------------- PLUGIN SETUP --------------------------
o.termguicolors = true -- True color support
-- require('onedark').setup { style = 'warmer' }
-- symbols-outline
g.symbols_outline = { highlight_hovered_item = false, auto_preview = false }
-- neoscroll
require('neoscroll').setup()
-- bufferline
require('bufferline').setup {
  options = {
    show_buffer_close_icons = false,
    show_close_icon = false,
    offsets = { { filetype = "NvimTree", padding = 1 } },
    custom_filter = function(buf_number, _) -- hide shell and other unknown ft
      if vim.bo[buf_number].filetype ~= "" then
        return true
      end
    end
  }
}
-- which-key
local wk = require('which-key')
wk.register({
  ["y"] = { '"+y', "Yank System Clipboard" },
  ["."] = { "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", "Comment" }
}, { prefix = "<leader>", mode = 'v' })
wk.register({
  ["w"] = { "<cmd>w!<CR>", "Save" },
  ["q"] = { "<cmd>q!<CR>", "Quit" },
  ["."] = { "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", "Comment" },
  ["x"] = { "<cmd>BufDel<CR>", "Close Buffer" }, -- vim-bbye
  ["gg"] = { '<cmd>TermExec cmd="gitui" direction=float<CR>', "Gitui" },
  ["b"] = { '<cmd>FzfLua buffers<CR>', "Buffers" },
  ["f"] = { '<cmd>FzfLua files<CR>', "Files" },
  ["r"] = { '<cmd>FzfLua oldfiles<CR>', "Recent Files" },
  ["<leader>"] = { '<C-^>', 'Last buffer' },
  ["s"] = { '<cmd>split<CR>', 'Split horizontal' },
  ["v"] = { '<C-w>v<C-w>l', 'Split vertical' },
  ["c"] = { '<cmd>split<bar>res 10 <bar>terminal<CR>', 'Terminal bottom' },
  p = {
    name = 'Packer',
    c = { "<cmd>PackerCompile<cr>", "Compile" },
    i = { "<cmd>PackerInstall<cr>", "Install" },
    s = { "<cmd>PackerSync<cr>", "Sync" },
    S = { "<cmd>PackerStatus<cr>", "Status" },
    u = { "<cmd>PackerUpdate<cr>", "Update" },
  },
  l = {
    name = "LSP",
    I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
    a = { "<cmd>FzfLua lsp_code_actions<cr>", "Code Action" },
    c = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
    D = { "<cmd>FzfLua lsp_document_diagnostics<cr>", "Buffer Diagnostics" },
    f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
    i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Implementation" },
    j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
    k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
    l = { "<cmd>LspInfo<cr>", "Info" },
    t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
    w = { "<cmd>FzfLua lsp_workspace_diagnostics<cr>", "Diagnostics" },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
    r = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    s = { "<cmd>FzfLua lsp_document_symbols<cr>", "Document Symbols" },
    S = { "<cmd>FzfLua lsp_workspace_symbols<cr>", "Workspace Symbols" },
  },
  g = {
    name = "Git",
    f = { "<cmd>FzfLua git_files<cr>", "Git Files" },
    c = { "<cmd>FzfLua git_commits<cr>", "Commits" },
    b = { "<cmd>FzfLua git_bcommits<cr>", "Buffer Commits" },
    B = { "<cmd>FzfLua git_branches<cr>", "Branches" },
    s = { "<cmd>FzfLua git_status<cr>", "Status" },
  },
}, { prefix = "<leader>" })

-- bufdel
require('bufdel').setup { next = 'alternate' }
-- closetag
g['closetag_filenames'] = '*.html, *.vue, *.heex, *.svelte'
-- colorizer
require('colorizer').setup { 'css'; 'javascript'; html = { mode = 'foreground'; } }
-- fzf-lua
g['fzf_action'] = { ['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit' }
require('fzf-lua').setup({
  winopts = {
    preview = { default = 'bat_native' }
  }
})
-- lualine
local window_width_limit = 70
local conditions = {
  buffer_not_empty = function()
    return fn.empty(fn.expand "%:t") ~= 1
  end,
  hide_in_width = function()
    return fn.winwidth(0) > window_width_limit
  end,
  check_git_workspace = function()
    local filepath = vim.fn.expand "%:p:h"
    local gitdir = vim.fn.finddir(".git", filepath .. ";")
    return gitdir and #gitdir > 0 and #gitdir < #filepath
  end,
}
local function diff_source()
  local gitsigns = b.gitsigns_status_dict
  if gitsigns then
    return {
      added = gitsigns.added,
      modified = gitsigns.changed,
      removed = gitsigns.removed,
    }
  end
end

require 'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = 'tokyodark',
    component_separators = { left = '', right = '' },
    section_separators = { left = '', right = '' },
    disabled_filetypes = { "NvimTree", "Telescope", "Outline", "dashboard" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = { { -- mode
      function() return " " end,
      padding = { left = 0, right = 0 }
    } },
    lualine_b = {
      { -- 'branch'
        "b:gitsigns_head",
        icon = "",
        cond = conditions.hide_in_width
      },
      { -- 'filename'
        "filename"
      }
    },
    -- {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {
      { -- 'diff'
        "diff", source = diff_source,
        symbols = { added = " ", modified = " ", removed = " " }
      },
      { 'filesize', cond = conditions.buffer_not_empty },
    },
    lualine_x = {
      { -- 'diagnostics'
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = "  ", warn = "  ", info = "  ", hint = "  " }
      },
      { -- 'treesitter'
        function()
          if next(vim.treesitter.highlighter.active[api.nvim_get_current_buf()]) then
            return ""
          end
          return ""
        end,
        cond = conditions.hide_in_width,
      },
      { -- 'lsp'
        function()
          local msg = ''
          local buf_ft = vim.api.nvim_buf_get_option(0, 'filetype')
          local clients = vim.lsp.get_active_clients()
          if next(clients) == nil then
            return msg
          end
          for _, client in ipairs(clients) do
            local filetypes = client.config.filetypes
            if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
              return client.name
            end
          end
          return msg
        end,
        icon = ' ',
        cond = conditions.hide_in_width,
      },
      { 'encoding' }, { 'fileformat' },
      { "filetype", cond = conditions.hide_in_width } -- color = { fg = colors.fg, bg = colors.bg } },
    },
    lualine_y = {},
    lualine_z = { '%3l:%3c' }
  },
  inactive_sections = {
    lualine_a = { 'filename' },
    lualine_b = {},
    lualine_c = {},
    lualine_x = {},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  extensions = { 'quickfix', 'nvim-tree', 'fzf' }
}
-- nvim-autopairs
require('nvim-autopairs').setup()
-- nvim-tree
require 'nvim-tree'.setup {
  disable_netrw = true,
  ignore_ft_on_setup = { "startify", "dashboard", "alpha" },
  update_focused_file = {
    update_cwd = false,
    ignore_list = {},
  },
  diagnostics = { enable = true },
  git = {
    enable = true,
    ignore = false
  },
  view = {
    width = 24,
    preserve_window_proportions = true
  },
  renderer = {
    group_empty = true,
    icons = { git_placement = "after" },
    highlight_opened_files = "all",
    indent_markers = { enable = true }
  },
  filters = { custom = { "node_modules", ".cache", ".git" } },
  actions = {
    open_file = {
      resize_window = false,
      window_picker = {
        enable = false
      },
    },
  }
}
map('n', '<F2>', '<cmd>NvimTreeToggle<CR>')
map('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>')
-- vi-viz
map('x', 'v', "<cmd>lua require('vi-viz').vizExpand()<CR>")
map('x', 'V', "<cmd>lua require('vi-viz').vizContract()<CR>")
-- vim-easy-align
map('x', 'ga', '<Plug>(EasyAlign)')
map('n', 'ga', '<Plug>(EasyAlign)')
-- vim-dadbod
g['db'] = "postgresql://hvaria:@localhost/mgp_dev"
map('x', '<Plug>(DBExe)', 'db#op_exec()', { expr = true })
map('n', '<Plug>(DBExe)', 'db#op_exec()', { expr = true })
map('n', '<Plug>(DBExeLine)', 'db#op_exec() . \'_\'', { expr = true })
map('x', '<leader>d', '<Plug>(DBExe)')
map('n', '<leader>d', '<Plug>(DBExe)')
map('o', '<leader>d', '<Plug>(DBExe)')
map('n', '<leader>dd', '<Plug>(DBExeLine)')
-- vim-svelte
g['vim_svelte_plugin_use_typescript'] = 1
g['vim_svelte_plugin_use_sass']       = 1
g['vim_svelte_plugin_use_foldexpr']   = 1
-- vimtex
g['vimtex_quickfix_mode']             = 0
g['vimtex_compiler_method']           = 'tectonic'
g['vimtex_view_general_viewer']       = 'evince'
-------------------- OPTIONS -------------------------------
local width                           = 96
-- cmd 'colorscheme onedark'
cmd 'colorscheme tokyodark'
o.background = 'dark'
-- global options
o.guicursor = 'i-ci-ve:ver25,r-cr:hor20,o:hor50' --,a:blinkon1'
o.laststatus = 3 -- global statusline
o.timeoutlen = 300 -- mapping timeout
o.hidden = true -- Enable background buffers
o.mouse = 'a' -- Allow the mouse
o.completeopt = 'menu,menuone,noselect' -- Completion options
o.ignorecase = true -- Ignore case
o.joinspaces = false -- No double spaces with join
o.scrolloff = 3 -- Lines of context
o.scrolljump = 1 -- min. lines to scroll
o.shiftround = true -- Round indent
o.sidescrolloff = 8 -- Columns of context
o.smartcase = true -- Don't ignore case with capitals
o.splitbelow = true -- Put new windows below current
o.splitright = true -- Put new windows right of current
o.updatetime = 200 -- Delay before swap file is saved
o.shortmess = 'IFc' -- Avoid showing extra message on completion
o.showbreak = '↪  '
o.showmode = false
o.showmatch = true
o.equalalways = false -- I don't like my windows changing all the time
o.fillchars = 'eob: '
o.inccommand = 'split'
o.backup = false
o.writebackup = false
o.swapfile = false
o.undofile = true
o.undodir = '/home/hvaria/.nvim/undo'
o.wildmode = "longest:full"
o.wildoptions = 'pum'
o.updatetime = 1000 -- make updates faster
o.wrap = true
o.breakindent = true
o.showbreak = '↪  '
o.linebreak = true
-- window-local options
wo.cursorline = false -- Highlight cursor line
wo.list = true -- Show some invisible characters
wo.listchars = "tab:▸ ,extends:>,precedes:<"
wo.relativenumber = true -- Relative line numbers
wo.number = true -- Show line numbers
wo.signcolumn = 'yes' -- Show sign column
wo.foldmethod = 'indent'
wo.foldlevel = 99
wo.foldenable = true
-- buffer-local options
o.tabstop = 2 -- Number of spaces tabs count for
o.shiftwidth = 2 -- Size of an indent
o.softtabstop = 2
o.expandtab = true -- Use spaces instead of tabs
o.formatoptions = 'cqn1j' -- Automatic formatting options
o.smartindent = true -- Insert indents automatically
o.textwidth = width -- Maximum width of text

-------------------- MAPPINGS ------------------------------
-- common tasks
map('n', '<C-s>', '<cmd>update<CR>')
-- map('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files({ winopts = { preview = { hidden = 'hidden' } } })<CR>")
map('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files()<CR>")
map('n', '<BS>', '<cmd>nohlsearch<CR>')
map('v', '<BS>', '<ESC>')
map('n', '<F4>', '<cmd>set spell!<CR>')
map('n', '<F5>', '<cmd>ColorizerToggle<CR>')
map('n', '<F6>', '<cmd>SymbolsOutline<CR>')
map('i', '<C-u>', '<C-g>u<C-u>') -- Delete lines in insert mode
map('i', '<C-w>', '<C-g>u<C-w>') -- Delete words in insert mode
map('n', '<C-f>', '<cmd>FzfLua grep<CR>')
map('n', '<C-b>', '<cmd>FzfLua blines<CR>')
map('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>')
-- move lines up/down
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
map('v', '<A-j>', ':m \'>+1<CR>gv=gv')
map('v', '<A-k>', ':m \'<-2<CR>gv=gv')
-- Escape
map('i', 'jk', '<ESC>', { noremap = false })
map('t', 'jk', '<ESC>', { noremap = false })
map('t', '<ESC>', '&filetype == "fzf" ? "\\<ESC>" : "\\<C-\\>\\<C-n>"', { expr = true })
-- Navigation & Window management
map('n', 'q', '<C-w>c')
map('n', 'H', '^')
map('n', 'L', 'g_')
map('n', 'F', '%')
map('v', 'L', 'g_')
map('n', 'S', '<cmd>bn<CR>')
map('n', 'X', '<cmd>bp<CR>')
map('n', '<Right>', '<cmd>BufferLineCycleNext<CR>')
map('n', '<Left>', '<cmd>BufferLineCyclePrev<CR>')
map('t', '<C-h>', '<C-\\><C-N><C-w>h')
map('t', '<C-j>', '<C-\\><C-N><C-w>j')
map('t', '<C-k>', '<C-\\><C-N><C-w>k')
map('t', '<C-l>', '<C-\\><C-N><C-w>l')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<M-Left>', '<C-w>2<')
map('n', '<M-Up>', '<C-w>2-')
map('n', '<M-Down>', '<C-w>2+')
map('n', '<M-Right>', '<C-w>2>')
map('n', 'n', 'nzz', { silent = true })
map('n', 'N', 'Nzz', { silent = true })
map('n', '*', '*zz', { silent = true })
map('n', '#', '#zz', { silent = true })
map('n', 'g*', 'g*zz', { silent = true })
map('n', 'g#', 'g#zz', { silent = true })
map('n', '<C-o>', '<C-o>zz', { silent = true })
map('n', '<C-i>', '<C-i>zz', { silent = true })
-- reselect visual block after indent
map('v', '<', '<gv')
map('v', '>', '>gv')
-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
  ensure_installed = {
    "css", "html", "javascript", "json", "svelte", "typescript",
    "erlang", "elixir", "eex", "heex",
    "ledger", "lua", "toml", "zig"
  },
  context_commentstring = { enable = true, enable_autocmd = false },
  highlight = { enable = true }, indent = { enable = false } -- indent is experimental
}

------------------ LSP-INSTALL & CONFIG --------------------
-- ref: https://github.com/wookayin/dotfiles/blob/master/nvim/lua/config/lsp.lua
-- lsp_diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
o.updatetime = 250
vim.diagnostic.config({
  -- virtual_text = false
  virtual_text = { prefix = '' }
})
cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]]
-- lsp_signature
local on_attach_lsp_signature = function(_, _)
  require('lsp_signature').on_attach({
    toggle_key = '<M-x>', -- Press <Alt-x> to toggle signature on and off.
  })
end
-- Customize LSP behavior
local on_attach = function(client, bufnr)
  -- Always use signcolumn for the current buffer
  wo.signcolumn = 'yes:1'

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap = true, silent = true, buffer = bufnr }
  vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gs', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)

  -- Activate LSP signature on attach.
  on_attach_lsp_signature(client, bufnr)

  -- keybindings
  -- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
  -- NOTE: Order is important. You can't lazy load lexima.vim
  g['lexima_no_defualt_rules'] = true
  g['lexima_enable_endwise_rules'] = 1
end

require("nvim-lsp-installer").setup {}
local lspconfig = require("lspconfig")
local capabilities = lsp.protocol.make_client_capabilities()

lspconfig.elixirls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities),
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false
    }
  }
}
lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities),
  settings = { Lua = { diagnostics = { globals = { "vim" } } } }
}
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities),
  settings = { json = {
    schemas = require('schemastore').json.schemas(),
    validate = { enable = true }
  } }
}
for _, server in ipairs { "tailwindcss", "svelte", "tsserver" } do
  lspconfig[server].setup {
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').update_capabilities(capabilities)
  }
end

-------------------------
-- LSP Handlers (general)
-------------------------
-- :help lsp-method
-- :help lsp-handler

local lsp_handlers_hover = lsp.with(lsp.handlers.hover, {
  border = 'single'
})
lsp.handlers["textDocument/hover"] = function(err, result, ctx, config)
  local bufnr, winnr = lsp_handlers_hover(err, result, ctx, config)
  if winnr ~= nil then
    api.nvim_win_set_option(winnr, "winblend", 0) -- opacity for hover
  end
  return bufnr, winnr
end

-------------------- LSP w/ Cmp-----------------------------
-- Setup our autocompletion. These configuration options are the default ones
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require 'cmp'
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
local lspkind = require('lspkind')
cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol',
      maxwidth = 50,
      menu = {
        buffer   = "[buf]",
        nvim_lsp = "[lsp]",
        nvim_lua = "[api]",
        path     = "[path]",
        luasnip  = "[snip]",
      },
    })
  },
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = {
    ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior.Insert },
    ["<C-d>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<c-y>"] = cmp.mapping(
      cmp.mapping.confirm {
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      },
      { "i", "c" }
    ),
    ["<c-space>"] = cmp.mapping {
      i = cmp.mapping.complete(),
      c = function(
        _ --[[fallback]]
      )
        if cmp.visible() then
          if not cmp.confirm { select = true } then
            return
          end
        else
          cmp.complete()
        end
      end,
    },
    -- Testing
    ["<c-q>"] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end,
    ["<S-Tab>"] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end,
  },
  sources = cmp.config.sources({
    { name = "luasnip", keyword_length = 2 },
    { name = "nvim_lua", keyword_length = 2 },
    { name = "nvim_lsp", keyword_length = 2 },
    { name = "path", keyword_length = 2 },
    { name = "buffer", keyword_length = 5 },
    { name = "spell" },
    { name = "tags" },
    { name = "latex_symbols" }
  })
})
--- Luasnip
local ls = require('luasnip')
require("luasnip.loaders.from_lua").load({ paths = "~/dotfiles/snippets/" })
ls.config.set_config({
  history = true, -- keep around last snippet local to jump back
  updateevents = "TextChanged,TextChangedI", -- update changes as you type
  enable_autosnippets = true,
  ext_opts = {
    [require("luasnip.util.types").choiceNode] = {
      active = { virt_text = { { "·", "Question" } } }
    }
  }
})
vim.keymap.set({ "i", "s" }, "<a-k>", function() -- my expansion key
  if ls.expand_or_jumpable() then ls.expand_or_jump() end
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<a-j>", function() -- my jump backwords key
  if ls.jumpable(-1) then ls.jump(-1) end
end, { silent = true })
vim.keymap.set({ "i" }, "<a-l>", function() -- select within list of options
  if ls.choice_active() then ls.change_choice(1) end
end)

-------------------- COMMANDS ------------------------------
function Init_Term()
  cmd 'setlocal nonumber norelativenumber'
  cmd 'setlocal nospell'
  cmd 'setlocal signcolumn=auto'
  cmd 'startinsert'
end

local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
autocmd("TextYankPost",
  { pattern = "*",
    command = 'silent! lua vim.highlight.on_yank({ hi_group="IncSearch", timeout=200, on_visual=true})',
    group = group })
autocmd("FileType",
  { pattern = "sql,mysql,plsql",
    command = 'lua require("cmp").setup.buffer({ sources = {{ name = "vim-dadbod-completion"}}})', group = group })
autocmd("BufEnter", {
  nested = true,
  callback = function()
    if #vim.api.nvim_list_wins() == 1 and vim.api.nvim_buf_get_name(0):match("NvimTree_") ~= nil then
      vim.cmd "quit"
    end
  end,
  group = group
})

local term_group = vim.api.nvim_create_augroup("TermGroup", { clear = true })
autocmd("BufEnter", { pattern = "term://*", command = 'startinsert', group = term_group })
autocmd("TermOpen", { pattern = "*", callback = Init_Term, group = term_group })

local elixir_group = vim.api.nvim_create_augroup("ElixirGroup", { clear = true })
autocmd("FileType", { pattern = "elixir,eelixir", command = 'iab pp \\|>', group = elixir_group })

local lsp_group = vim.api.nvim_create_augroup("LSPGroup", { clear = true })
autocmd("BufWritePre", { pattern = "*.{ex,exs,heex}", command = 'lua vim.lsp.buf.formatting_sync()', group = lsp_group })
autocmd("BufWritePre",
  { pattern = "*.{svelte,css,scss,js,ts,json}", command = 'lua vim.lsp.buf.formatting_sync()', group = lsp_group })
autocmd("BufWritePre",
  { pattern = "*.{lua}", command = 'lua vim.lsp.buf.formatting_sync()', group = lsp_group })
