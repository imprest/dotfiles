-- Based of https://github.com/ojroques/dotfiles & https://oroques.dev/notes/neovim-init/
-- git clone https://github.com/savq/paq-nvim.git \
--    "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/pack/paqs/opt/paq-nvim
-------------------- HELPERS -------------------------------
local vim = vim
local api, cmd, fn, g, lsp = vim.api, vim.cmd, vim.fn, vim.g, vim.lsp
local o, wo, b = vim.o, vim.wo, vim.b
-- local bo = vim.bo

local function map(mode, lhs, rhs, opts)
  local options = {noremap = true, silent = true}
  if opts then options = vim.tbl_extend('force', options, opts) end
  api.nvim_set_keymap(mode, lhs, rhs, options)
end

g['loaded_python_provider'] = 1
g['python3_host_prog'] = '/usr/bin/python3'
g['mapleader'] = ' '
g['maplocalleader'] = ","

-------------------- PACKER  -------------------------------
local execute = api.nvim_command

local install_path = fn.stdpath('data')..'/site/pack/packer/start/packer.nvim'

if fn.empty(fn.glob(install_path)) > 0 then
  fn.system({'git', 'clone', 'https://github.com/wbthomason/packer.nvim', install_path})
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
packer.startup{ function()
  use 'wbthomason/packer.nvim'      -- Let packer manage packer
  use 'alvan/vim-closetag'          -- Close html tags
  use {'akinsho/nvim-bufferline.lua', requires = {'ojroques/nvim-bufdel'}}
  use 'airblade/vim-rooter'
  -- use 'cohama/lexima.vim'
  use 'elixir-editors/vim-elixir'
  use 'farmergreg/vim-lastplace'
  use 'haya14busa/is.vim'
  use 'Shatur/neovim-session-manager'
  -- use 'tanvirtin/monokai.nvim'
  -- use 'navarasu/onedark.nvim'
  use 'LunarVim/onedarker.nvim'
  use {'ibhagwan/fzf-lua', requires = {'vijaymarupudi/nvim-fzf'}}
  use 'junegunn/vim-easy-align'      -- visual select then ga<char> to align
  use 'justinmk/vim-gtfo'            -- ,gof open file in filemanager
  use { 'kyazdani42/nvim-tree.lua', requires = 'kyazdani42/nvim-web-devicons' }
  use {'kristijanhusak/vim-dadbod-completion', requires = 'tpope/vim-dadbod' }
  use 'leafOfTree/vim-svelte-plugin'
  use {
    'lewis6991/gitsigns.nvim',
    requires = {'nvim-lua/plenary.nvim'},
    config = function()
      require("gitsigns").setup({ current_line_blame = false })
    end
  }
  use 'lervag/vimtex'
  use 'machakann/vim-sandwich'       -- sr({ sd' <select text>sa'
  -- lsp
  use 'neovim/nvim-lspconfig'
  use 'b0o/SchemaStore.nvim'
  use 'JoosepAlviste/nvim-ts-context-commentstring'
  use {'numToStr/Comment.nvim',
    config = function()
      require('Comment').setup {
        pre_hook = function(ctx)
          local U = require 'Comment.utils'

          local location = nil
          if ctx.ctype == U.ctype.block then
            location = require('ts_context_commentstring.utils').get_cursor_location()
          elseif ctx.cmotion == U.cmotion.v or ctx.cmotion == U.cmotion.V then
            location = require('ts_context_commentstring.utils').get_visual_start_location()
          end

          return require('ts_context_commentstring.internal').calculate_commentstring {
            key = ctx.ctype == U.ctype.line and '__default' or '__multiline',
            location = location,
          }
        end,
      }
    end
  }
  use 'williamboman/nvim-lsp-installer'
  -- autocomplete and snippets
  use {
    'hrsh7th/nvim-cmp',
    requires = {
      {'windwp/nvim-autopairs'               },
      {'hrsh7th/cmp-nvim-lsp'                },
      {'hrsh7th/cmp-nvim-lua'                },
      {'hrsh7th/cmp-buffer'                  },
      {'hrsh7th/cmp-path'                    },
      {'hrsh7th/cmp-vsnip'                   },
      {'hrsh7th/vim-vsnip'                   },
      {'rafamadriz/friendly-snippets'        },
      {'ray-x/lsp_signature.nvim'            },
      {'kdheepak/cmp-latex-symbols'          },
      {'hrsh7th/cmp-nvim-lsp-document-symbol'},
      {'onsails/lspkind-nvim'}
    }
  }
  -- lsp-diagnostics
  use 'NvChad/nvim-colorizer.lua'
  use 'nvim-lualine/lualine.nvim'
  use 'olambo/vi-viz'
  use 'ojroques/nvim-lspfuzzy'
  use 'pbrisbin/vim-mkdir'           -- :e this/does/not/exist/file.txt then :w
  use 'phaazon/hop.nvim'
  use {'nvim-treesitter/nvim-treesitter', run = ':TSUpdate' }
  -- use {'mfussenegger/nvim-dap'}        -- Debug Adapter Protocol
  use 'akinsho/toggleterm.nvim'
  use 'simrat39/symbols-outline.nvim'
  use {'folke/which-key.nvim',
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
o.termguicolors = true                    -- True color support
-- bufferline
local function diagnostics_indicator(_, _, diagnostics)
  local result = {}
  local symbols = { error = "", warning = "", info = "" }
  for name, count in pairs(diagnostics) do
    if symbols[name] and count > 0 then
      table.insert(result, symbols[name] .. " " .. count)
    end
  end
  result = table.concat(result, " ")
  return #result > 0 and result or ""
end
require('bufferline').setup{
  options = {
    close_command = "BufDel",
    diagnostics = 'nvim_lsp',
    diagnostics_indicator = diagnostics_indicator,
    show_close_icon = false,
    seperator_style = 'thin',
    offsets = {
      {
        filetype = "NvimTree",
        text = "",
        padding = 1,
      }
    }
  }
}
-- toggleterm
local terminal = require('toggleterm')
terminal.setup{
  open_mapping = [[<c-t>]],
  shading_factor = 2,
  direction = 'float',
}
-- which-key
local wk = require('which-key')
wk.register({
  ["S"] = { ':s//gcI<Left><Left><Left><Left>', "Substitue" },
  ["y"] = { '"+y', "Yank System Clipboard" },
  ["/"] = { "<ESC><CMD>lua require('Comment.api').toggle_linewise_op(vim.fn.visualmode())<CR>", "Comment" }
}, { prefix = "<leader>", mode = 'v' })
wk.register({
  ["w"] = { "<cmd>w!<CR>", "Save" },
  ["q"] = { "<cmd>q!<CR>", "Quit" },
  ["/"] = { "<cmd>lua require('Comment.api').toggle_current_linewise()<CR>", "Comment" },
  ["c"] = { "<cmd>BufDel<CR>", "Close Buffer" }, -- vim-bbye
  ["gg"] = { '<cmd>TermExec cmd="gitui" direction=float<CR>', "Gitui" },
  ["b"] = { '<cmd>FzfLua buffers<CR>', "Buffers" },
  ["f"] = { '<cmd>FzfLua files<CR>', "Files" },
  ["r"] = { '<cmd>FzfLua oldfiles<CR>', "Recent Files" },
  ["j"] = { '<cmd>HopChar2<CR>', "Hop" },
  ["S"] = { ':%s//gcI<Left><Left><Left><Left>', "Substitue" },
  ["<leader>"] = { '<C-^>', 'Last buffer' },
  ["s"] = { '<cmd>split<CR>', 'Split horizontal' },
  ["v"] = { '<C-w>v<C-w>l', 'Split vertical' },
  ["t"] = { '<cmd>split<bar>res 10 <bar>terminal<CR>', 'Terminal bottom' },
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
    a = { "<cmd>FzfLua lsp_code_actions<cr>", "Code Action" },
    d = { "<cmd>FzfLua lsp_document_diagnostics<cr>", "Buffer Diagnostics" },
    w = { "<cmd>FzfLua lsp_workspace_diagnostics<cr>", "Diagnostics" },
    f = { "<cmd>lua vim.lsp.buf.formatting()<cr>", "Format" },
    i = { "<cmd>LspInfo<cr>", "Info" },
    I = { "<cmd>LspInstallInfo<cr>", "Installer Info" },
    j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
    k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
    l = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    p = {
      name = "Peek",
      d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
      t = { "<cmd>lua vim.lsp.buf.type_definition()<cr>", "Type Definition" },
      i = { "<cmd>lua vim.lsp.buf.implementation()<cr>", "Implementation" },
    },
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
require('bufdel').setup {next = 'alternate'}
-- closetag
g['closetag_filenames'] = '*.html, *.vue, *.ex, *.eex, *.leex, *.heex, *.svelte'
-- colorizer
require('colorizer').setup {'css'; 'javascript'; html = { mode = 'foreground'; }}
-- fzf-lua
g['fzf_action'] = {['ctrl-s'] = 'split', ['ctrl-v'] = 'vsplit'}
require('fzf-lua').setup({
  winopts = {
    preview = { default = 'bat_native' }
  }
})
-- lualine
local colors = {
  bg = "#282c34",
  fg = "#bbc2cf",
  yellow = "#ECBE7B",
  cyan = "#008080",
  darkblue = "#081633",
  green = "#98be65",
  orange = "#FF8800",
  violet = "#a9a1e1",
  magenta = "#c678dd",
  purple = "#c678dd",
  blue = "#51afef",
  red = "#ec5f67",
}
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
local custom_auto = require'lualine.themes.auto'
-- Change the background of lualine_c section for all modes
custom_auto.normal.c.bg = colors.bg
custom_auto.insert.c.bg = colors.bg
custom_auto.visual.c.bg = colors.bg
custom_auto.command.c.bg = colors.bg
require'lualine'.setup {
  options = {
    icons_enabled = true,
    theme = custom_auto,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = { "NvimTree", "Telescope", "Outline", "dashboard" },
    always_divide_middle = true,
  },
  sections = {
    lualine_a = {{ -- mode
      function() return " " end,
      padding = { left = 0, right = 0 },
      color = {},
      cond = nil,
    }},
    lualine_b = {
      { -- 'branch'
        "b:gitsigns_head",
        icon = "",
        color = { gui = "bold", bg = colors.bg },
        cond = conditions.hide_in_width,
      },
      { -- 'filename'
        "filename",
        color = { bg = colors.bg },
        cond = nil,
      }
    },
    -- {'diagnostics', sources={'nvim_diagnostic'}}},
    lualine_c = {
      { -- 'diff'
        "diff",
        source = diff_source,
        symbols = { added = " ", modified = " ", removed = " " },
        diff_color = {
          added = { fg = colors.green, bg = colors.bg },
          modified = { fg = colors.yellow, bg = colors.bg },
          removed = { fg = colors.red, bg = colors.bg },
        },
        color = {},
        cond = nil,
      },
      { 'filesize', cond = conditions.buffer_not_empty },
    },
    lualine_x = {
      { -- 'diagnostics'
        "diagnostics",
        sources = { "nvim_diagnostic" },
        symbols = { error = " ", warn = " ", info = " ", hint = " " },
        color = { bg = colors.bg },
        cond = nil
      },
      { -- 'treesitter'
        function()
          -- local b = vim.api.nvim_get_current_buf()
          if next(vim.treesitter.highlighter.active[b]) then
            return ""
          end
          return ""
        end,
        color = { fg = colors.green, bg = colors.bg },
        cond = conditions.hide_in_width,
      },
      { -- 'lsp'
        function()
          local msg = 'No Active Lsp'
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
        icon = '',
        color = { bg = colors.bg, gui = "bold" },
        cond = conditions.hide_in_width,
      },
      { "filetype", cond = conditions.hide_in_width, color = { fg = colors.fg, bg = colors.bg } },
    },
    lualine_y = {},
    lualine_z = {
      {
        function()
          local current_line = fn.line "."
          local total_lines = fn.line "$"
          local chars = { "__", "▁▁", "▂▂", "▃▃", "▄▄", "▅▅", "▆▆", "▇▇", "██" }
          local line_ratio = current_line / total_lines
          local index = math.ceil(line_ratio * #chars)
          return chars[index]
        end,
        padding = { left = 1, right = 0 },
        color = { fg = colors.yellow, bg = colors.bg },
        cond = nil,
      },
    }
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
  extensions = {'quickfix', 'nvim-tree', 'fzf'}
}
-- hop
require('hop').setup { keys = 'etovxqpdygfblzhckisuran', term_seq_bias = 0.5 }
-- nvim-autopairs
require('nvim-autopairs').setup()
-- nvim-tree
require'nvim-tree'.setup {
  disable_netrw = true,
  ignore_ft_on_setup = { "startify","dashboard", "alpha" },
  update_focused_file = {
    enable = true,
    update_cwd = true,
    ignore_list = {},
  },
  git = {
    enable = true,
    ignore = false,
    timeout = 200,
  },
  view = { width = 24 },
  filters = {
    dotfiles = false,
    custom = { "node_modules", ".cache" , ".git"},
  },
  actions = {
    open_file = {
      window_picker = {
        enable = false
      },
    },
  },
  show_icons = {
    git = 1,
    folders = 1,
    files = 1,
    folder_arrows = 1,
  },
  git_hl = 1,
  root_folder_modifier = ":t",
  icons = {
    default = "",
    symlink = "",
    git = {
      unstaged = "",
      staged = "S",
      unmerged = "",
      renamed = "➜",
      deleted = "",
      untracked = "U",
      ignored = "◌",
    },
    folder = {
      default = "",
      open = "",
      empty = "",
      empty_open = "",
      symlink = "",
    },
  }
}
map('n', '<F2>'  , '<cmd>NvimTreeToggle<CR>')
map('n', '<C-\\>', '<cmd>NvimTreeToggle<CR>')
-- vi-viz
map('x','v', "<cmd>lua require('vi-viz').vizExpand()<CR>", {noremap = true})
map('x','V', "<cmd>lua require('vi-viz').vizContract()<CR>", {noremap = true})
-- vim-easy-align
map('x', 'ga', '<Plug>(EasyAlign)', {noremap = false})
map('n', 'ga', '<Plug>(EasyAlign)', {noremap = false})
-- vim-dadbod
g['db'] = "postgresql://hvaria:@localhost/mgp_dev"
map('x', '<Plug>(DBExe)', 'db#op_exec()', {expr=true})
map('n', '<Plug>(DBExe)', 'db#op_exec()', {expr=true})
map('n', '<Plug>(DBExeLine)', 'db#op_exec() . \'_\'', {expr=true})
-- map('x', '<leader>p', '<Plug>(DBExe)', {noremap=false})
-- map('n', '<leader>p', '<Plug>(DBExe)', {noremap=false})
-- map('o', '<leader>p', '<Plug>(DBExe)', {noremap=false})
-- map('n', '<leader>p', '<Plug>(DBExeLine)', {noremap=false})
-- vim-svelte
g['vim_svelte_plugin_use_typescript'] = 1
g['vim_svelte_plugin_use_sass']       = 1
g['vim_svelte_plugin_use_foldexpr']   = 1
-- vimtex
g['vimtex_quickfix_mode'] = 0
g['vimtex_compiler_method'] = 'tectonic'
g['vimtex_view_general_viewer'] = 'evince'
-------------------- OPTIONS -------------------------------
local width = 96
cmd 'colorscheme onedarker'
o.background = 'dark'
-- global options
o.guicursor = 'i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon1'
o.timeoutlen = 300                        -- mapping timeout
o.hidden = true                           -- Enable background buffers
o.mouse = 'a'                             -- Allow the mouse
o.completeopt = 'menu,menuone,noselect'   -- Completion options
o.ignorecase = true                       -- Ignore case
o.joinspaces = false                      -- No double spaces with join
o.scrolloff = 1                           -- Lines of context
o.scrolljump = 5                          -- min. lines to scroll
o.shiftround = true                       -- Round indent
o.sidescrolloff = 8                       -- Columns of context
o.smartcase = true                        -- Don't ignore case with capitals
o.splitbelow = true                       -- Put new windows below current
o.splitright = true                       -- Put new windows right of current
o.updatetime = 200                        -- Delay before swap file is saved
o.shortmess = 'IFc'                       -- Avoid showing extra message on completion
o.showbreak = '↪ '
o.showmode = false
o.fillchars = "eob: "
o.inccommand = 'split'
o.backup = false
o.writebackup = false
o.swapfile = false
o.undofile = true
o.undodir = '/home/hvaria/.nvim/undo'
-- window-local options
wo.cursorline = false                     -- Highlight cursor line
wo.list = true                            -- Show some invisible characters
wo.relativenumber = false                 -- Relative line numbers
wo.number = true                          -- Show line numbers
wo.signcolumn = 'yes'                     -- Show sign column
wo.wrap = false                           -- Disable line wrap
wo.foldmethod = 'expr'
wo.foldexpr = 'nvim_treesitter#foldexpr()'
wo.foldlevel = 9
-- buffer-local options
o.tabstop = 2                             -- Number of spaces tabs count for
o.expandtab = true                        -- Use spaces instead of tabs
o.formatoptions = 'crqnj1'                -- Automatic formatting options
o.shiftwidth = 2                          -- Size of an indent
o.smartindent = true                      -- Insert indents automatically
o.textwidth = width                       -- Maximum width of text

-------------------- MAPPINGS ------------------------------
-- common tasks
map('n', '<C-s>', '<cmd>update<CR>')
map('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files({ winopts = { preview = { hidden = 'hidden' } } })<CR>")
map('n', '<BS>', '<cmd>nohlsearch<CR>')
map('v', '<BS>', '<ESC>')
map('n', '<F3>', '<cmd>lua Toggle_Wrap()<CR>')
map('n', '<F4>', '<cmd>set spell!<CR>')
map('n', '<F5>', '<cmd>ColorizerToggle<CR>')
map('n', '<F6>', '<cmd>SymbolsOutline<CR>')
map('i', '<C-u>', '<C-g>u<C-u>') -- Delete lines in insert mode
map('i', '<C-w>', '<C-g>u<C-w>') -- Delete words in insert mode
map('n', '<C-f>', '<cmd>FzfLua grep<CR>')
map('n', '<C-b>', '<cmd>FzfLua blines<CR>')
-- move lines up/down
map('n', '<A-j>', ':m .+1<CR>==')
map('n', '<A-k>', ':m .-2<CR>==')
map('i', '<A-j>', '<Esc>:m .+1<CR>==gi')
map('i', '<A-k>', '<Esc>:m .-2<CR>==gi')
map('v', '<A-j>', ':m \'>+1<CR>gv=gv')
map('v', '<A-k>', ':m \'<-2<CR>gv=gv')
-- Escape
map('i', 'jk', '<ESC>', {noremap = false})
map('t', 'jk', '<ESC>', {noremap = false})
map('t', '<ESC>', '&filetype == "fzf" ? "\\<ESC>" : "\\<C-\\>\\<C-n>"' , {expr = true})
-- Navigation & Window management
map('n', 'q', '<C-w>c')
map('n', 'H', '^')
map('n', 'L', 'g_')
map('n', 'F', '%')
map('v', 'L', 'g_')
map('n', 'S', '<cmd>bn<CR>')
map('n', 'X', '<cmd>bp<CR>')
map('n', '<Right>', '<cmd>bn<CR>')
map('n', '<Left>', '<cmd>bp<CR>')
map('t', '<C-h>', '<C-\\><C-N><C-w>h')
map('t', '<C-j>', '<C-\\><C-N><C-w>j')
map('t', '<C-k>', '<C-\\><C-N><C-w>k')
map('t', '<C-l>', '<C-\\><C-N><C-w>l')
map('n', '<C-h>', '<C-w>h')
map('n', '<C-j>', '<C-w>j')
map('n', '<C-k>', '<C-w>k')
map('n', '<C-l>', '<C-w>l')
map('n', '<S-Right>', '<C-w>2<')
map('n', '<S-Up>', '<C-w>2-')
map('n', '<S-Down>', '<C-w>2+')
map('n', '<S-Left>', '<C-w>2>')
map('n', 'n', 'nzz')
map('n', 'N', 'Nzz')
map('n', '*', '*zz')
map('n', '#', '#zz')
map('n', 'g*', 'g*zz')
map('n', 'g#', 'g#zz')
map('n', '<C-o>', '<C-o>zz')
map('n', '<C-i>', '<C-i>zz')
-- reselect visual block after indent
map('v', '<', '<gv')
map('v', '>', '>gv')
-------------------- TREE-SITTER ---------------------------
local ts = require 'nvim-treesitter.configs'
ts.setup {
  ensure_installed = {"css", "erlang", "elixir", "html", "javascript", "json", "ledger", "lua", "toml", "zig"},
  context_commentstring = { enable = true, enable_autocmd = false },
  highlight = {enable = true}, indent = {enable = false} -- indent is experimental
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
  virtual_text = false
  -- virtual_text = { prefix = '●'}
})
cmd [[autocmd! CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false, scope="cursor"})]]
-- lsp_signature
local on_attach_lsp_signature = function(_, _)
  require('lsp_signature').on_attach({
      bind = true, -- This is mandatory, otherwise border config won't get registered.
      floating_window = true,
      handler_opts = {
        border = "single"
      },
      zindex = 99,     -- <100 so that it does not hide completion popup.
      fix_pos = false, -- Let signature window change its position when needed, see GH-53
      toggle_key = '<M-x>',  -- Press <Alt-x> to toggle signature on and off.
    })
end

-- Customize LSP behavior
local on_attach = function(client, bufnr)
  -- Always use signcolumn for the current buffer
  wo.signcolumn = 'yes:1'

  -- Activate LSP signature on attach.
  on_attach_lsp_signature(client, bufnr)

  -- keybindings
  -- https://github.com/neovim/nvim-lspconfig#keybindings-and-completion
  -- NOTE: Order is important. You can't lazy load lexima.vim
  -- g['lexima_no_defualt_rules'] = true
  -- g['lexima_enable_endwise_rules'] = 1
end

local lsp_installer = require("nvim-lsp-installer")
local enhance_server_opts = {
  ["elixirls"] = function(opts)
    opts.settings = {
      elixirLS = {
        dialyzerEnabled = false,
        fetchDeps = false
      }
    }
  end,
  ["jsonls"] = function(opts)
    opts.settings = {
      json = {
        schemas = require('schemastore').json.schemas()
      }
    }
  end
}
lsp_installer.on_server_ready(function(server)
  local opts = {
    on_attach = on_attach,
    -- Suggested configuration by nvim-cmp
    capabilities = require('cmp_nvim_lsp').update_capabilities(lsp.protocol.make_client_capabilities())
  }

  if enhance_server_opts[server.name] then
    -- Enhance the default opts with the server-specific ones
    enhance_server_opts[server.name](opts)
  end

  -- This setup() function is exactly the same as lspconfig's setup function (:help lspconfig-quickstart)
  server:setup(opts)
  cmd [[ do User LspAttachBuffers ]]
end)

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
    api.nvim_win_set_option(winnr, "winblend", 20)  -- opacity for hover
  end
  return bufnr, winnr
end

-------------------- LSP w/ Cmp-----------------------------
-- Setup our autocompletion. These configuration options are the default ones
-- copied out of the documentation.
local has_words_before = function()
  local line, col = unpack(api.nvim_win_get_cursor(0))
  return col ~= 0 and api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

local feedkey = function(key, mode)
  api.nvim_feedkeys(api.nvim_replace_termcodes(key, true, true, true), mode, true)
end

local cmp_autopairs = require('nvim-autopairs.completion.cmp')
local cmp = require'cmp'
cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
local lspkind = require('lspkind')
cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol'
    })
  },
  snippet = {
    expand = function(args)
      fn["vsnip#anonymous"](args.body)
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
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif fn["vsnip#available"](1) == 1 then
        feedkey("<Plug>(vsnip-expand-or-jump)", "")
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function()
      if cmp.visible() then
        cmp.select_prev_item()
      elseif fn["vsnip#jumpable"](-1) == 1 then
        feedkey("<Plug>(vsnip-jump-prev)", "")
      end
    end, { "i", "s" }),
  },
  sources = cmp.config.sources({
    { name = "nvim_lsp" },
    { name = "nvim_lua" },
    { name = "nvim_lsp_document_symbol" },
    { name = "vsnip" },
    { name = "path" },
    { name = "buffer", keyword_length = 3 },
    { name = "spell" },
    { name = "tags" },
    { name = "vim_dadbod_completion" },
    { name = "latex_symbols" }
  })
})


-------------------- COMMANDS ------------------------------
function Init_Term()
  cmd 'setlocal nonumber norelativenumber'
  cmd 'setlocal nospell'
  cmd 'setlocal signcolumn=auto'
  cmd 'startinsert'
end

function Toggle_Wrap()
  wo.breakindent = not wo.breakindent
  wo.linebreak = not wo.linebreak
  wo.wrap = not wo.wrap
end

vim.tbl_map(function(c) cmd(string.format('autocmd %s', c)) end, {
  'TermOpen * lua Init_Term()',
  'TextYankPost * silent! lua vim.highlight.on_yank({ hi_group="IncSearch", timeout=150, on_visual=true })',
  'FileType elixir,eelixir iab pp \\|>',
  'BufWritePre *.{ex,exs,heex} lua vim.lsp.buf.formatting_sync()',
  'BufWritePre *.{svelte,css,scss} lua vim.lsp.buf.formatting_sync()',
  'BufWritePre *.{js,ts,json} lua vim.lsp.buf.formatting_sync()',
  "FileType sql,mysql,plsql lua require('cmp').setup.buffer({ sources = {{ name = 'vim-dadbod-completion' }} })"
})
