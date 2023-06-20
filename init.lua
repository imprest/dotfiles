-- Based of https://github.com/LazyVim/LazyVim & https://astronvim.com
-------------------- HELPERS -------------------------------
vim.g['loaded_python_provider'] = 1
vim.g['python3_host_prog'] = '/usr/bin/python3'
vim.g.mapleader = ','
vim.g.maplocalleader = ';'

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
      ft = { 'javascript', 'typescript', 'typescriptreact', 'css', 'html' },
      cmd = 'ColorizerToggle',
      opts = { user_default_options = { tailwind = true } }
    },
    {
      "NTBBloodbath/doom-one.nvim",
      lazy = false,       -- make sure we load this during startup if it is your main colorscheme
      priority = 1000,    -- make sure to load this before all the other start plugins
      config = function() -- load the colorscheme here
        -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
        vim.cmd [[autocmd! ColorScheme * highlight NormalFloat guifg=#bbc2cf guibg=#282c34]]
        vim.cmd([[colorscheme doom-one]])
      end
    },
    {
      'akinsho/bufferline.nvim',
      version = "v3.*",
      dependencies = { "famiu/bufdelete.nvim", "nvim-tree/nvim-web-devicons" },
      opts = {
        highlights = { fill = { bg = "" } },
        options = {
          always_show_bufferline = true,
          show_buffer_close_icons = false,
          show_close_icon = false,
          offsets = { { filetype = "neo-tree", highlight = "Directory" } },
          custom_filter = function(buf_number, _) -- hide shell and other unknown ft
            if vim.bo[buf_number].filetype ~= "" then
              return true
            end
          end
        }
      }
    },
    -- references i.e. highlight same work undercursor
    {
      "RRethy/vim-illuminate",
      event = { "BufReadPost", "BufNewFile" },
      opts = { delay = 200 },
      config = function(_, opts)
        require("illuminate").configure(opts)

        local function map(key, dir, buffer)
          vim.keymap.set("n", key, function()
              require("illuminate")["goto_" .. dir .. "_reference"](false)
            end,
            {
              desc = dir:sub(1, 1):upper() .. dir:sub(2) .. " Reference",
              buffer = buffer
            })
        end

        map("]]", "next")
        map("[[", "prev")

        -- also set it after loading ftplugins, since a lot overwrite [[ and ]]
        vim.api.nvim_create_autocmd("FileType", {
          callback = function()
            local buffer = vim.api.nvim_get_current_buf()
            map("]]", "next", buffer)
            map("[[", "prev", buffer)
          end,
        })
      end,
      keys = {
        { "]]", desc = "Next Reference" },
        { "[[", desc = "Prev Reference" },
      },
    },
    {
      'leafOfTree/vim-svelte-plugin',
      ft = { "svelte" },
      config = function()
        vim.g['vim_svelte_plugin_use_typescript'] = 1
        vim.g['vim_svelte_plugin_use_foldexpr']   = 1
      end
    },
    { 'ethanholz/nvim-lastplace', config = true },
    {
      'ibhagwan/fzf-lua',
      event = "VeryLazy",
      dependencies = { 'vijaymarupudi/nvim-fzf' },
      config = function()
        require "fzf-lua".setup({ "max-perf" })
      end
    },
    -- LSP
    {
      'neovim/nvim-lspconfig',
      event = { "BufReadPre", "BufNewFile" },
      dependencies = {
        { "slashmili/alchemist.vim" },
        { 'elixir-editors/vim-elixir' },
        { "jose-elias-alvarez/typescript.nvim" },
        { 'b0o/schemastore.nvim',              version = false },
        { 'williamboman/mason.nvim',           config = true },
        {
          'williamboman/mason-lspconfig.nvim',
          opts = {
            ensure_installed = {
              "lua_ls", "elixirls", "cssls", "html", "jsonls", "tsserver", "tailwindcss", "svelte" }
          }
        }
      },
      config = function()
        -- ref: LazyVim & https://github.com/wookayin/dotfiles/blob/master/nvim/lua/config/lsp.lua
        -- lsp_diagnostics
        local signs = { Error = " ", Warn = " ", Hint = "Ⓗ ", Info = " " }
        for type, icon in pairs(signs) do
          local hl = "DiagnosticSign" .. type
          vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
        vim.diagnostic.config({
          underline = true,
          update_in_insert = false,
          virtual_text = { spacing = 4, prefix = "●" },
          severity_sort = true,
        })

        -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
        -- To instead override globally for all lsp borders
        local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
        function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
          opts = opts or {}
          opts.border = opts.border or 'single'
          return orig_util_open_floating_preview(contents, syntax, opts, ...)
        end

        -- Customize LSP behavior
        local on_attach = function(client, bufnr)
          -- Enable completion triggered by <c-x><c-o>
          vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

          -- Mappings | See `:help vim.lsp.*` for documentation on any of the below functions
          local bufopts = { noremap = true, silent = true, buffer = bufnr }
          vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, bufopts)
          vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
          vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
          vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
          vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
          vim.keymap.set('n', 'gS', vim.lsp.buf.signature_help, bufopts)
          vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
          if client.name == "tsserver" then
            vim.keymap.set('n', '<leader>co', '<cmd>TypescriptOrganizeImports<CR>',
              { buffer = bufnr, desc = "Organize Imports" })
            vim.keymap.set('n', '<leader>cR', '<cmd>TypescriptRenameFile<CR>',
              { buffer = bufnr, desc = "Rename File" })
          end
        end

        local lspconfig = require("lspconfig")
        local capabilities = require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol
          .make_client_capabilities())

        lspconfig.elixirls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          settings = {
            elixirLS = {
              dialyzerEnabled = true
            }
          }
        }

        lspconfig.lua_ls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          settings = { Lua = { diagnostics = { globals = { "vim" } } } }
        }

        lspconfig.jsonls.setup {
          on_attach = on_attach,
          capabilities = capabilities,
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas,
              require("schemastore").json.schemas())
          end,
          settings = {
            json = {
              validate = { enable = true }
            }
          }
        }

        -- jose-elias-alvarez/typescript.nvim
        require("typescript").setup({
          disable_commands = false, -- prevent the plugin from creating Vim commands
          debug = false,            -- enable debug logging for commands
          go_to_source_definition = {
            fallback = true,        -- fall back to standard LSP definition on failure
          },
          server = {
            on_attach = on_attach,
            capabilities = capabilities,
            settings = { completions = { completeFunctionCalls = true } }
          },
        })

        local servers = { 'tailwindcss', 'svelte' }
        for _, lsp in ipairs(servers) do
          lspconfig[lsp].setup {
            on_attach = on_attach,
            capabilities = capabilities
          }
        end
      end
    },
    -- Null-ls
    {
      "jay-babu/mason-null-ls.nvim",
      dependencies = { 'jose-elias-alvarez/null-ls.nvim', 'williamboman/mason.nvim' },
      config = function()
        require('mason-null-ls').setup({
          automatic_setup = true,
        })
      end
    },
    -- snippets
    {
      "L3MON4D3/LuaSnip",
      version = "1.*",
      build = "make install_jsregexp",
      dependencies = {
        "rafamadriz/friendly-snippets",
        config = function()
          require("luasnip.loaders.from_vscode").lazy_load()
        end,
      },
      config = function()
        local lsnip = require('luasnip')
        require("luasnip.loaders.from_lua").load({ paths = "~/dotfiles/snippets/" })
        lsnip.config.set_config({
          history = true,                            -- keep around last snippet local to jump back
          updateevents = "TextChanged,TextChangedI", -- update changes as you type
          delete_check_events = "TextChanged",
          enable_autosnippets = true,
          ext_opts = {
            [require("luasnip.util.types").choiceNode] = {
              active = { virt_text = { { "·", "Question" } } }
            }
          }
        })
      end,
      keys = {
        {
          "<a-l>",
          function()
            return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or
                "<tab>"
          end,
          expr = true,
          silent = true,
          mode = "i",
        },
        { "<a-l>", function() require("luasnip").jump(1) end,  mode = "s" },
        { "<a-h>", function() require("luasnip").jump(-1) end, mode = { "i", "s" } },
      },
    },
    -- better diagnostics list and others
    {
      "folke/trouble.nvim",
      cmd = { "TroubleToggle", "Trouble" },
      opts = { use_diagnostic_signs = true },
      keys = {
        {
          "<leader>xx",
          "<cmd>TroubleToggle document_diagnostics<cr>",
          desc =
          "Document Diagnostics (Trouble)"
        },
        {
          "<leader>xX",
          "<cmd>TroubleToggle workspace_diagnostics<cr>",
          desc =
          "Workspace Diagnostics (Trouble)"
        },
        {
          "<leader>xL",
          "<cmd>TroubleToggle loclist<cr>",
          desc =
          "Location List (Trouble)"
        },
        {
          "<leader>xQ",
          "<cmd>TroubleToggle quickfix<cr>",
          desc =
          "Quickfix List (Trouble)"
        },
        {
          "[q",
          function()
            if require("trouble").is_open() then
              require("trouble").previous({ skip_groups = true, jump = true })
            else
              vim.cmd.cprev()
            end
          end,
          desc = "Previous trouble/quickfix item",
        },
        {
          "]q",
          function()
            if require("trouble").is_open() then
              require("trouble").next({ skip_groups = true, jump = true })
            else
              vim.cmd.cnext()
            end
          end,
          desc = "Next trouble/quickfix item",
        },
      },
    },

    -- todo comments
    {
      "folke/todo-comments.nvim",
      cmd = { "TodoTrouble" },
      event = { "BufReadPost", "BufNewFile" },
      config = true,
      -- stylua: ignore
      keys = {
        {
          "]t",
          function() require("todo-comments").jump_next() end,
          desc =
          "Next todo comment"
        },
        {
          "[t",
          function() require("todo-comments").jump_prev() end,
          desc =
          "Previous todo comment"
        },
        {
          "<leader>xt",
          "<cmd>TodoTrouble<cr>",
          desc =
          "Todo (Trouble)"
        },
        {
          "<leader>xT",
          "<cmd>TodoTrouble keywords=TODO,FIX,FIXME<cr>",
          desc =
          "Todo/Fix/Fixme (Trouble)"
        },
      },
    },

    -- Better Escape
    {
      'max397574/better-escape.nvim', config = true
    },

    -- auto completion
    { "windwp/nvim-autopairs",    config = true },
    {
      "hrsh7th/nvim-cmp",
      version = false,       -- last release is way too old
      event = "InsertEnter", -- load cmp on InsertEnter
      -- these dependencies will only be loaded when cmp loads
      dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        'saadparwaiz1/cmp_luasnip',
        -- 'kdheepak/cmp-latex-symbols',
        'onsails/lspkind-nvim',
        { 'roobert/tailwindcss-colorizer-cmp.nvim', config = true }
      },
      opts = function()
        local cmp = require("cmp")
        local snip_status_ok, luasnip = pcall(require, "luasnip")
        local lspkind_status_ok, lspkind = pcall(require, "lspkind")
        if not snip_status_ok then return end
        local border_opts = {
          border = "single",
          winhighlight =
          "Normal:Normal,FloatBorder:FloatBorder,CursorLine:Visual,Search:None",
        }

        -- If you want insert `(` after select function or method item
        local cmp_autopairs = require('nvim-autopairs.completion.cmp')
        cmp.event:on('confirm_done',
          cmp_autopairs.on_confirm_done({ filetypes = { tex = false } }))

        local has_words_before = function()
          unpack = unpack or table.unpack
          local line, col = unpack(vim.api.nvim_win_get_cursor(0))
          return col ~= 0 and
              vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match(
                "%s") ==
              nil
        end

        local format_kinds = lspkind_status_ok and
            lspkind.cmp_format({ mode = 'symbol', maxwidth = 50, ellipsis_char = '...' }) or nil

        return {
          formatting = {
            -- ref: https://www.youtube.com/watch?v=_NiWhZeR-MY
            format = function(entry, item)
              if format_kinds ~= nil then
                format_kinds(entry, item) -- add icons
                return require('tailwindcss-colorizer-cmp').formatter(
                  entry, item)
              end
            end
          },
          completion = {
            completeopt = "menu,menuone,noselect",
          },
          snippet = {
            expand = function(args)
              luasnip.lsp_expand(args.body)
            end
          },
          duplicates = {
            nvim_lsp = 1,
            luasnip = 1,
            cmp_tabnine = 1,
            buffer = 1,
            path = 1,
          },
          confirm_opts = {
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          },
          window = {
            completion = cmp.config.window.bordered(border_opts),
            documentation = cmp.config.window.bordered(border_opts),
          },
          mapping = {
            ["<C-n>"] = cmp.mapping.select_next_item { behavior = cmp.SelectBehavior
                .Insert },
            ["<C-p>"] = cmp.mapping.select_prev_item { behavior = cmp.SelectBehavior
                .Insert },
            ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
            ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
            ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
            ["<C-y>"] = cmp.config.disable,
            ["<C-e>"] = cmp.mapping { i = cmp.mapping.abort(), c = cmp.mapping.close() },
            ["<CR>"] = cmp.mapping.confirm { select = true },
            ["<S-CR>"] = cmp.mapping.confirm({
              behavior = cmp.ConfirmBehavior.Replace,
              select = true,
            }),
            ["<Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_next_item()
              elseif luasnip.expand_or_jumpable() then
                luasnip.expand_or_jump()
              elseif has_words_before() then
                cmp.complete()
              else
                fallback()
              end
            end, { "i", "s" }),
            ["<S-Tab>"] = cmp.mapping(function(fallback)
              if cmp.visible() then
                cmp.select_prev_item()
              elseif luasnip.jumpable(-1) then
                luasnip.jump(-1)
              else
                fallback()
              end
            end, { "i", "s" }),
          },
          sources = cmp.config.sources({
            { name = "nvim_lsp", priority = 1000 },
            { name = "luasnip",  priority = 750 },
            { name = "buffer",   priority = 500 },
            { name = "path",     priority = 250 }
            -- { name = "latex_symbols", priority = 200 }
          }),
          experimental = {
            ghost_text = {
              hl_group = "LspCodeLens",
            },
          },
        }
      end
    },
    {
      'nvim-lualine/lualine.nvim',
      event = "VeryLazy",
      config = function()
        local window_width_limit = 70
        local conditions = {
          buffer_not_empty = function()
            return vim.fn.empty(vim.fn.expand "%:t") ~= 1
          end,
          hide_in_width = function()
            return vim.fn.winwidth(0) > window_width_limit
          end,
          check_git_workspace = function()
            local filepath = vim.fn.expand "%:p:h"
            local gitdir = vim.fn.finddir(".git", filepath .. ";")
            return gitdir and #gitdir > 0 and #gitdir < #filepath
          end,
        }
        local function diff_source()
          local gitsigns = vim.b.gitsigns_status_dict
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
            -- theme = 'onedark',
            globalstatus = true,
            component_separators = { left = '', right = '' },
            section_separators = { left = '', right = '' },
            disabled_filetypes = { "Telescope", "Outline", "dashboard" },
            always_divide_middle = true,
          },
          sections = {
            lualine_a = { {
              -- mode
              function() return " " end,
              padding = { left = 0, right = 0 }
            }
            },
            lualine_b = {
              { 'filesize', cond = conditions.buffer_not_empty },
              {
                "filename",
                symbols = {
                  path = 3,
                  modified = "  ",
                  readonly = "",
                  unnamed = ""
                }
              },
            },
            lualine_c = {
              {
                -- 'branch'
                "b:gitsigns_head",
                icon = "",
                cond = conditions.hide_in_width
              },
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
            },
            lualine_x = {
              {
                -- 'diagnostics'
                "diagnostics",
                sources = { "nvim_diagnostic" },
                symbols = {
                  error = " ",
                  warn = " ",
                  info = " ",
                  hint = " "
                }
              },
              {
                -- lazy package manager status
                require("lazy.status").updates,
                cond = require("lazy.status").has_updates,
                color = { fg = "#ff9e64" }
              },
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
                cond = conditions.hide_in_width,
              },
            },
            lualine_y = { 'filetype', 'fileformat', 'encoding' },
            lualine_z = { 'progress', '%3l:%3c' }
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
          extensions = { 'quickfix', 'neo-tree', 'fzf' }
        }
      end
    },
    -- file explorer
    {
      "nvim-neo-tree/neo-tree.nvim",
      cmd = "Neotree",
      dependencies = { "MunifTanjim/nui.nvim" },
      keys = {
        { "<F2>", '<cmd>Neotree toggle<CR>', desc = "Toggle NeoTree" },
      },
      deactivate = function()
        vim.cmd([[Neotree close]])
      end,
      init = function()
        vim.g.neo_tree_remove_legacy_commands = 1
        if vim.fn.argc() == 1 then
          local stat = vim.loop.fs_stat(vim.fn.argv(0))
          if stat and stat.type == "directory" then
            require("neo-tree")
          end
        end
      end,
      opts = {
        close_if_last_window = true,
        source_selector = { statusline = true },
        filesystem = {
          bind_to_cwd = false,
          follow_current_file = true,
        },
        window = {
          width = "24",
          mappings = {
            ["<space>"] = "none",
          },
        },
        default_component_configs = {
          indent = {
            with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
            expander_collapsed = "",
            expander_expanded = "",
            expander_highlight = "NeoTreeExpander",
          },
        }
      },
    },
    -- search/replace in multiple files
    {
      "windwp/nvim-spectre",
      -- stylua: ignore
      keys = {
        {
          "<leader>S",
          function() require("spectre").open() end,
          desc = "Replace in files (Spectre)"
        },
      },
    },
    {
      'stevearc/aerial.nvim',
      opts = {
        on_attach = function(bufnr)
          vim.keymap.set('n', '<A-d>', '<cmd>AerialPrev<CR>', { buffer = bufnr })
          vim.keymap.set('n', '<A-f>', '<cmd>AerialNext<CR>', { buffer = bufnr })
        end
      }
    },
    {
      'numToStr/Comment.nvim',
      event = "VeryLazy",
      dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' }, -- Allow commenting embedded lang in files
      config = function()
        require('Comment').setup({
          pre_hook = require('ts_context_commentstring.integrations.comment_nvim')
              .create_pre_hook()
        })
      end
    },
    {
      'nmac427/guess-indent.nvim',
      event = { "BufReadPost", "BufNewFile" },
      config = true
    },
    {
      'nvim-treesitter/nvim-treesitter',
      version = false,
      build = ':TSUpdate',
      dependencies = { {
        "windwp/nvim-ts-autotag",
        ft = { 'html', 'javascript', 'typescript', 'svelte', 'vue', 'xml', 'markdown', 'heex' }
      }, "RRethy/nvim-treesitter-endwise" },
      event = { "BufReadPost", "BufNewFile" },
      opts = {
        autotag = {
          enable = true, -- windwp/nvim-ts-autotag
          filetypes = { 'html', 'javascript', 'typescript', 'svelte', 'vue', 'xml', 'markdown', 'heex' }
        },
        endwise = { enable = true }, -- RRethy/nvim-treesitter-endwise
        highlight = { enable = true },
        -- indent = { enable = true, disable = { "python" } },            -- guess-indent is better and faster
        context_commentstring = { enable = true, enable_autocmd = false }, -- nvim-ts-context-commentstring
        ensure_installed = {
          "vim", "regex", "lua", "markdown", "markdown_inline",
          "css", "html", "javascript", "json", "typescript",
          "erlang", "elixir", "eex", "heex",
          "ledger", "toml" --, "zig"
        },
        incremental_selection = {
          enable = true,
          keymaps = {
            init_selection = "<C-space>",
            node_incremental = "<C-space>",
            scope_incremental = "<nop>",
            node_decremental = "<space>",
          },
        },
      },
      config = function(_, opts)
        require("nvim-treesitter.configs").setup(opts)
      end
    },

    -- easily jump to any location and enhanced f/t motions for Leap
    {
      "ggandor/flit.nvim",
      keys = function()
        local ret = {}
        for _, key in ipairs({ "f", "F", "t", "T" }) do
          ret[#ret + 1] = { key, mode = { "n", "x", "o" }, desc = key }
        end
        return ret
      end,
      opts = { labeled_modes = "nx" },
    },
    {
      "ggandor/leap.nvim",
      keys = {
        { "s",  mode = { "n", "x", "o" }, desc = "Leap forward to" },
        { "S",  mode = { "n", "x", "o" }, desc = "Leap backward to" },
        { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
      },
      config = function(_, opts)
        local leap = require("leap")
        for k, v in pairs(opts) do
          leap.opts[k] = v
        end
        leap.add_default_mappings(true)
        vim.keymap.del({ "x", "o" }, "x")
        vim.keymap.del({ "x", "o" }, "X")
      end,
    },
    {
      'lewis6991/gitsigns.nvim',
      event = { "BufReadPre", "BufNewFile" },
      dependencies = { 'nvim-lua/plenary.nvim' },
      opts = { current_line_blame = false }
    },
    -- {
    --   "lukas-reineke/indent-blankline.nvim",
    --   event = { "BufReadPost", "BufNewFile" },
    --   opts = {
    --     char = "┊",
    --     filetype_exclude = { "help", "alpha", "dashboard", "neo-tree", "Trouble", "lazy" },
    --     show_trailing_blankline_indent = false,
    --     show_current_context = true,
    --   },
    -- },
    -- {
    --   'j-hui/fidget.nvim',
    --   event = { "BufReadPre", "BufNewFile" },
    --   config = true
    -- },
    { 'pbrisbin/vim-mkdir', event = 'VeryLazy' }, -- :e this/does/not/exist/file.txt then :w
    { 'justinmk/vim-gtfo',  event = 'VeryLazy' }, -- gof open file in filemanager
    {
      'kristijanhusak/vim-dadbod-completion',
      ft = "sql",
      dependencies = { 'tpope/vim-dadbod' },
      config = function()
        vim.g['db'] = "postgresql://hvaria:@localhost/mgp_dev"
        vim.keymap.set('x', '<Plug>(DBExe)', 'db#op_exec()', { expr = true })
        vim.keymap.set('n', '<Plug>(DBExe)', 'db#op_exec()', { expr = true })
        vim.keymap.set('n', '<Plug>(DBExeLine)', 'db#op_exec() . \'_\'', { expr = true })
        vim.keymap.set('x', '<leader>d', '<Plug>(DBExe)')
        vim.keymap.set('n', '<leader>d', '<Plug>(DBExe)')
        vim.keymap.set('o', '<leader>d', '<Plug>(DBExe)')
        vim.keymap.set('n', '<leader>dd', '<Plug>(DBExeLine)')
      end
    },
    -- {
    --   'lervag/vimtex', -- don't lazy load since it breaks the plugin + plugin automatically loads based on ft
    --   config = function()
    --     vim.g['vimtex_quickfix_mode']       = 0
    --     vim.g['vimtex_compiler_method']     = 'tectonic'
    --     vim.g['vimtex_view_general_viewer'] = 'okular'
    --     vim.g['vimtex_fold_enabled']        = true
    --   end
    -- },
    {
      'akinsho/toggleterm.nvim',
      cmd = { "ToggleTerm", "TermExec" },
      version = 'v2.*',
      opts = { open_mapping = [[<A-,>]], shading_factor = 1 }
    },
    {
      'echasnovski/mini.surround',                                         -- sr({ sd' <select text>sa'
      keys = { "sr", "sh", "sf", "sF", "sd", "sn", { "sa", mode = "v" } }, -- Only load on these keystrokes
      version = false,
      config = function()
        require('mini.surround').setup()
      end,
    },
    { 'mg979/vim-visual-multi', version = false, event = "VeryLazy" },
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

-------------------- OPTIONS -------------------------------
local width           = 85
-- global options
vim.opt.backup        = false
vim.opt.breakindent   = true
vim.opt.completeopt   = 'menu,menuone,noselect' -- Completion options
vim.opt.conceallevel  = 3                       -- Hide * markip for bold and italic
vim.opt.cursorline    = false                   -- Highlight cursor line
-- vim.opt.equalalways              = false                   -- I don't like my windows changing all the time
vim.opt.expandtab     = true                    -- Use spaces instead of tabs
vim.opt.foldlevel     = 99
vim.opt.foldmethod    = 'indent'
vim.opt.formatoptions = 'cqn1jl' -- Automatic formatting options
vim.cmd [[set formatoptions-=ro]]
-- vim.opt.guicursor                = 'i-ci-ve:ver25,r-cr:hor20,o:hor50' --,a:blinkon1'
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg    = "rg --vimgrep"
vim.opt.ignorecase = true  -- Ignore case
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.laststatus = 3     -- global statusline
vim.opt.linebreak  = true
vim.opt.list       = true  -- Show some invisible characters
vim.opt.listchars  = "tab:▸ ,extends:>,precedes:<"
vim.opt.mouse      = 'a'   -- Allow the mouse
vim.opt.number     = true  -- Show line numbers
vim.opt.pumheight  = 10    -- Maximum number of entries in a popup
vim.opt.scrolljump = 4     -- min. lines to scroll
vim.opt.scrolloff  = 4     -- Lines of context
vim.opt.shiftround = true  -- Round indent
vim.opt.shiftwidth = 2     -- Size of an indent
-- vim.opt.shortmess                = 'IFc' -- Avoid showing extra message on completion
vim.opt.shortmess:append { W = true, I = true, c = true }
vim.opt.showbreak     = '↪  '
vim.opt.showbreak     = '↪  '
vim.opt.showmatch     = true
vim.opt.showmode      = false   -- Don't show mode since we have a statusline
vim.opt.sidescrolloff = 8       -- Columns of context
vim.opt.signcolumn    = 'yes:1' -- Show sign column
vim.opt.smartcase     = true    -- Don't ignore case with capitals
vim.opt.smartindent   = true    -- Insert indents automatically
vim.opt.spelllang     = { "en_GB" }
vim.opt.softtabstop   = 2
vim.opt.splitbelow    = true  -- Put new windows below current
vim.opt.splitright    = true  -- Put new windows right of current
vim.opt.swapfile      = false
vim.opt.tabstop       = 2     -- Number of spaces tabs count for
vim.opt.termguicolors = true  -- True color support
vim.opt.textwidth     = width -- Maximum width of text
vim.opt.timeoutlen    = 100   -- mapping timeout
vim.opt.undodir       = '/home/hvaria/.nvim/undo'
vim.opt.undofile      = true
vim.opt.updatetime    = 200                 -- make updates faster and trigger CursorHold
vim.opt.wildmode      = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth   = 5                   -- Minimum window width
vim.opt.wrap          = false               -- Disable line wrap
vim.opt.writebackup   = false

-------------------- MAPPINGS ------------------------------
-- Personal common tasks
-- map('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files({ winopts = { preview = { hidden = 'hidden' } } })<CR>")
vim.keymap.set('n', '<C-p>', "<cmd>lua require('fzf-lua').git_files()<CR>")
vim.keymap.set('n', '<BS>', '<cmd>nohlsearch<CR>')
vim.keymap.set('n', '<F4>', '<cmd>set spell!<CR>')
vim.keymap.set('n', '<F5>', '<cmd>ColorizerToggle<CR>')
vim.keymap.set('i', '<C-u>', '<C-g>u<C-u>') -- Delete lines in insert mode
vim.keymap.set('i', '<C-w>', '<C-g>u<C-w>') -- Delete words in insert mode
vim.keymap.set('n', '<C-f>', '<cmd>FzfLua grep<CR>')
vim.keymap.set('n', '<C-b>', '<cmd>FzfLua blines<CR>')

-- Easier movement
vim.keymap.set('n', 'q', '<C-w>c')
vim.keymap.set('n', 'H', '^')
vim.keymap.set('n', 'L', 'g_')
vim.keymap.set('n', 'F', '%')
vim.keymap.set('v', 'L', 'g_')

-- better up/down
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set('t', '<C-h>', '<C-\\><C-N><C-w>h')
vim.keymap.set('t', '<C-j>', '<C-\\><C-N><C-w>j')
vim.keymap.set('t', '<C-k>', '<C-\\><C-N><C-w>k')
vim.keymap.set('t', '<C-l>', '<C-\\><C-N><C-w>l')
vim.keymap.set('n', '<C-h>', '<C-w>h')
vim.keymap.set('n', '<C-j>', '<C-w>j')
vim.keymap.set('n', '<C-k>', '<C-w>k')
vim.keymap.set('n', '<C-l>', '<C-w>l')

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- buffers
vim.keymap.set("n", "<Right>", "<cmd>BufferLineCycleNext<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<Left>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })

-- Try and center these motions to the middle of the screen
-- vim.keymap.set({ "n", "x" }, "gw", "*Nzz", { desc = "Search word under cursor" })
-- vim.keymap.set('n', 'n', 'nzz', { silent = true })
-- vim.keymap.set('n', 'N', 'Nzz', { silent = true })
-- vim.keymap.set('n', '*', '*zz', { silent = true })
-- vim.keymap.set('n', '#', '#zz', { silent = true })
-- vim.keymap.set('n', 'g*', 'g*zz', { silent = true })
-- vim.keymap.set('n', 'g#', 'g#zz', { silent = true })
-- vim.keymap.set('n', '<C-o>', '<C-o>zz', { silent = true })
-- vim.keymap.set('n', '<C-i>', '<C-i>zz', { silent = true })
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
-- vim.keymap.set('n', 'u', 'uzz', { silent = true })
-- vim.keymap.set('n', '<C-r>', '<C-r>zz', { silent = true })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>update<cr><esc>", { desc = "Save file" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- LazyGit function
local Terminal = require('toggleterm.terminal').Terminal
local lazygit = Terminal:new({
  cmd = "lazygit",
  dir = "git_dir",
  direction = "float",
  float_opts = {
    border = "double",
  },
  -- function to run on opening the terminal
  on_open = function(term)
    vim.cmd("startinsert!")
    vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
  end,
  -- function to run on closing the terminal
  on_close = function(_)
    vim.cmd("startinsert!")
  end,
})
function _G.lazygit_toggle()
  lazygit:toggle()
end

-- which-key
local wk = require('which-key')
wk.register({
  ["y"] = { '"+y', "Yank System Clipboard" },
  ["."] = { "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", "Comment" }
}, { prefix = "<leader>", mode = 'v' })
wk.register({
  ["b"] = { '<cmd>FzfLua buffers<CR>', "Buffers" },
  ["."] = { "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", "Comment" },
  ["f"] = { '<cmd>FzfLua files<CR>', "Files" },
  ["gg"] = { '<cmd>lua _G.lazygit_toggle()<CR>', "lazygit" },
  ["<leader>"] = { '<C-^>', 'Last buffer' },
  ["m"] = { "<cmd>Mason<cr>", "Mason [LSP Manager]" }, -- mason plugin
  ["r"] = { '<cmd>FzfLua oldfiles<CR>', "Recent Files" },
  ["s"] = { '<cmd>split<CR>', 'Split horizontal' },
  ["v"] = { '<C-w>v<C-w>l', 'Split vertical' },
  ["w"] = { "<cmd>w!<CR>", "Save" },
  ["d"] = { "<cmd>Bdelete<CR>", "Close Buffer" },       -- bufdelete plugin
  ["z"] = { "<cmd>Lazy<CR>", "Lazy [Plugin Manager]" }, -- lazy plugin
  l = {
    name = "LSP",
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

-------------------- AUTO COMMANDS -------------------------
local function augroup(name)
  return vim.api.nvim_create_augroup("My_" .. name, { clear = true })
end

-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup("highlight_yank"),
  callback = function()
    vim.highlight.on_yank({ hi_group = "IncSearch", timeout = 200, on_visual = true })
  end,
})

-- resize splits if window got resized
vim.api.nvim_create_autocmd({ "VimResized" }, {
  group = augroup("resize_splits"),
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- wrap and check for spell in text filetypes
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("wrap_spell"),
  pattern = { "gitcommit", "markdown" },
  callback = function()
    vim.opt_local.wrap = true
    vim.opt_local.spell = true
  end,
})

-- Terminal autocommands
function _G.set_terminal_keymaps()
  local opts = { buffer = 0 }
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufNew", "TermOpen" }, {
  group = augroup("term_group"),
  pattern = "term://*",
  callback = function()
    vim.cmd [[startinsert]]
    vim.cmd [[setlocal nonumber norelativenumber nospell signcolumn=auto]]
    vim.cmd [[lua set_terminal_keymaps()]]
  end
})

-- Elixir autocommands like abbreviation of pipe as pp
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("elixir_group"),
  pattern = "elixir,eelixir",
  callback = function()
    vim.cmd [[iab pp \|>]]
  end
})

-- SQL cmp
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("sql_cmp"),
  pattern = "sql,mysql,plsql",
  callback = function()
    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
  end
})

-- LSP autocommands like format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup("lsp_format"),
  pattern = "*.{ex,exs,heex,css,scss,svelte,js,ts,json,lua}",
  callback = function()
    vim.lsp.buf.format()
  end
})

-- Help Buffer
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("help"),
  pattern = "help",
  callback = function()
    vim.cmd [[wincmd L | vert res 83<CR>]]
    vim.cmd [[nnoremap <buffer><cr> <c-]>]]
    vim.cmd [[nnoremap <buffer><bs> <c-T>]]
  end
})
