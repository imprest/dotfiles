-- Based of https://github.com/LazyVim/LazyVim & https://astronvim.com
-------------------- HELPERS -------------------------------
vim.g["loaded_python_provider"] = 1
vim.g["python3_host_prog"] = "/usr/bin/python3"
vim.g.mapleader = ","
vim.g.maplocalleader = "<"
vim.g.have_nerd_font = true

-------------------- LAZY.NVIM -----------------------------
-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

-------------------- PLUGINS -------------------------------
require("lazy").setup({
  {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
      icons = { mappings = vim.g.have_nerd_font, keys = vim.g.have_nerd_font and {} },
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
    ft = { "javascript", "typescript", "css", "html" },
    cmd = "ColorizerToggle",
    opts = { user_default_options = { tailwind = true } },
  },
  {
    "catppuccin/nvim",
    lazy = true,
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
    opts = {
      integrations = {
        aerial = true,
        cmp = true,
        grug_far = true,
        gitsigns = true,
        indent_blankline = { enabled = true },
        lsp_trouble = true,
        mason = true,
        markdown = true,
        mini = true,
        native_lsp = {
          enabled = true,
          underlines = {
            errors = { "undercurl" },
            hints = { "undercurl" },
            warnings = { "undercurl" },
            information = { "undercurl" },
          },
        },
        neotest = true,
        neotree = false,
        semantic_tokens = true,
        telescope = true,
        treesitter = true,
        treesitter_context = true,
        which_key = true,
      },
    },
  },
  {
    "nvimdev/dashboard-nvim",
    event = "VimEnter",
    config = function()
      require("dashboard").setup({
        -- config
      })
    end,
    dependencies = { { "nvim-tree/nvim-web-devicons" } },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "famiu/bufdelete.nvim", { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font } },
    after = "catppuccin",
    opts = {
      highlights = { fill = { bg = "" }, buffer_selected = { italic = false } },
      options = {
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
  {
    "amrbashir/nvim-docs-view",
    lazy = true,
    cmd = "DocsViewUpdate",
    opts = { update_mode = "manual" },
    keys = { { "<leader>k", "<cmd>DocsViewUpdate<CR>", mode = "", desc = "DocsViewUpdate" } },
  },
  { "stevearc/dressing.nvim", event = "VeryLazy" },
  -- Fuzzy Finder (files, lsp, etc)
  {
    "nvim-telescope/telescope.nvim",
    event = "VimEnter",
    -- branch = "0.1.x",
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
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fa", builtin.builtin, { desc = "Select Telescope" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fC", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Commands History" })
      vim.keymap.set("n", "<leader>fs", builtin.search_history, { desc = "Search History" })

      vim.keymap.set("n", "<leader>/", function()
        builtin.current_buffer_fuzzy_find(require("telescope.themes").get_dropdown({
          previewer = false,
        }))
      end, { desc = "[/] Fuzzily search in current buffer" })

      vim.keymap.set("n", "<leader>f/", function()
        builtin.live_grep({
          grep_open_files = true,
          prompt_title = "Live Grep in Open Files",
        })
      end, { desc = "[S]earch [/] in Open Files" })
    end,
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup()
    end,
  },
  -- LSP
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      {
        "b0o/schemastore.nvim",
        version = false,
      },
      {
        "williamboman/mason.nvim",
        opts = { ui = { border = "rounded" } },
      },
      {
        "williamboman/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "cssls",
            "html",
            "jsonls",
            "ts_ls",
            "tailwindcss",
            "svelte",
            "elixirls",
            "typst_lsp",
          },
        },
      },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = { notification = { window = { winblend = 0 } } } },
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
        virtual_text = false,
        severity_sort = true,
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
          map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
          map("gi", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
          map("<leader>D", require("telescope.builtin").lsp_implementations, "Type [D]efinition")
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle In[l]ay [H]ints")
          end
          -- custom keymaps for individual lsp servers
          -- if client.name == "elixirls" then
          -- map("<space>fp", ":ElixirFromPipe<cr>", "Elixir From Pipe")
          -- map("<space>tp", ":ElixirToPipe<cr>", "Elixir To Pipe")
          -- map("v", "<space>em", ":ElixirExpandMacro<cr>", "Elixir Expand Macro")
          -- end
        end,
      })

      -- LSP servers and clients are able to communicate to each other what features they support.
      --  By default, Neovim doesn't support everything that is in the LSP specification.
      --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = vim.tbl_deep_extend("force", capabilities, require("cmp_nvim_lsp").default_capabilities())

      -- Enable the following language servers
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
        typst_lsp = {},
        elixirls = {
          dialyzerEnabled = false,
          settings = {
            cmd = "/home/hvaria/.local/share/nvim/mason/bin/elixir-ls",
            enableTestLenses = true,
          },
        },
        ts_ls = {
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
        html = { filetypes = { "html", "twig", "hbs" } },
        cssls = { settings = { css = { lint = { unknownAtRules = "ignore" } } } },
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

      -- require("lspconfig").gleam.setup({
      --   capabilities = vim.tbl_deep_extend("force", {}, capabilities, {}),
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
        javascript = { "eslint" },
        typescript = { "eslint" },
        svelte = { "eslint" },
        elixir = { "credo" },
      }

      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          lint.try_lint()
          -- Only run the linter in buffers that you can modify in order to
          -- avoid superfluous noise, notably within the handy LSP pop-ups that
          -- describe the hovered symbol using Markdown.
          if vim.opt_local.modifiable:get() then
            lint.try_lint()
          end
        end,
      })
    end,
  },
  -- Autoformat
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        "<leader>F",
        function()
          require("conform").format({ async = true, lsp_format = "fallback" })
        end,
        mode = "",
        desc = "[F]ormat buffer",
      },
    },
    opts = {
      notify_on_error = false,
      format_on_save = function(bufnr)
        local disable_filetypes = { c = true, cpp = true }
        local lsp_format_opt
        if disable_filetypes[vim.bo[bufnr].filetype] then
          lsp_format_opt = "never"
        else
          lsp_format_opt = "fallback"
        end
        return {
          timeout_ms = 500,
          lsp_format = lsp_format_opt,
        }
      end,
      formatters_by_ft = {
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        svelte = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
        lua = { "stylua" },
      },
    },
  },
  -- better diagnostics list and others
  {
    "folke/trouble.nvim",
    cmd = { "Trouble" },
    opts = {
      modes = {
        lsp = {
          win = { position = "right" },
        },
      },
    },
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>", desc = "Symbols (Trouble)" },
      {
        "<leader>xS",
        "<cmd>Trouble lsp toggle<cr>",
        desc = "LSP references/definitions/... (Trouble)",
      },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>", desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      {
        "[q",
        function()
          if require("trouble").is_open() then
            require("trouble").prev({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cprev)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Previous Trouble/Quickfix Item",
      },
      {
        "]q",
        function()
          if require("trouble").is_open() then
            require("trouble").next({ skip_groups = true, jump = true })
          else
            local ok, err = pcall(vim.cmd.cnext)
            if not ok then
              vim.notify(err, vim.log.levels.ERROR)
            end
          end
        end,
        desc = "Next Trouble/Quickfix Item",
      },
    },
  },

  -- Finds and lists all of the TODO, HACK, BUG, etc comment
  -- in your project and loads them into a browsable list.
  {
    "folke/todo-comments.nvim",
    cmd = { "TodoTrouble", "TodoTelescope" },
    event = "VeryLazy",
    opts = {},
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end,              desc = "Next Todo Comment" },
      { "[t",         function() require("todo-comments").jump_prev() end,              desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                                   desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>", desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>ft", "<cmd>TodoTelescope<cr>",                                         desc = "Todo" },
      { "<leader>fT", "<cmd>TodoTelescope keywords=TODO,FIX,FIXME<cr>",                 desc = "Todo/Fix/Fixme" },
    },
  },

  -- auto completion
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  {
    "hrsh7th/nvim-cmp",
    version = false,
    event = "InsertEnter",
    dependencies = {
      {
        "L3MON4D3/LuaSnip",
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
            "<C-left>",
            function()
              return require("luasnip").jumpable(1) and "<Plug>luasnip-jump-next" or "<tab>"
            end,
            expr = true,
            silent = true,
            mode = "i",
          },
          {
            "<C-left>",
            function()
              require("luasnip").jump(1)
            end,
            mode = "s",
          },
          {
            "<C-right>",
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
      "onsails/lspkind-nvim",
      -- "kdheepak/cmp-latex-symbols",
      -- { "roobert/tailwindcss-colorizer-cmp.nvim", config = true },
    },
    config = function()
      vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
      local cmp = require("cmp")
      local snip_status_ok, luasnip = pcall(require, "luasnip")
      local lspkind = require("lspkind")
      if not snip_status_ok then
        return
      end

      -- If you want insert `(` after select function or method item
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done({ filetypes = { tex = false } }))

      local has_words_before = function()
        unpack = unpack or table.unpack
        local line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
      end

      local auto_select = false
      cmp.setup({
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        formatting = {
          fields = { "kind", "abbr", "menu" },
          format = function(entry, item)
            -- ref: https://www.youtube.com/watch?v=_NiWhZeR-MY
            local kind = lspkind.cmp_format({
              mode = "symbol",
              maxwidth = 50,
              -- before = require("tailwindcss-colorizer-cmp").formatter,
            })(entry, item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "
            return kind
          end,
        },
        completion = {
          keyword_length = 2,
          completeopt = "menu,menuone,noselect" .. (auto_select and "" or ",noselect"),
        },
        preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
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
        mapping = cmp.mapping.preset.insert({
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
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                cmp.select_next_item()
              end
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            elseif has_words_before() then
              cmp.complete()
              if #cmp.get_entries() == 1 then
                cmp.confirm({ select = true })
              else
                fallback()
              end
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
        }),
        sources = {
          { name = "nvim_lsp" },
          { name = "nvim_lsp_signature_help" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
          -- { name = "latex_symbols", priority = 200 },
        },
        experimental = {
          ghost_text = {
            hl_group = "LspCodeLens",
          },
        },
      })
    end,
  },
  -- search/replace in multiple files
  {
    "MagicDuck/grug-far.nvim",
    opts = { headerMaxWidth = 80 },
    cmd = "GrugFar",
    keys = {
      {
        "<leader>S",
        function()
          local grug = require("grug-far")
          local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
          grug.open({
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= "" and "*." .. ext or nil,
            },
          })
        end,
        mode = { "n", "v" },
        desc = "Search and Replace",
      },
    },
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "catppuccin",
          globalstatus = true,
          section_separators = "",
          component_separators = "|",
          disabled_filetypes = { "Telescope", "Outline", "dashboard", "alpha", "neo-tree" },
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
          lualine_b = { "branch" },
          lualine_c = { { "filename", path = 1 }, "diff" },
          lualine_x = { "diagnostics", "encoding", "filetype" },
          lualine_y = {
            { "progress", separator = " ", padding = { left = 1, right = 0 } },
            { "location", padding = { left = 0, right = 1 } },
          },
          lualine_z = {
            function()
              return " " .. os.date("%R")
            end,
          },
        },

        tabline = {},
        extensions = { "quickfix", "neo-tree", "fzf", "trouble", "mason", "aerial", "lazy" },
      })
    end,
  },

  -- indent guides for Neovim
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        indent = {
          char = "│",
          tab_char = "│",
        },
        scope = { show_start = false, show_end = false },
        exclude = {
          filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
          },
        },
      }
    end,
    main = "ibl",
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
  {
    -- Code skimming or outline for quick navigation
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialPrev", "AerialNext" },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
      layout = { placement = "left" },
    },
  },
  { "folke/ts-comments.nvim", opts = {}, event = "VeryLazy" },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    main = "nvim-treesitter.configs", -- Sets main module to use for opts
    dependencies = { "RRethy/nvim-treesitter-endwise" },
    opts = {
      endwise = { enable = true }, -- RRethy/nvim-treesitter-endwise
      highlight = { enable = true },
      indent = { enable = true, disable = { "python" } }, -- guess-indent is better and faster
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
        "typst",
        "tsx",
        "svelte",
        "erlang",
        "elixir",
        -- "gleam",
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
          scope_incremental = false,
          node_decremental = "<space>",
        },
      },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { current_line_blame = false },
  },
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
  --   "lervag/vimtex", -- don't lazy load since it breaks the plugin + plugin automatically loads based on ft
  --   lazy = false,
  --   config = function()
  --     vim.g.vimtex_quickfix_mode = 0
  --     vim.g.vimtex_compiler_method = "tectonic"
  --     vim.g.vimtex_view_general_viewer = "evince"
  --     vim.g.vimtex_fold_enabled = true
  --   end,
  -- },
  {
    "akinsho/toggleterm.nvim",
    cmd = { "ToggleTerm", "TermExec" },
    version = "*",
    opts = { shading_factor = 1 },
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
    keys = { { "ga", mode = "v" }, { "gA", mode = "v" } },
    version = false,
    config = function()
      require("mini.align").setup()
    end,
  },
  { "echasnovski/mini.ai", version = false, opts = {} },
  -- { "mg979/vim-visual-multi", version = false, event = "VeryLazy" },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      "jfpedroza/neotest-elixir",
    },
    opts = {
      adapters = { ["neotest-elixir"] = {} },
    },
    keys = {
      {
        "<leader>tf",
        "<cmd>lua require('neotest').run.run(vim.fn.expand('%'))<cr>",
        silent = true,
        desc = "Run this file",
      },
      { "<leader>tn", "<cmd>lua require('neotest').run.run()<cr>", silent = true, desc = "Run nearest test" },
    },
  },
}, {
  checker = { enabled = false, notify = false },
  rocks = { enabled = false },
  ui = { border = "rounded" },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        "netrwPlugin",
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
local opt = vim.opt
opt.hlsearch = false
opt.backup = false
opt.breakindent = true
opt.conceallevel = 2 -- So that `` is visible in markdown files (default: 1)
opt.cursorline = true -- Highlight cursor line
opt.equalalways = false -- I don't like my windows changing all the time
opt.foldcolumn = "0"
opt.foldlevel = 99
opt.fillchars = { foldopen = "", foldclose = "", fold = " ", foldsep = " ", diff = "╱", eob = " " }
opt.formatoptions = "jcroqlnt" -- tcqj
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- Don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode. (default: 'croql')
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldtext = ""
opt.guicursor = "i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon1"
opt.grepformat = "%f:%l:%c:%m"
opt.grepprg = "rg --vimgrep"
opt.jumpoptions = "view"
opt.ignorecase = true -- Ignore case
opt.joinspaces = false -- No double spaces with join
opt.laststatus = 3 -- global statusline
opt.wrap = false -- Disable line wrap
opt.linebreak = true -- Companion to wrap, don't split words (default: false)
opt.autoindent = true -- Copy indent from current line when starting new one (default: true)
opt.list = true -- Show some invisible characters
opt.listchars = "tab:▸ ,extends:>,precedes:<" -- Don't change this line else cwd will not work
opt.mouse = "a" -- Allow the mouse
vim.wo.number = true -- Show line numbers
opt.pumblend = 10 -- Popup blend
opt.pumheight = 10 -- Maximum number of entries in a popup
opt.scrolljump = 4 -- min. lines to scroll
opt.scrolloff = 10 -- Lines of context
opt.sidescrolloff = 8 -- Columns of context
opt.shiftround = true -- Round indent
opt.showbreak = "↪  "
opt.showbreak = "↪  "
opt.showmatch = true
opt.showmode = false -- Don't show mode since we have a statusline
vim.wo.signcolumn = "yes" -- Show sign column
opt.smartcase = true -- Don't ignore case with capitals
opt.spelllang = { "en" }
opt.shiftwidth = 2 -- Size of an indent
opt.tabstop = 2 -- Number of spaces tabs count for
opt.softtabstop = 2
opt.expandtab = true -- Use spaces instead of tabs
opt.splitbelow = true -- Put new windows below current
opt.splitkeep = "screen"
opt.splitright = true -- Put new windows right of current
opt.smartindent = true -- Make indenting smarter again (default: false)
opt.termguicolors = true -- True color support
opt.textwidth = width -- Maximum width of text
opt.winminwidth = 5 -- Minimum window width
opt.swapfile = false
opt.writebackup = false
opt.updatetime = 200 -- make updates faster and trigger CursorHold
opt.timeoutlen = 300 -- mapping timeout
opt.undofile = true
opt.undolevels = 10000
opt.undodir = "/home/hvaria/.nvim/undo"
opt.completeopt = "menu,menuone,noselect" -- Completion options
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.iskeyword:append("-") -- Hyphenated words recognized by searches (default: does not include '-')
opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
opt.wildmode = "longest:full,full" -- Command-line completion mode

-------------------- MAPPINGS ------------------------------
-- Personal common tasks
vim.keymap.set("n", "<C-p>", "<cmd>lua require('telescope.builtin').git_files()<CR>")
vim.keymap.set("n", "<BS>", "<cmd>nohlsearch<CR>")
vim.keymap.set("n", "<F4>", "<cmd>set spell!<CR>")
vim.keymap.set("n", "<F5>", "<cmd>ColorizerToggle<CR>")
vim.keymap.set("i", "<C-u>", "<C-g>u<C-u>") -- Delete lines in insert mode
vim.keymap.set("i", "<C-w>", "<C-g>u<C-w>") -- Delete words in insert mode
vim.keymap.set("n", "<leader><leader>", "<C-^>")

-- Easier movement
vim.keymap.set("n", "q", "<C-w>c") -- Prevent usage of macros
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

-- Try and center these motions to the middle of the screen
vim.keymap.set({ "n", "x" }, "gw", "*Nzz", { desc = "Search word under cursor" })
vim.keymap.set("n", "n", "nzzzv", { silent = true })
vim.keymap.set("n", "N", "Nzzzv", { silent = true })
vim.keymap.set("n", "*", "*zz", { silent = true })
vim.keymap.set("n", "#", "#zz", { silent = true })
vim.keymap.set("n", "g*", "g*zz", { silent = true })
vim.keymap.set("n", "g#", "g#zz", { silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { silent = true })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
vim.keymap.set("n", "u", "uzz", { silent = true })
vim.keymap.set("n", "<C-r>", "<C-r>zz", { silent = true })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save file" })

vim.keymap.set("n", "<leader>xl", "<cmd>lopen<cr>", { desc = "Location List" })
vim.keymap.set("n", "<leader>xq", "<cmd>copen<cr>", { desc = "Quickfix List" })

vim.keymap.set("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
vim.keymap.set("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Faster close buffer and window
vim.keymap.set("n", "<leader>q", "<cmd>Bdelete<cr>")

-- which-key
local wk = require("which-key")
wk.add({
  {
    mode = { "v" },
    { "<leader>.", "<cmd>normal gcc<CR>", desc = "Comment" },
    { "<leader>t", group = "ToggleTerm" },
    { "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", desc = "Send Visual Selection" },
    { "<leader>tv", "<cmd>ToggleTermSendVisualLines<cr>", desc = "Send Visual Line" },
    { "<leader>y", '"+y', desc = "Yank System Clipboard" },
  },
  {
    { "<leader>.", "<cmd>normal gcc<CR>", desc = "Comment" },
    {
      "<leader>a",
      "<cmd>AerialToggle!<CR>",
      desc = "AerialToggle",
    },
    {
      "<leader>c",
      "<cmd>ToggleTerm<CR>",
      desc = "ToggleTerm",
    },
    { "<leader>g", group = "Git" },
    { "<leader>gB", "<cmd>lua require('telescope.builtin').git_branches()<cr>", desc = "Branches" },
    {
      "<leader>gb",
      "<cmd>lua require('telescope.builtin').git_bcommits()<cr>",
      desc = "Buffer Commits",
    },
    { "<leader>gc", "<cmd>lua require('telescope.builtin').git_commits()<cr>", desc = "Commits" },
    {
      "<leader>gd",
      "<cmd>lua require('telescope').extensions.git_diffs.diff_commits()<cr>",
      desc = "Diff history",
    },
    { "<leader>gs", "<cmd>lua require('telescope.builtin').git_status()<cr>", desc = "Status" },
    { "<leader>l", group = "LSP" },
    {
      "<leader>lD",
      "<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>",
      desc = "Buffer Diagnostics",
    },
    {
      "<leader>lI",
      "<cmd>lua require('telescope.builtin').lsp_incoming_calls()<cr>",
      desc = "Incoming calls",
    },
    {
      "<leader>lO",
      "<cmd>lua require('telescope.builtin').lsp_outgoing_calls()<cr>",
      desc = "Outgoing calls",
    },
    { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    {
      "<leader>lS",
      "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>",
      desc = "Workspace Symbols",
    },
    {
      "<leader>la",
      "<cmd>lua vim.lsp.buf.code_action()<cr>",
      desc = "Code Action",
    },
    {
      "<leader>lc",
      "<cmd>lua vim.lsp.codelens.run()<cr>",
      desc = "CodeLens Action",
    },
    {
      "<leader>ld",
      "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>",
      desc = "Definition",
    },
    { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format" },
    {
      "<leader>li",
      "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>",
      desc = "Implementation",
    },
    {
      "<leader>lj",
      "<cmd>lua vim.diagnostic.goto_next()<cr>",
      desc = "Next Diagnostic",
    },
    {
      "<leader>lk",
      "<cmd>lua vim.diagnostic.goto_prev()<cr>",
      desc = "Prev Diagnostic",
    },
    { "<leader>ll", "<cmd>LspInfo<cr>", desc = "Info" },
    { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
    {
      "<leader>lr",
      "<cmd>lua require('telescope.builtin').lsp_references()<cr>",
      desc = "References",
    },
    {
      "<leader>ls",
      "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>",
      desc = "Document Symbols",
    },
    {
      "<leader>lt",
      "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>",
      desc = "Type Definition",
    },
    {
      "<leader>lw",
      "<cmd>lua require('telescope.builtin').diagnostics()<cr>",
      desc = "Diagnostics",
    },
    {
      "<leader>m",
      "<cmd>Mason<cr>",
      desc = "Mason [LSP Manager]",
    },
    {
      "<leader>r",
      "<cmd>lua require('telescope.builtin').oldfiles()<CR>",
      desc = "Recent Files",
    },
    {
      "<leader>s",
      "<cmd>split<CR>",
      desc = "Split horizontal",
    },
    {
      "<leader>v",
      "<C-w>v<C-w>l",
      desc = "Split vertical",
    },
    { "<leader>w", "<cmd>w!<CR>", desc = "Save" },
    {
      "<leader>z",
      "<cmd>Lazy<CR>",
      desc = "Lazy [Plugin Manager]",
    },
  },
})

-------------------- AUTO COMMANDS -------------------------
local function augroup(name)
  return vim.api.nvim_create_augroup("My_" .. name, { clear = true })
end

-- highlight on yank
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

-- go to last loc when opening a buffer
vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup("last_loc"),
  callback = function(event)
    local exclude = { "gitcommit" }
    local buf = event.buf
    if vim.tbl_contains(exclude, vim.bo[buf].filetype) or vim.b[buf].lazyvim_last_loc then
      return
    end
    vim.b[buf].lazyvim_last_loc = true
    local mark = vim.api.nvim_buf_get_mark(buf, '"')
    local lcount = vim.api.nvim_buf_line_count(buf)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
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

-- Fix conceallevel for json files
vim.api.nvim_create_autocmd({ "FileType" }, {
  group = augroup("json_conceal"),
  pattern = { "json", "jsonc", "json5" },
  callback = function()
    vim.opt_local.conceallevel = 0
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
