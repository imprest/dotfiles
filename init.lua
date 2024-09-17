-- Based of https://github.com/LazyVim/LazyVim & https://astronvim.com
-------------------- HELPERS -------------------------------
vim.g["loaded_python_provider"] = 1
vim.g["python3_host_prog"] = "/usr/bin/python3"
vim.g.mapleader = ","
vim.g.maplocalleader = ";"
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
      icons = { keys = vim.g.have_nerd_font and {} },
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
    ft = { "javascript", "ts_ls", "css", "html", "postcss" },
    cmd = "ColorizerToggle",
    opts = { user_default_options = { tailwind = true } },
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    init = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
    opts = {
      transparent_background = true,
      no_italic = true,
    },
  },
  {
    "akinsho/bufferline.nvim",
    version = "*",
    dependencies = { "famiu/bufdelete.nvim", { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font } },
    after = "catppuccin",
    opts = {
      highlights = { fill = { bg = "" }, buffer_selected = { italic = false } },
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
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
      vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Keymaps" })
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>ft", builtin.builtin, { desc = "Select Telescope" })
      vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Find Word" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fd", builtin.diagnostics, { desc = "Diagnostics" })
      vim.keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent Files" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fC", builtin.commands, { desc = "Commands" })
      vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Commands History" })
      vim.keymap.set("n", "<leader>fs", builtin.search_history, { desc = "Search History" })

      vim.keymap.set("n", "<leader>f/", function()
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
          map("K", vim.lsp.buf.hover, "Hover Documentation")
          map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle Inlay Hints")
          end
          -- if client.name == "tsserver" then
          --   map("<leader>o", "<cmd>TypescriptOrganizeImports<CR>", "Organize Imports")
          --   map("<leader>R", "<cmd>TypescriptRenameFile<CR>", "Rename File")
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
        lexical = {
          -- cmd = { "/home/hvaria/.local/share/nvim/mason/packages/lexical/libexec/lexical/bin/start_lexical.sh" },
          filetypes = { "elixir", "eelixir", "heex" },
          root_dir = function(fname)
            return require("lspconfig").util.root_pattern("mix.exs", ".git")(fname) or vim.loop.os_homedir()
          end,
          settings = {},
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
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  {
    "hrsh7th/nvim-cmp",
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
      -- "kdheepak/cmp-latex-symbols",
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
          completeopt = "menu,menuone,noselect",
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
        }),
        -- sources = cmp.config.sources({
        sources = {
          { name = "nvim_lsp", priority = 1000 },
          { name = "nvim_lsp_signature_help", priority = 900 },
          { name = "luasnip", priority = 750 },
          { name = "buffer", priority = 500 },
          { name = "path", priority = 250 },
          -- { name = "latex_symbols", priority = 200 },
        },
        -- }),
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
          lualine_c = { "filename", "diff" },
          lualine_x = { "diagnostics", "encoding", "filetype" },
          lualine_y = { "location" },
          lualine_z = { "progress" },
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
    lazy = false,
    config = function()
      vim.g.vimtex_quickfix_mode = 0
      vim.g.vimtex_compiler_method = "tectonic"
      vim.g.vimtex_view_general_viewer = "evince"
      -- vim.g.vimtex_view_method = "evince"
      vim.g.vimtex_fold_enabled = true
    end,
  },
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
  rocks = { enabled = false },
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
vim.o.hlsearch = true
vim.o.backup = false
vim.o.breakindent = true
vim.o.conceallevel = 0 -- So that `` is visible in markdown files (default: 1)
vim.o.cursorline = false -- Highlight cursor line
vim.o.equalalways = false -- I don't like my windows changing all the time
vim.o.foldcolumn = "0" -- '0' is not bad
vim.o.foldlevel = 99
vim.o.foldlevelstart = 99
vim.o.foldenable = true
vim.o.foldmethod = "indent" -- expr
-- vim.o.foldexpr = "nvim_treesitter#foldexpr()"
vim.o.guicursor = "i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon1"
vim.o.grepformat = "%f:%l:%c:%m"
vim.o.grepprg = "rg --vimgrep"
vim.o.ignorecase = true -- Ignore case
vim.o.joinspaces = false -- No double spaces with join
vim.o.laststatus = 3 -- global statusline
vim.o.wrap = false -- Disable line wrap
vim.o.linebreak = true -- Companion to wrap, don't split words (default: false)
vim.o.autoindent = true -- Copy indent from current line when starting new one (default: true)
vim.o.list = true -- Show some invisible characters
vim.o.listchars = "tab:▸ ,extends:>,precedes:<"
vim.o.mouse = "a" -- Allow the mouse
vim.wo.number = true -- Show line numbers
vim.o.pumheight = 10 -- Maximum number of entries in a popup
vim.o.scrolljump = 4 -- min. lines to scroll
vim.o.scrolloff = 4 -- Lines of context
vim.o.sidescrolloff = 8 -- Columns of context
vim.o.shiftround = true -- Round indent
vim.o.showbreak = "↪  "
vim.o.showbreak = "↪  "
vim.o.showmatch = true
vim.o.showmode = false -- Don't show mode since we have a statusline
vim.wo.signcolumn = "yes:1" -- Show sign column
vim.o.smartcase = true -- Don't ignore case with capitals
vim.o.spelllang = "en_GB"
vim.o.shiftwidth = 2 -- Size of an indent
vim.o.tabstop = 2 -- Number of spaces tabs count for
vim.o.softtabstop = 2
vim.o.expandtab = true -- Use spaces instead of tabs
vim.o.splitbelow = true -- Put new windows below current
vim.o.splitright = true -- Put new windows right of current
vim.o.smartindent = true -- Make indenting smarter again (default: false)
vim.o.termguicolors = true -- True color support
vim.o.textwidth = width -- Maximum width of text
vim.o.winminwidth = 5 -- Minimum window width
vim.o.swapfile = false
vim.o.writebackup = false
vim.o.updatetime = 250 -- make updates faster and trigger CursorHold
vim.o.timeoutlen = 300 -- mapping timeout
vim.o.undofile = true
vim.o.undodir = "/home/hvaria/.nvim/undo"
vim.o.completeopt = "menuone,noselect" -- Completion options
vim.opt.shortmess:append("c") -- Don't give |ins-completion-menu| messages (default: does not include 'c')
vim.opt.iskeyword:append("-") -- Hyphenated words recognized by searches (default: does not include '-')
vim.o.formatoptions = "q1jl" -- Automatic formatting options
vim.opt.formatoptions:remove({ "c", "r", "o" }) -- Don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode. (default: 'croql')
vim.opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
vim.o.wildmode = "longest:full,full" -- Command-line completion mode

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
vim.keymap.set("n", "n", "nzzzv", { silent = true })
vim.keymap.set("n", "N", "Nzzzv", { silent = true })
vim.keymap.set("n", "*", "*zz", { silent = true })
vim.keymap.set("n", "#", "#zz", { silent = true })
vim.keymap.set("n", "g*", "g*zz", { silent = true })
vim.keymap.set("n", "g#", "g#zz", { silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { silent = true })
vim.keymap.set("n", "u", "uzz", { silent = true })
vim.keymap.set("n", "<C-r>", "<C-r>zz", { silent = true })

-- Add undo break-points
vim.keymap.set("i", ",", ",<c-g>u")
vim.keymap.set("i", ".", ".<c-g>u")
vim.keymap.set("i", ";", ";<c-g>u")

-- save file
vim.keymap.set({ "i", "v", "n", "s" }, "<C-s>", "<cmd>update<cr><esc>", { desc = "Save file" })

-- delete single character without copying into register
vim.keymap.set("n", "x", '"_x', { noremap = true, silent = true })

-- better indenting
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- Faster close buffer and window
vim.keymap.set("n", "Q", "<cmd>Bdelete<cr>")

-- which-key
local wk = require("which-key")
wk.add({
  {
    mode = { "v" },
    { "<leader>.", "<ESC><CMD>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<CR>", desc = "Comment" },
    { "<leader>t", group = "ToggleTerm" },
    { "<leader>ts", "<cmd>ToggleTermSendVisualSelection<cr>", desc = "Send Visual Selection" },
    { "<leader>tv", "<cmd>ToggleTermSendVisualLines<cr>", desc = "Send Visual Line" },
    { "<leader>y", '"+y', desc = "Yank System Clipboard" },
  },
  {
    { "<leader>.", "<cmd>lua require('Comment.api').toggle.linewise.current()<CR>", desc = "Comment" },
    { "<leader><leader>", "<C-^>", desc = "Last buffer" },
    { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "AerialToggle" },
    { "<leader>c", "<cmd>ToggleTerm<CR>", desc = "ToggleTerm" },
    { "<leader>g", group = "Git" },
    { "<leader>gB", "<cmd>lua require('telescope.builtin').git_branches()<cr>", desc = "Branches" },
    { "<leader>gb", "<cmd>lua require('telescope.builtin').git_bcommits()<cr>", desc = "Buffer Commits" },
    { "<leader>gc", "<cmd>lua require('telescope.builtin').git_commits()<cr>", desc = "Commits" },
    { "<leader>gd", "<cmd>lua require('telescope').extensions.git_diffs.diff_commits()<cr>", desc = "Diff history" },
    { "<leader>gs", "<cmd>lua require('telescope.builtin').git_status()<cr>", desc = "Status" },
    { "<leader>l", group = "LSP" },
    { "<leader>lD", "<cmd>lua require('telescope.builtin').diagnostics({bufnr=0})<cr>", desc = "Buffer Diagnostics" },
    { "<leader>lI", "<cmd>lua require('telescope.builtin').lsp_incoming_calls()<cr>", desc = "Incoming calls" },
    { "<leader>lO", "<cmd>lua require('telescope.builtin').lsp_outgoing_calls()<cr>", desc = "Outgoing calls" },
    { "<leader>lR", "<cmd>lua vim.lsp.buf.rename()<cr>", desc = "Rename" },
    { "<leader>lS", "<cmd>lua require('telescope.builtin').lsp_workspace_symbols()<cr>", desc = "Workspace Symbols" },
    { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>", desc = "Code Action" },
    { "<leader>lc", "<cmd>lua vim.lsp.codelens.run()<cr>", desc = "CodeLens Action" },
    { "<leader>ld", "<cmd>lua require('telescope.builtin').lsp_definitions()<cr>", desc = "Definition" },
    { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>", desc = "Format" },
    { "<leader>li", "<cmd>lua require('telescope.builtin').lsp_implementations()<cr>", desc = "Implementation" },
    { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>", desc = "Next Diagnostic" },
    { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>", desc = "Prev Diagnostic" },
    { "<leader>ll", "<cmd>LspInfo<cr>", desc = "Info" },
    { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>", desc = "Quickfix" },
    { "<leader>lr", "<cmd>lua require('telescope.builtin').lsp_references()<cr>", desc = "References" },
    { "<leader>ls", "<cmd>lua require('telescope.builtin').lsp_document_symbols()<cr>", desc = "Document Symbols" },
    { "<leader>lt", "<cmd>lua require('telescope.builtin').lsp_type_definitions()<cr>", desc = "Type Definition" },
    { "<leader>lw", "<cmd>lua require('telescope.builtin').diagnostics()<cr>", desc = "Diagnostics" },
    { "<leader>m", "<cmd>Mason<cr>", desc = "Mason [LSP Manager]" },
    { "<leader>r", "<cmd>lua require('telescope.builtin').oldfiles()<CR>", desc = "Recent Files" },
    { "<leader>s", "<cmd>split<CR>", desc = "Split horizontal" },
    { "<leader>t", "<cmd>ToggleTermSendCurrentLine<cr>", desc = "Send Current Line to Term" },
    { "<leader>v", "<C-w>v<C-w>l", desc = "Split vertical" },
    { "<leader>w", "<cmd>w!<CR>", desc = "Save" },
    { "<leader>z", "<cmd>Lazy<CR>", desc = "Lazy [Plugin Manager]" },
  },
})

-------------------- AUTO COMMANDS -------------------------
local function augroup(name)
  return vim.api.nvim_create_augroup("My_" .. name, { clear = true })
end

-- Prevent LSP from overwriting treesitter color settings
-- https://github.com/NvChad/NvChad/issues/1907
vim.highlight.priorities.semantic_tokens = 95 -- Or any number lower than 100, treesitter's priority level

-- Appearance of diagnostics
vim.diagnostic.config({
  virtual_text = {
    prefix = "●",
    -- Add a custom format function to show error codes
    format = function(diagnostic)
      local code = diagnostic.code and string.format("[%s]", diagnostic.code) or ""
      return string.format("%s %s", code, diagnostic.message)
    end,
  },
  underline = false,
  update_in_insert = true,
  float = {
    source = "always", -- Or "if_many"
  },
  -- Make diagnostic background transparent
  on_ready = function()
    vim.cmd("highlight DiagnosticVirtualText guibg=NONE")
  end,
})

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
