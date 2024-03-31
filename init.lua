-- Based of https://github.com/LazyVim/LazyVim & https://astronvim.com
-------------------- HELPERS -------------------------------
vim.g["loaded_python_provider"] = 1
vim.g["python3_host_prog"] = "/usr/bin/python3"
vim.g.mapleader = ","
vim.g.maplocalleader = ";"
vim.g.have_nerd_font = true

-------------------- LAZY.NVIM -----------------------------
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy/lazy.nvim"
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "--branch=stable", -- latest stable release
    lazyrepo,
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-------------------- PLUGINS -------------------------------
require("lazy").setup({
  {
    "folke/which-key.nvim",
    lazy = true,
    opts = {
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
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    ft = { "javascript", "typescript", "typescriptreact", "css", "html", "postcss" },
    cmd = "ColorizerToggle",
    opts = { user_default_options = { tailwind = true } },
  },
  {
    "folke/tokyonight.nvim",
    priority = 1000, -- Make sure to load this before all the other start plugins.
    init = function()
      vim.cmd.colorscheme("tokyonight-moon")
      -- You can configure highlights by doing something like:
      -- vim.cmd.hi 'Comment gui=none'
      vim.api.nvim_set_hl(0, "Normal", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NormalSB", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NonText", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "SignColumn", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "SignColumnNC", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "SignColumnSB", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeNormal", { bg = "none", ctermbg = "none" })
      vim.api.nvim_set_hl(0, "NeoTreeNormalNC", { bg = "none", ctermbg = "none" })
    end,
  },
  -- {
  --   "NTBBloodbath/doom-one.nvim",
  --   lazy = false, -- make sure we load this during startup if it is your main colorscheme
  --   priority = 1000, -- make sure to load this before all the other start plugins
  --   init = function()
  --     vim.g.doom_one_plugin_telescope = true
  --   end,
  --   config = function() -- load the colorscheme here
  --     -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
  --     vim.cmd([[autocmd! ColorScheme * highlight NormalFloat guifg=#bbc2cf guibg=#282c34]])
  --     vim.cmd([[colorscheme doom-one]])
  --   end,
  -- },
  -- {
  --   "navarasu/onedark.nvim",
  --   priority = 1000,
  --   config = function()
  --     vim.cmd.colorscheme("onedark")
  --   end,
  -- },
  {
    "akinsho/bufferline.nvim",
    version = "v3.*",
    dependencies = { "famiu/bufdelete.nvim", { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font } },
    opts = {
      -- highlights = { fill = { bg = "" }, buffer_selected = { italic = false, bold = false } },
      options = {
        numbers = function(opts)
          return string.format("%s ", opts.ordinal)
        end,
        offsets = { { filetype = "neo-tree", highlight = "Directory" } },
        custom_filter = function(buf_number, _) -- hide shell and other unknown ft
          if vim.bo[buf_number].filetype ~= "" then
            return true
          end
        end,
      },
    },
  },
  {
    "leafOfTree/vim-svelte-plugin",
    ft = { "svelte" },
    config = function()
      vim.g["vim_svelte_plugin_use_typescript"] = 1
      vim.g["vim_svelte_plugin_use_foldexpr"] = 1
    end,
  },
  { "ethanholz/nvim-lastplace", config = true },
  { "stevearc/dressing.nvim", event = "VeryLazy" },
  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    branch = "0.1.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
      { "nvim-telescope/telescope-ui-select.nvim" },
      {
        "paopaol/telescope-git-diffs.nvim",
        dependencies = {
          "nvim-lua/plenary.nvim",
          "sindrets/diffview.nvim",
        },
      },
    },
    config = function()
      local telescope = require("telescope")

      telescope.setup({
        pickers = {
          buffers = {
            theme = "dropdown",
            previewer = false,
          },
        },
        extensions = {
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
        },
        defaults = {
          sorting_strategy = "ascending",
          layout_config = {
            prompt_position = "top",
            vertical = { mirror = false, width = 0.5, height = 0.5 },
            horizontal = { mirror = false, height = 0.5 },
          },
        },
      })

      telescope.load_extension("git_diffs")
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")

      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<C-g>", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>b", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
      vim.keymap.set("n", "<leader>w", builtin.grep_string, { desc = "Find Word" })
      vim.keymap.set("n", "<leader>fc", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>fcc", builtin.command_history, { desc = "Commands History" })
      vim.keymap.set("n", "<leader>fss", builtin.search_history, { desc = "Search History" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          winblend = 10,
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })
    end,
  },
  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      { "dgagn/diagflow.nvim", event = "LspAttach", opts = {} }, -- put diagnostic msg @ top right corner
      "elixir-editors/vim-elixir",
      "elixir-tools/elixir-tools.nvim",
      "jose-elias-alvarez/typescript.nvim",
      {
        "b0o/schemastore.nvim",
        version = false,
      },
      {
        "williamboman/mason.nvim",
        opts = {
          ui = {
            border = "rounded",
            icons = {
              package_installed = "✓",
              package_pending = "➜",
              package_uninstalled = "✗",
            },
          },
        },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            -- "cssls",
            "html",
            "jsonls",
            "tsserver",
            "tailwindcss",
            "svelte",
          },
        },
      },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    },
    config = function()
      -- https://github.com/neovim/nvim-lspconfig/wiki/UI-customization
      -- To instead override globally for all lsp borders
      local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview
      function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
        opts = opts or {}
        opts.border = opts.border or "single"
        return orig_util_open_floating_preview(contents, syntax, opts, ...)
      end

      -- ref: LazyVim & https://github.com/wookayin/dotfiles/blob/master/nvim/lua/config/lsp.lua
      -- lsp_diagnostics
      local signs = { Error = " ", Warn = " ", Hint = "⨁ ", Info = " " }
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

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc)
            vim.keymap.set("n", keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
          map("<leader>ls", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
          map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
          map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
          map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
          if vim.lsp.inlay_hint then
            map("<leader>uh", function()
              vim.lsp.inlay_hint(0, nil)
            end, "Toggle Inlay Hints")
          end

          -- Highlight references under the cursor and clear hl when moving cursor
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.server_capabilities.documentHighlightProvider then
            vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.document_highlight,
            })

            vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
              buffer = event.buf,
              callback = vim.lsp.buf.clear_references,
            })
          end

          if client.name == "tsserver" then
            map("<leader>o", "<cmd>TypescriptOrganizeImports<CR>", "Organize Imports")
            map("<leader>R", "<cmd>TypescriptRenameFile<CR>", "Rename File")
          end

          if client.name == "elixirls" then
            vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
            vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })
          end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- jose-elias-alvarez/typescript.nvim
      require("typescript").setup({
        disable_commands = false, -- prevent the plugin from creating Vim commands
        debug = false, -- enable debug logging for commands
        go_to_source_definition = {
          fallback = true, -- fall back to standard LSP definition on failure
        },
      })

      require("elixir").setup({
        nextls = { enable = false },
        credo = { enable = true },
        elixirls = { enable = false },
      })

      -- Enable the following language servers
      --  Add any additional override configuration in the following tables. Available keys are:
      --  - cmd (table): Override the default command used to start the server
      --  - filetypes (table): Override the default list of associated filetypes for the server
      --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
      --  - settings (table): Override the default settings passed when initializing the server.
      --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
      local servers = {
        lua_ls = {
          settings = {
            Lua = {
              completion = { callSnippet = "Replace" },
              telemetry = { enable = false },
              hint = { enable = true },
              diagnostics = { globals = { "vim" } },
            },
          },
        },
        -- lexical = {
        --   cmd = { "/home/hvaria/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
        --   filetypes = { "elixir", "eelixir", "heex" },
        --   root_dir = function(fname)
        --     return require("lspconfig").util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
        --   end,
        --   settings = {},
        -- },
        elixirls = { settings = { dialyzerEnabled = false, enableTestLenses = true } },
        tsserver = {
          settings = {
            completions = { completeFunctionCalls = true },
            javascript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = true,
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
            typescript = {
              inlayHints = {
                includeInlayEnumMemberValueHints = true,
                includeInlayFunctionLikeReturnTypeHints = true,
                includeInlayFunctionParameterTypeHints = true,
                includeInlayParameterNameHints = true,
                includeInlayParameterNameHintsWhenArgumentMatchesName = true,
                includeInlayPropertyDeclarationTypeHints = true,
                includeInlayVariableTypeHints = true,
              },
            },
          },
        },
        jsonls = {
          -- lazy-load schemastore when needed
          on_new_config = function(new_config)
            new_config.settings.json.schemas = new_config.settings.json.schemas or {}
            vim.list_extend(new_config.settings.json.schemas, require("schemastore").json.schemas())
          end,
          settings = { json = { validate = { enable = true } } },
        },
        -- cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
        tailwindcss = {},
        svelte = {},
      }

      -- Ensure the servers and tools above are installed
      require("mason").setup()

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      vim.list_extend(ensure_installed, {
        "stylua", -- Used to format Lua code
      })
      require("mason-tool-installer").setup({ ensure_installed = ensure_installed })

      require("mason-lspconfig").setup({
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            require("lspconfig")[server_name].setup(server)
          end,
        },
      })

      -- local lspconfig = require("lspconfig")
      -- local configs = require("lspconfig.configs")
      --
      -- local lexical_config = {
      --   filetypes = { "elixir", "eelixir", "heex" },
      --   cmd = { "/home/hvaria/lexical/_build/dev/package/lexical/bin/start_lexical.sh" },
      --   settings = {},
      -- }
      --
      -- if not configs.lexical then
      --   configs.lexical = {
      --     default_config = {
      --       filetypes = lexical_config.filetypes,
      --       cmd = lexical_config.cmd,
      --       root_dir = function(fname)
      --         return lspconfig.util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
      --       end,
      --       -- optional settings
      --       settings = lexical_config.settings,
      --     },
      --   }
      -- end
      --
      -- lspconfig.lexical.setup({
      --   capabilities = vim.tbl_deep_extend("force", {}, capabilities, lspconfig.lexical.capabilities or {}),
      -- })
    end,
  },
  -- linter
  {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")

      lint.linters_by_ft = {
        javascript = { "eslint_d" },
        typescript = { "eslint_d" },
        svelte = { "eslint_d" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
        end,
      })
    end,
  },
  -- Autoformat
  {
    "stevearc/conform.nvim",
    config = function()
      local conform = require("conform")

      conform.setup({
        notify_on_error = false,
        format_on_save = function(bufnr)
          local disabled_filetypes = { c = true, cpp = true }
          return {
            timeout_ms = 500,
            lsp_fallback = not disabled_filetypes[vim.bo[bufnr].filetype],
          }
        end,
        formatters_by_ft = {
          javascript = { { "prettierd", "prettier" } },
          typescript = { { "prettierd", "prettier" } },
          svelte = { { "prettierd", "prettier" } },
          css = { { "prettierd", "prettier" } },
          html = { { "prettierd", "prettier" } },
          json = { { "prettierd", "prettier" } },
          yaml = { { "prettierd", "prettier" } },
          markdown = { { "prettierd", "prettier" } },
          lua = { "stylua" },
        },
      })

      vim.keymap.set({ "n", "v" }, "<leader>p", function()
        conform.format({
          lsp_fallback = true,
          timeout_ms = 500,
        })
      end, { desc = "Format file or range (in visual mode)" })
    end,
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
        desc = "Document Diagnostics (Trouble)",
      },
      {
        "<leader>xX",
        "<cmd>TroubleToggle workspace_diagnostics<cr>",
        desc = "Workspace Diagnostics (Trouble)",
      },
      {
        "<leader>xL",
        "<cmd>TroubleToggle loclist<cr>",
        desc = "Location List (Trouble)",
      },
      {
        "<leader>xQ",
        "<cmd>TroubleToggle quickfix<cr>",
        desc = "Quickfix List (Trouble)",
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
    event = "VimEnter",
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

  -- auto completion
  { "windwp/nvim-autopairs", config = true },
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter", -- load cmp on InsertEnter
    -- these dependencies will only be loaded when cmp loads
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
        config = function()
          local lsnip = require("luasnip")
          require("luasnip.loaders.from_lua").load({ paths = "~/dotfiles/snippets/" })
          lsnip.config.set_config({
            history = true, -- keep around last snippet local to jump back
            updateevents = "TextChanged,TextChangedI", -- update changes as you type
            delete_check_events = "TextChanged",
            enable_autosnippets = true,
            ext_opts = {
              [require("luasnip.util.types").choiceNode] = {
                active = { virt_text = { { "·", "Question" } } },
              },
            },
          })
        end,
        keys = {
          {
            "<a-l>",
            function()
              return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
          },
          {
            "<a-l>",
            function()
              require("luasnip").jump(1)
            end,
            mode = "s",
          },
          {
            "<a-h>",
            function()
              require("luasnip").jump(-1)
            end,
            mode = { "i", "s" },
          },
        },
      },
      "saadparwaiz1/cmp_luasnip",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "kdheepak/cmp-latex-symbols",
      "onsails/lspkind-nvim",
      { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    config = function()
      local cmp = require("cmp")
      local snip_status_ok, luasnip = pcall(require, "luasnip")
      local lspkind_status_ok, lspkind = pcall(require, "lspkind")
      if not snip_status_ok then
        return
      end
      local border_opts = {
        border = "single",
        winhighlight = "CursorLine:Visual",
      }

      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ filetypes = { tex = false } }))

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local format_kinds = lspkind_status_ok and lspkind.cmp_format({ maxwidth = 50, ellipsis_char = "..." }) or nil

      cmp.setup({
        formatting = {
          -- ref: https://www.youtube.com/watch?v=_NiWhZeR-MY
          format = function(entry, item)
            if format_kinds ~= nil then
              format_kinds(entry, item) -- add icons
              return require("tailwindcss-colorizer-cmp").formatter(entry, item)
            end
          end,
        },
        completion = {
          completeopt = "menu,menuone,preview,noselect",
        },
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
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
          ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
          ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
          ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
          ["<C-y>"] = cmp.config.disable,
          ["<C-e>"] = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
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
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
          { name = "latex_symbols", priority = 200 },
        }),
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      })
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "tokyonight",
          globalstatus = true,
          component_separators = "|",
          section_separators = "",
          disabled_filetypes = { "Telescope", "Outline", "dashboard" },
          always_divide_middle = true,
        },
        sections = {
          lualine_a = {
            {
              -- mode
              function()
                return " "
              end,
              padding = { left = 0, right = 0 },
            },
          },
        },
        tabline = {},
        extensions = { "quickfix", "neo-tree", "fzf", "trouble", "mason", "aerial" },
      })
    end,
  },
  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    cmd = "Neotree",
    version = "v3.*",
    dependencies = { "MunifTanjim/nui.nvim" },
    keys = {
      { "<F2>", "<cmd>Neotree toggle<CR>", desc = "Toggle NeoTree" },
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
      enable_git_status = false,
      source_selector = { statusline = true },
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
      },
      window = {
        width = "26",
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
      },
    },
  },
  -- search/replace in multiple files
  {
    "windwp/nvim-spectre",
    keys = {
      {
        "<A-s>",
        function()
          require("spectre").open()
        end,
        desc = "Replace in files (spectre)",
      },
    },
  },
  {
    -- Code skimming or outline for quick navigation
    "stevearc/aerial.nvim",
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "<A-d>", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "<A-f>", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    },
  },
  {
    "JoosepAlviste/nvim-ts-context-commentstring",
    lazy = false,
    config = function()
      require("ts_context_commentstring").setup({
        enable_autocmd = false,
      })
      vim.g["skip_ts_context_commentstring_module"] = true
    end,
  },
  {
    "numToStr/Comment.nvim",
    lazy = false,
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" }, -- Allow commenting embedded lang in files
    config = function()
      require("Comment").setup({
        pre_hook = require("ts_context_commentstring.integrations.comment_nvim").create_pre_hook(),
      })
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = {
      {
        "windwp/nvim-ts-autotag",
        ft = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "xml",
          "markdown",
          "heex",
        },
      },
      "RRethy/nvim-treesitter-endwise",
    },
    opts = {
      autotag = {
        enable = true, -- windwp/nvim-ts-autotag
        filetypes = {
          "html",
          "javascript",
          "typescript",
          "javascriptreact",
          "typescriptreact",
          "svelte",
          "vue",
          "tsx",
          "jsx",
          "xml",
          "markdown",
          "heex",
        },
      },
      endwise = { enable = true }, -- RRethy/nvim-treesitter-endwise
      highlight = { enable = true },
      indent = { enable = true, disable = { "python" } }, -- guess-indent is better and faster
      -- context_commentstring = { enable = true, enable_autocmd = false }, -- nvim-ts-context-commentstring
      ensure_installed = {
        "vim",
        "lua",
        "markdown",
        "markdown_inline",
        "bash",
        "regex",
        "css",
        "html",
        "javascript",
        "json",
        "typescript",
        "tsx",
        "svelte",
        "erlang",
        "elixir",
        "sql",
        "eex",
        "heex",
        "ledger", --, "toml", "zig"
      },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = "<a-s>",
          node_decremental = "<space>",
        },
      },
    },
    config = function(_, opts)
      require("nvim-treesitter.configs").setup(opts)
    end,
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { current_line_blame = false },
  },
  {
    "j-hui/fidget.nvim",
    tag = "legacy",
    event = "LspAttach",
    config = true,
  },
  { "pbrisbin/vim-mkdir", event = "VeryLazy" }, -- :e this/does/not/exist/file.txt then :w
  { "justinmk/vim-gtfo", event = "VeryLazy" }, -- gof open file in filemanager
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = "sql",
    dependencies = { "tpope/vim-dadbod" },
    config = function()
      vim.g["db"] = "postgresql://postgres:@localhost/mgp_dev"
      vim.keymap.set("x", "<Plug>(DBExe)", "db#op_exec()", { expr = true })
      vim.keymap.set("n", "<Plug>(DBExe)", "db#op_exec()", { expr = true })
      vim.keymap.set("n", "<Plug>(DBExeLine)", "db#op_exec() . '_'", { expr = true })
      vim.keymap.set("x", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("n", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("o", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("n", "<leader>dd", "<Plug>(DBExeLine)")
    end,
  },
  -- {
  --   'kaarmu/typst.vim', ft = 'typst', lazy = false
  -- },
  {
    "lervag/vimtex", -- don't lazy load since it breaks the plugin + plugin automatically loads based on ft
    config = function()
      vim.g["vimtex_quickfix_mode"] = 0
      vim.g["vimtex_compiler_method"] = "tectonic"
      vim.g["vimtex_view_general_viewer"] = "evince"
      vim.g["vimtex_fold_enabled"] = true
    end,
  },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    version = "*",
    opts = { open_mapping = [[<C-\>]], shading_factor = 1 },
  },
  {
    "echasnovski/mini.surround", -- sr({ sd' <select text>sa'
    keys = { "sr", "sh", "sf", "sF", "sd", "sn", { "sa", mode = "v" } }, -- Only load on these keystrokes
    version = false,
    config = function()
      require("mini.surround").setup()
    end,
  },
  {
    "echasnovski/mini.align",
    event = "VeryLazy",
    version = false,
    config = function()
      require("mini.align").setup()
    end,
  },
  { "mg979/vim-visual-multi", version = false, event = "VeryLazy" },
  { "karb94/neoscroll.nvim", config = true },
  {
    "vim-test/vim-test",
    config = function()
      vim.cmd([[
        function! BufferTermStrategy(cmd)
          exec 'te ' . a:cmd
        endfunction

        let g:test#custom_strategies = {'bufferterm': function('BufferTermStrategy')}
        let g:test#strategy = 'bufferterm'
      ]])
    end,
    keys = {
      { "<leader>Tf", "<cmd>TestFile<cr>", silent = true, desc = "Run this file" },
      { "<leader>Tn", "<cmd>TestNearest<cr>", silent = true, desc = "Run nearest test" },
      { "<leader>Tl", "<cmd>TestLast<cr>", silent = true, desc = "Run last test" },
    },
  },
}, {
  checker = { enabled = false, notify = false },
  ui = { border = "rounded" },
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
      },
    },
  },
})

-------------------- OPTIONS -------------------------------
local width = 85
-- global options
vim.opt.hlsearch = true
vim.opt.backup = false
vim.opt.breakindent = true
vim.opt.completeopt = "menu,menuone,noselect" -- Completion options
vim.opt.conceallevel = 3 -- Hide * markip for bold and italic
vim.opt.cursorline = false -- Highlight cursor line
vim.opt.equalalways = false -- I don't like my windows changing all the time
vim.opt.expandtab = true -- Use spaces instead of tabs
vim.opt.foldcolumn = "0" -- '0' is not bad
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
vim.opt.foldenable = true
vim.opt.foldmethod = "indent" -- expr
-- vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.formatoptions = "q1jl" -- Automatic formatting options
vim.cmd([[set formatoptions-=ro]])
vim.opt.guicursor = "i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon1"
vim.opt.grepformat = "%f:%l:%c:%m"
vim.opt.grepprg = "rg --vimgrep"
vim.opt.ignorecase = true -- Ignore case
vim.opt.joinspaces = false -- No double spaces with join
vim.opt.laststatus = 3 -- global statusline
vim.opt.linebreak = true
vim.opt.list = true -- Show some invisible characters
vim.opt.listchars = "tab:▸ ,extends:>,precedes:<"
vim.opt.mouse = "a" -- Allow the mouse
vim.opt.number = true -- Show line numbers
vim.opt.pumheight = 10 -- Maximum number of entries in a popup
vim.opt.scrolljump = 4 -- min. lines to scroll
vim.opt.scrolloff = 10 -- Lines of context
vim.opt.shiftround = true -- Round indent
vim.opt.shiftwidth = 2 -- Size of an indent
-- vim.opt.shortmess                = 'IFc' -- Avoid showing extra message on completion
vim.opt.shortmess:append({ W = true, I = true, c = true })
vim.opt.showbreak = "↪  "
vim.opt.showbreak = "↪  "
vim.opt.showmatch = true
vim.opt.showmode = false -- Don't show mode since we have a statusline
vim.opt.sidescrolloff = 8 -- Columns of context
vim.opt.signcolumn = "yes:1" -- Show sign column
vim.opt.smartcase = true -- Don't ignore case with capitals
-- vim.opt.smartindent   = true    -- Insert indents automatically
vim.opt.spelllang = { "en_GB" }
vim.opt.softtabstop = 2
vim.opt.splitbelow = true -- Put new windows below current
vim.opt.splitright = true -- Put new windows right of current
vim.opt.swapfile = false
vim.opt.tabstop = 2 -- Number of spaces tabs count for
vim.opt.termguicolors = true -- True color support
vim.opt.textwidth = width -- Maximum width of text
vim.opt.timeoutlen = 300 -- mapping timeout
vim.opt.undodir = "/home/hvaria/.nvim/undo"
vim.opt.undofile = true
vim.opt.updatetime = 250 -- make updates faster and trigger CursorHold
vim.opt.wildmode = "longest:full,full" -- Command-line completion mode
vim.opt.winminwidth = 5 -- Minimum window width
vim.opt.wrap = false -- Disable line wrap
vim.opt.writebackup = false

-------------------- MAPPINGS ------------------------------
-- Personal common tasks
vim.keymap.set("n", "<C-p>", "<cmd>lua require('telescope.builtin').git_files()<CR>")
vim.keymap.set("n", "<BS>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<F4>", "<cmd>set spell!<CR>")
vim.keymap.set("n", "<F5>", "<cmd>ColorizerToggle<CR>")
vim.keymap.set("i", "<C-u>", "<C-g>u<C-u>") -- Delete lines in insert mode
vim.keymap.set("i", "<C-w>", "<C-g>u<C-w>") -- Delete words in insert mode

-- Easier movement
vim.keymap.set("n", "q", "<C-w>c")
vim.keymap.set("n", "H", "^")
vim.keymap.set("n", "L", "g_")
vim.keymap.set("n", "F", "%")
vim.keymap.set("v", "L", "g_")

-- better up/down
vim.keymap.set("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
vim.keymap.set("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- gF is a more useful default than gF
vim.keymap.set("n", "gf", "gF", { silent = true })

-- better escape
vim.keymap.set("i", "jk", "<Esc>")
vim.keymap.set("i", "jj", "<Esc>")

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("t", "<C-h>", "<C-\\><C-N><C-w>h")
vim.keymap.set("t", "<C-j>", "<C-\\><C-N><C-w>j")
vim.keymap.set("t", "<C-k>", "<C-\\><C-N><C-w>k")
vim.keymap.set("t", "<C-l>", "<C-\\><C-N><C-w>l")
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Move Lines
vim.keymap.set("n", "<A-j>", "<cmd>m .+1<cr>==", { desc = "Move down" })
vim.keymap.set("n", "<A-k>", "<cmd>m .-2<cr>==", { desc = "Move up" })
vim.keymap.set("i", "<A-j>", "<esc><cmd>m .+1<cr>==gi", { desc = "Move down" })
vim.keymap.set("i", "<A-k>", "<esc><cmd>m .-2<cr>==gi", { desc = "Move up" })
vim.keymap.set("v", "<A-j>", ":m '>+1<cr>gv=gv", { desc = "Move down" })
vim.keymap.set("v", "<A-k>", ":m '<-2<cr>gv=gv", { desc = "Move up" })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<A-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<A-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<A-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<A-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

-- buffers
vim.keymap.set("n", "<Right>", "<cmd>BufferLineCycleNext<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<Left>", "<cmd>BufferLineCyclePrev<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>BufferLineCyclePrev<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferLineCycleNext<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "<A-1>", "<cmd>BufferLineGoToBuffer 1<cr>", { desc = "Goto Buffer 1" })
vim.keymap.set("n", "<A-2>", "<cmd>BufferLineGoToBuffer 2<cr>", { desc = "Goto Buffer 2" })
vim.keymap.set("n", "<A-3>", "<cmd>BufferLineGoToBuffer 3<cr>", { desc = "Goto Buffer 3" })
vim.keymap.set("n", "<A-4>", "<cmd>BufferLineGoToBuffer 4<cr>", { desc = "Goto Buffer 4" })
vim.keymap.set("n", "<A-5>", "<cmd>BufferLineGoToBuffer 5<cr>", { desc = "Goto Buffer 5" })
vim.keymap.set("n", "<A-6>", "<cmd>BufferLineGoToBuffer 6<cr>", { desc = "Goto Buffer 6" })
vim.keymap.set("n", "<A-7>", "<cmd>BufferLineGoToBuffer 7<cr>", { desc = "Goto Buffer 7" })
vim.keymap.set("n", "<A-8>", "<cmd>BufferLineGoToBuffer 8<cr>", { desc = "Goto Buffer 8" })
vim.keymap.set("n", "<A-9>", "<cmd>BufferLineGoToBuffer 9<cr>", { desc = "Goto Buffer 9" })

-- Try and center these motions to the middle of the screen
vim.keymap.set({ "n", "x" }, "gw", "*Nzz", { desc = "Search word under cursor" })
vim.keymap.set("n", "n", "nzz", { silent = true })
vim.keymap.set("n", "N", "Nzz", { silent = true })
vim.keymap.set("n", "*", "*zz", { silent = true })
vim.keymap.set("n", "#", "#zz", { silent = true })
vim.keymap.set("n", "g*", "g*zz", { silent = true })
vim.keymap.set("n", "g#", "g#zz", { silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { silent = true })
vim.keymap.set("n", "u", "uzz", { silent = true })
vim.keymap.set("n", "<C-r>", "<C-r>zz", { silent = true })
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })
-- vim.keymap.set('n', '<C-d>', '<C-d>zz', { silent = true })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>update<cr><esc>", { desc = "Save file" })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Faster close buffer and window
vim.keymap.set("n", "Q", "<cmd>Bdelete<cr>")

-- which-key
local wk = require("which-key")
wk.register({
  ["y"] = { '"+y', "Yank System Clipboard" },
  ["."] = { "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", "Comment" },
  t = {
    name = "ToggleTerm",
    v = { "<cmd>ToggleTermSendVisualLines<cr>", "Send Visual Line" },
    s = { "<cmd>ToggleTermSendVisualSelection<cr>", "Send Visual Selection" },
  },
}, { prefix = "<leader>", mode = "v" })
wk.register({
  ["a"] = { "<cmd>AerialToggle!<CR>", "AerialToggle" },
  ["."] = { "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", "Comment" },
  ["<leader>"] = { "<C-^>", "Last buffer" },
  ["m"] = { "<cmd>Mason<cr>", "Mason [LSP Manager]" }, -- mason plugin
  ["r"] = { "<cmd>lua require('telescope.builtin').oldfiles()<CR>", "Recent Files" },
  ["s"] = { "<cmd>split<CR>", "Split horizontal" },
  ["v"] = { "<C-w>v<C-w>l", "Split vertical" },
  ["w"] = { "<cmd>w!<CR>", "Save" },
  ["c"] = { "<cmd>ToggleTerm<CR>", "ToggleTerm" },
  ["d"] = { "<cmd>Bdelete<CR>", "Close Buffer" }, -- bufdelete plugin
  ["z"] = { "<cmd>Lazy<CR>", "Lazy [Plugin Manager]" }, -- lazy plugin
  ["t"] = { "<cmd>ToggleTermSendCurrentLine<cr>", "Send Current Line to Term" },
  l = {
    name = "LSP",
    a = { "<cmd>lua vim.lsp.buf.code_action()<cr>", "Code Action" },
    c = { "<cmd>lua vim.lsp.codelens.run()<cr>", "CodeLens Action" },
    d = { "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", "Definition" },
    D = { "<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>", "Buffer Diagnostics" },
    f = { "<cmd>lua vim.lsp.buf.format()<cr>", "Format" },
    i = { "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", "Implementation" },
    j = { "<cmd>lua vim.diagnostic.goto_next()<cr>", "Next Diagnostic" },
    k = { "<cmd>lua vim.diagnostic.goto_prev()<cr>", "Prev Diagnostic" },
    l = { "<cmd>LspInfo<cr>", "Info" },
    t = { "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>", "Type Definition" },
    w = { "<cmd>lua require('telescope.builtin').diagnostics()<cr>", "Diagnostics" },
    q = { "<cmd>lua vim.diagnostic.setloclist()<cr>", "Quickfix" },
    R = { "<cmd>lua vim.lsp.buf.rename()<cr>", "Rename" },
    r = { "<cmd>lua require('telescope.builtin').lsp_references()<cr>", "References" },
    I = { "<cmd>lua require('telescope.builtin').lsp_incoming_calls()<cr>", "Incoming calls" },
    O = { "<cmd>lua require('telescope.builtin').lsp_outgoing_calls()<cr>", "Outgoing calls" },
    s = { "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", "Document Symbols" },
    S = { "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>", "Workspace Symbols" },
    h = { "<cmd>lua vim.lsp.inlay_hint(0, nil)<cr>", "Toggle Inlay Hints" },
  },
  g = {
    name = "Git",
    c = { "<cmd>lua require('telescope.builtin').git_commits()<cr>", "Commits" },
    b = { "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", "Buffer Commits" },
    B = { "<cmd>lua require('telescope.builtin').git_branches()<cr>", "Branches" },
    s = { "<cmd>lua require('telescope.builtin').git_status()<cr>", "Status" },
    d = { "<cmd>lua require('telescope').extensions.git_diffs.diff_commits()<cr>", "Diff history" },
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
    vim.highlight.on_yank()
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
  vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], opts)
  vim.keymap.set("t", "jk", [[<C-\><C-n>]], opts)
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufNew", "TermOpen" }, {
  group = augroup("term_group"),
  pattern = "term://*",
  callback = function()
    vim.cmd([[startinsert]])
    vim.cmd([[setlocal nonumber norelativenumber nospell signcolumn=auto]])
    vim.cmd([[lua set_terminal_keymaps()]])
  end,
})

-- Elixir autocommands like abbreviation of pipe as pp
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("elixir_group"),
  pattern = "elixir,eelixir",
  callback = function()
    vim.cmd([[iab pp \|>]])
  end,
})

-- SQL cmp
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("sql_cmp"),
  pattern = "sql,mysql,plsql",
  callback = function()
    require("cmp").setup.buffer({ sources = { { name = "vim-dadbod-completion" } } })
  end,
})

-- Postcss
vim.filetype.add({ extension = { postcss = "css" } })

-- Help Buffer
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("help"),
  pattern = "help",
  callback = function()
    vim.cmd([[wincmd L | vert res 83<CR>]])
    vim.cmd([[nnoremap <buffer><cr> <c-]>]])
    vim.cmd([[nnoremap <buffer><bs> <c-T>]])
  end,
})

-- Autocmd to save folds for a file
-- https://github.com/AstroNvim/AstroNvim/blob/271c9c3f71c2e315cb16c31276dec81ddca6a5a6/lua/astronvim/autocmds.lua#L98-L120
local view_group = vim.api.nvim_create_augroup("auto_view", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinLeave", "BufWritePost", "WinLeave" }, {
  desc = "Save view with mkview for real files",
  group = view_group,
  callback = function(args)
    if vim.b[args.buf].view_activated then
      vim.cmd.mkview({ mods = { emsg_silent = true } })
    end
  end,
})
vim.api.nvim_create_autocmd("BufWinEnter", {
  desc = "Try to load file view if available and enable view saving for real files",
  group = view_group,
  callback = function(args)
    if not vim.b[args.buf].view_activated then
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = args.buf })
      local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
      local ignore_filetypes = { "gitcommit", "gitrebase", "svg", "hgcommit" }
      if buftype == "" and filetype and filetype ~= "" and not vim.tbl_contains(ignore_filetypes, filetype) then
        vim.b[args.buf].view_activated = true
        vim.cmd.loadview({ mods = { emsg_silent = true } })
      end
    end
  end,
})
