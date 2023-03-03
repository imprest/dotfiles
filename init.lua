-- Based of https://github.com/LazyVim/LazyVim
-------------------- HELPERS -------------------------------
local api, cmd, fn, g, lsp = vim.api, vim.cmd, vim.fn, vim.g, vim.lsp
local opt, wo, b, map, autocmd = vim.opt, vim.wo, vim.b, vim.keymap.set, vim.api.nvim_create_autocmd
-- local bo = vim.bo

g['loaded_python_provider'] = 1
g['python3_host_prog'] = '/usr/bin/python3'
g.mapleader = ','
g.maplocalleader = ';'

-------------------- LAZY.NVIM -----------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------- PLUGINS -------------------------------
require('lazy').setup({
    {
      "folke/which-key.nvim",
      lazy = true,
      opts = {
        plugins = {
          spelling = { enabled = true, suggestions = 20 }, -- use which-key for spelling hints i.e. z=
          -- the presets plugin, adds help for a bunch of default keybindings in Neovim
          -- No actual key bindings are created
          presets = {
            operators = false,    -- adds help for operators like d, y, ...
            motions = false,      -- adds help for motions
            text_objects = false, -- help for text objects triggered after entering an operator
            windows = true,       -- default bindings on <c-w>
            nav = true,           -- misc bindings to work with windows
            z = true,             -- bindings for folds, spelling and others prefixed with z
            g = true,             -- bindings for prefixed with g
          },
        }
      }
    },
    {
      'NvChad/nvim-colorizer.lua',
      cmd = 'ColorizerToggle',
      opts = { 'css', 'javascript', html = { mode = 'foreground', } }
    }, -- lazy-load on a command
    -- session management
    {
      "folke/persistence.nvim",
      event = "BufReadPre",
      opts = { options = { "buffers", "curdir", "tabpages", "winsize", "help", "globals" } },
      -- stylua: ignore
      keys = {
        {
          "<leader>qs",
          function() require("persistence").load() end,
          desc =
          "Restore Session"
        },
        {
          "<leader>ql",
          function() require("persistence").load({ last = true }) end,
          desc =
          "Restore Last Session"
        },
        {
          "<leader>qd",
          function() require("persistence").stop() end,
          desc =
          "Don't Save Current Session"
        },
      },
    },
    {
      "NTBBloodbath/doom-one.nvim",
      lazy = false,       -- make sure we load this during startup if it is your main colorscheme
      priority = 1000,    -- make sure to load this before all the other start plugins
      config = function() -- load the colorscheme here
        vim.cmd([[colorscheme doom-one]])
      end,
    },
    {
      'akinsho/bufferline.nvim',
      event = "VeryLazy",
      version = "v3.*",
      dependencies = { "ojroques/nvim-bufdel" },
      opts = {
        -- run require("bufferline.nvim").setup({ highlights = { fill = "#ee44f5" } })
        highlights = { fill = { bg = "" } },
        options = {
          always_show_bufferline = true,
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
    },
    'airblade/vim-rooter',
    'elixir-editors/vim-elixir',
    { 'ethanholz/nvim-lastplace', config = true },
    'farmergreg/vim-lastplace',
    { 'ibhagwan/fzf-lua',         dependencies = { 'vijaymarupudi/nvim-fzf' } },
    'williamboman/mason.nvim',
    'williamboman/mason-lspconfig.nvim',
    -- snippets
    {
      "L3MON4D3/LuaSnip",
      --[[ build = (not jit.os:find("Windows"))
          and "echo -e 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
          or nil, ]]
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      opts = {
        history = true,
        delete_check_events = "TextChanged",
      },
      -- stylua: ignore
      keys = {
        {
          "<tab>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or
                "<tab>"
          end,
          expr = true,
          silent = true,
          mode = "i",
        },
        { "<tab>",   function() require("luasnip").jump(1) end,  mode = "s" },
        { "<s-tab>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      },
    },
    -- auto completion
    {
      "hrsh7th/nvim-cmp",
      version = false,       -- last release is way too old
      event = "InsertEnter", -- load cmp on InsertEnter
      -- these dependencies will only be loaded when cmp loads
      dependencies = {
        'windwp/nvim-autopairs',
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        'saadparwaiz1/cmp_luasnip',
        'ray-x/lsp_signature.nvim',
        'kdheepak/cmp-latex-symbols',
        'onsails/lspkind-nvim'
      },
      config = function()
        -- nvim-autopairs
        require('nvim-autopairs').setup()
        local cmp = require("cmp")
        -- cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done({ map_char = { tex = '' } }))
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
                ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp
                .SelectBehavior.Insert },
                ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp
                .SelectBehavior.Insert },
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
            { name = "luasnip",      keyword_length = 2 },
            { name = "nvim_lua",     keyword_length = 2 },
            { name = "nvim_lsp",     keyword_length = 2 },
            { name = "path",         keyword_length = 2 },
            { name = "buffer",       keyword_length = 5 },
            { name = "spell" },
            { name = "tags" },
            { name = "latex_symbols" }
          })
        })
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      event = "VeryLazy",
      config = function()
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
            theme = 'onedark',
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = { "NvimTree", "Telescope", "Outline", "dashboard" },
            always_divide_middle = true,
          },
          sections = {
            lualine_a = { {
              -- mode
              function() return " " end,
              padding = { left = 0, right = 0 }
            } },
            lualine_b = {
              {
                -- 'branch'
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
              {
                -- 'diff'
                "diff",
                source = diff_source,
                symbols = {
                  added = " ",
                  modified = " ",
                  removed = " "
                }
              },
              { 'filesize', cond = conditions.buffer_not_empty },
            },
            lualine_x = {
              {
                -- 'diagnostics'
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = {
                  error = "  ",
                  warn = "  ",
                  info = "  ",
                  hint = "H "
                }
              },
              {
                -- lazy package manager status
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
                color = { fg = "#ff9e64" }
              },
              -- { -- 'treesitter'
              --   function()
              --     if next(vim.treesitter.highlighter.active[api.nvim_get_current_buf()]) then
              --       return ""
              --     end
              --     return ""
              --   end,
              --   cond = conditions.hide_in_width,
              -- },
              {
                -- 'lsp'
                function()
                  local msg = ''
                  local buf_ft = vim.api.nvim_buf_get_option(0,
                    'filetype')
                  local clients = vim.lsp.get_active_clients()
                  if next(clients) == nil then
                    return msg
                  end
                  for _, client in ipairs(clients) do
                    local filetypes = client.config
                        .filetypes
                    if filetypes and vim.fn.index(filetypes, buf_ft) ~= -1 then
                      return client.name
                    end
                  end
                  return msg
                end,
                -- icon = ' ',
                cond = conditions.hide_in_width,
              },
              -- { 'encoding' },
              -- { 'fileformat' },
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
      end
    },
    {
      'nvim-tree/nvim-tree.lua',
      event = "VeryLazy",
      dependencies = { 'nvim-tree/nvim-web-devicons' },
      config = function()
        require 'nvim-tree'.setup {
          disable_netrw = true,
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
      end,
    },
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      opts = {
        ensure_installed = {
          "css", "html", "javascript", "json", "svelte", "typescript",
          "erlang", "elixir", "eex", "heex",
          "ledger", "lua", "toml", "zig"
        },
        context_commentstring = { enable = true, enable_autocmd = false },
        highlight = { enable = true },
        indent = { enable = false } -- indent is experimental
      }
    },
    'neovim/nvim-lspconfig',
    'b0o/schemastore.nvim',
    {
      'lewis6991/gitsigns.nvim',
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { current_line_blame = false }
    },
    {
      "lukas-reineke/indent-blankline.nvim",
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        char = "┊",
        filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
        show_trailing_blankline_indent = false,
        show_current_context = true,
      },
    },
    -- lsp symbol navigation for lualine
    {
      "SmiteshP/nvim-navic",
      lazy = true,
      init = function()
        vim.g.navic_silence = true
        -- require("lazyvim.util").on_attach(function(client, buffer)
        --   if client.server_capabilities.documentSymbolProvider then
        --     require("nvim-navic").attach(client, buffer)
        --   end
        -- end)
      end,
      opts = function()
        return {
          separator = " ",
          highlight = true,
          depth_limit = 5,
          -- icons = require("lazyvim.config").icons.kinds,
        }
      end,
    },
    {
      'numToStr/Comment.nvim',
      event = "VeryLazy",
      dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
      opts = {
        --pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook()
      }
    },
    { 'j-hui/fidget.nvim',                    config = true },
    'olambo/vi-viz',
    'pbrisbin/vim-mkdir',      -- :e this/does/not/exist/file.txt then :w
    'cohama/lexima.vim',
    'alvan/vim-closetag',      -- Close html tags
    'justinmk/vim-gtfo',       -- gof open file in filemanager
    'junegunn/vim-easy-align', -- visual select then ga<char> to align
    { 'kristijanhusak/vim-dadbod-completion', dependencies = { 'tpope/vim-dadbod' } },
    'lervag/vimtex',
    {
      'akinsho/toggleterm.nvim',
      version = 'v2.*',
      opts = {
        open_mapping = [[A-1]],
        -- shading-factor = 2
      }
    },
    'machakann/vim-sandwich', -- sr({ sd' <select text>sa'
    'mg979/vim-visual-multi',
    -- 'leafOfTree/vim-svelte-plugin'
  },
  {
    checker = { enabled = true },
    performance = {
      rtp = {
        disabled_plugins = {
          "gzip",
          -- "matchit",
          -- "matchparen",
          -- "netrwPlugin",
          "tarPlugin",
          "tohtml",
          "tutor",
          "zipPlugin",
        }
      }
    }
  })

-------------------- PLUGIN SETUP --------------------------
-- symbols-outline
g.symbols_outline = { highlight_hovered_item = false, auto_preview = false }
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
      ["L"] = { '<cmd>Lazy<CR>', 'Lazy' },
  l = {
    name = "LSP",
    I = { "<cmd>Mason<cr>", "Installer Info" },
    a = { "<cmd>FzfLua lsp_code_actions<cr>", "Code Action" },
    c = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    d = { "<cmd>lua vim.lsp.buf.definition()<cr>", "Definition" },
    D = { "<cmd>FzfLua lsp_document_diagnostics<cr>", "Buffer Diagnostics" },
    f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format" },
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
-- require('bufdel').setup { next = 'alternate' }
-- closetag
g['closetag_filenames'] = '*.html, *.vue, *.heex, *.svelte'
-- fzf-lua
g['fzf_action'] = { ['ctrl-s'] = 'split',['ctrl-v'] = 'vsplit' }
require('fzf-lua').setup({
  winopts = {
    preview = { default = 'bat_native' }
  }
})
-- nvim-tree
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
g['vimtex_view_general_viewer']       = 'okular'
-------------------- OPTIONS -------------------------------
local width                           = 80
-- global options
opt.backup                            = false
opt.breakindent                       = true
opt.completeopt                       = 'menu,menuone,noselect' -- Completion options
opt.conceallevel                      = 3                       -- Hide * markip for bold and italic
opt.cursorline                        = true                    -- Highlight cursor line
-- opt.equalalways                       = false                   -- I don't like my windows changing all the time
opt.expandtab                         = true                    -- Use spaces instead of tabs
opt.foldlevel                         = 99
opt.foldmethod                        = 'indent'
opt.formatoptions                     = 'cqn1j' -- Automatic formatting options
-- opt.guicursor                         = 'i-ci-ve:ver25,r-cr:hor20,o:hor50' --,a:blinkon1'
opt.grepformat                        = "%f:%l:%c:%m"
opt.grepprg                           = "rg --vimgrep"
opt.ignorecase                        = true  -- Ignore case
opt.joinspaces                        = false -- No double spaces with join
opt.laststatus                        = 3     -- global statusline
opt.linebreak                         = true
opt.list                              = true  -- Show some invisible characters
opt.listchars                         = "tab:▸ ,extends:>,precedes:<"
opt.mouse                             = 'a'   -- Allow the mouse
opt.number                            = true  -- Show line numbers
opt.pumheight                         = 10    -- Maximum number of entries in a popup
opt.scrolljump                        = 4     -- min. lines to scroll
opt.scrolloff                         = 4     -- Lines of context
opt.shiftround                        = true  -- Round indent
opt.shiftwidth                        = 2     -- Size of an indent
-- opt.shortmess                         = 'IFc' -- Avoid showing extra message on completion
opt.shortmess:append { W = true, I = true, c = true }
opt.showbreak     = '↪  '
opt.showbreak     = '↪  '
opt.showmatch     = true
opt.showmode      = false -- Don't show mode since we have a statusline
opt.sidescrolloff = 8     -- Columns of context
opt.signcolumn    = 'yes' -- Show sign column
opt.smartcase     = true  -- Don't ignore case with capitals
opt.smartindent   = true  -- Insert indents automatically
opt.spelllang     = { "en_GB" }
opt.softtabstop   = 2
opt.splitbelow    = true  -- Put new windows below current
opt.splitright    = true  -- Put new windows right of current
opt.swapfile      = false
opt.tabstop       = 2     -- Number of spaces tabs count for
opt.termguicolors = true  -- True color support
opt.textwidth     = width -- Maximum width of text
opt.timeoutlen    = 100   -- mapping timeout
opt.undodir       = '/home/hvaria/.nvim/undo'
opt.undofile      = true
opt.updatetime    = 200                 -- make updates faster and trigger CursorHold
opt.wildmode      = "longest:full,full" -- Command-line completion mode
opt.winminwidth   = 5                   -- Minimum window width
opt.wrap          = false               -- Disable line wrap
opt.writebackup   = false

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
map('n', '<C-o>', '<C-o>zz', { silent = true })
map('n', '<C-d>', '<C-d>zz', { silent = true })
map('n', '<C-u>', '<C-u>zz', { silent = true })
-- reselect visual block after indent
map('v', '<', '<gv')
map('v', '>', '>gv')

------------------ LSP-INSTALL & CONFIG --------------------
-- ref: https://github.com/wookayin/dotfiles/blob/master/nvim/lua/config/lsp.lua
-- lsp_diagnostics
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
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

require("mason").setup()
require("mason-lspconfig").setup {
  ensure_installed = { "lua_ls", "elixirls", "cssls", "html", "jsonls", "tsserver", "tailwindcss", "texlab" }
}
local lspconfig = require("lspconfig")
local capabilities = lsp.protocol.make_client_capabilities()

lspconfig.elixirls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities),
  settings = {
    elixirLS = {
      dialyzerEnabled = false,
      fetchDeps = false
    }
  }
}
lspconfig.lua_ls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities),
  settings = { Lua = { diagnostics = { globals = { "vim" } } } }
}
lspconfig.jsonls.setup {
  on_attach = on_attach,
  capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities),
  settings = {
    json = {
      schemas = require('schemastore').json.schemas(),
      validate = { enable = true }
    }
  }
}
for _, server in ipairs { "tailwindcss", "svelte", "tsserver" } do
  lspconfig[server].setup {
    on_attach = on_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
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
--- Luasnip
local ls = require('luasnip')
require("luasnip.loaders.from_lua").load({ paths = "~/dotfiles/snippets/" })
ls.config.set_config({
  history = true,                            -- keep around last snippet local to jump back
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
local group = vim.api.nvim_create_augroup("MyGroup", { clear = true })
autocmd("TextYankPost",
  {
    pattern = "*",
    command = 'silent! lua vim.highlight.on_yank({ hi_group="IncSearch", timeout=200, on_visual=true})',
    group = group
  })
autocmd("FileType",
  {
    pattern = "sql,mysql,plsql",
    command = 'lua require("cmp").setup.buffer({ sources = {{ name = "vim-dadbod-completion"}}})',
    group = group
  })
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

local elixir_group = vim.api.nvim_create_augroup("ElixirGroup", { clear = true })
autocmd("FileType", { pattern = "elixir,eelixir", command = 'iab pp \\|>', group = elixir_group })

local lsp_group = vim.api.nvim_create_augroup("LSPGroup", { clear = true })
autocmd("BufWritePre", { pattern = "*.{ex,exs,heex}", command = 'lua vim.lsp.buf.format()', group = lsp_group })
autocmd("BufWritePre",
  { pattern = "*.{svelte,css,scss,js,ts,json}", command = 'lua vim.lsp.buf.format()', group = lsp_group })
autocmd("BufWritePre",
  { pattern = "*.{lua}", command = 'lua vim.lsp.buf.format()', group = lsp_group })
