-- Based of http://github.com/LazyVim/LazyVim & https://astronvim.com
-------------------- HELPERS -------------------------------
vim.g["loaded_python_provider"] = 1
vim.g["python3_host_prog"] = "/usr/bin/python3"
vim.g.mapleader = ","
vim.g.maplocalleader = ","
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
  -- "NMAC427/guess-indent.nvim", -- Detect tabstop and shiftwidth automatically
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
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    init = function()
      vim.cmd.colorscheme("tokyonight-moon")
    end,
  },
  {
    "romgrk/barbar.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    init = function()
      vim.g.barbar_auto_setup = false
    end,
    opts = {
      sidebar_filetypes = {
        ["neo-tree"] = { event = "BufWipeout" },
      },
    },
    version = "^1.0.0", -- optional: only update when a new 1.x version is released
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    -- stylua: ignore
    keys = {
      { "<leader>ps", function() require("persistence").load() end,                desc = "Restore Session" },
      { "<leader>pS", function() require("persistence").select() end,              desc = "Select Session" },
      { "<leader>pl", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>pd", function() require("persistence").stop() end,                desc = "Don't Save Current Session" },
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    init = function()
      vim.g.snacks_animate = false
    end,
    opts = {
      bigfile = { enabled = true },
      dashboard = { enabled = true },
      explorer = { enabled = false },
      image = { enabled = true },
      indent = { enabled = false },
      input = { enabled = true, win = { relative = "cursor" } },
      picker = { enabled = true, layout = { preset = "ivy" } },
      notifier = { enabled = false },
      quickfile = { enabled = true },
      terminal = { win = { style = "terminal", height = 14 } },
      scope = { enabled = true }, -- select and jump to scopes e.g. dii vai vii [i ]i
      scroll = { enabled = true },
      statuscolumn = { enabled = true },
      words = { enabled = false }, -- highlight variables based on LSP references
    },
    -- stylua: ignore
    keys = {
      -- Top Pickers & Explorer
      { "<C-p>",      function() require('snacks').picker.git_files() end,                                   desc = "Smart Find Files" },
      { "<leader>r",  function() require('snacks').picker.recent() end,                                  desc = "Recent" },
      { "B",          "<Cmd>BufferPick<CR>"                            ,                                 desc = "Buffers" },
      { "<leader>/",  function() require('snacks').picker.grep() end,                                    desc = "Grep" },
      { "<leader>:",  function() require('snacks').picker.command_history() end,                         desc = "Command History" },
      -- { "<leader>e", function() require("snacks").explorer() end,               desc = "Explorer Toggle" },
      -- find
      { "<leader>fb", function() require('snacks').picker.buffers() end,                                 desc = "Buffers" },
      { "<leader>fc", function() require('snacks').picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
      { "<leader>ff", function() require('snacks').picker.smart() end,                                   desc = "Find Files" },
      { "<leader>fg", function() require('snacks').picker.git_files() end,                               desc = "Find Git Files" },
      { "<leader>fp", function() require('snacks').picker.projects() end,                                desc = "Projects" },
      { "<leader>fr", function() require('snacks').picker.recent() end,                                  desc = "Recent" },
      -- LSP
      { "gd",         function() require('snacks').picker.lsp_definitions() end,                         desc = "Goto Definition" },
      { "gD",         function() require('snacks').picker.lsp_declarations() end,                        desc = "Goto Declaration" },
      { "gI",         function() require('snacks').picker.lsp_implementations() end,                     desc = "Goto Implementation" },
      { "gt",         function() require('snacks').picker.lsp_type_definitions() end,                    desc = "Goto Type Defini[t]ion" },
      { "<leader>ls", function() require('snacks').picker.lsp_symbols() end,                             desc = "LSP Symbols" },
      { "<leader>lS", function() require('snacks').picker.lsp_workspace_symbols() end,                   desc = "LSP Workspace Symbols" },
      { "<leader>la", "<cmd>lua vim.lsp.buf.code_action()<cr>",                                          desc = "Code Action" },
      { "<leader>lc", "<cmd>lua vim.lsp.codelens.run()<cr>",                                             desc = "CodeLens Action" },
      { "<leader>lf", "<cmd>lua vim.lsp.buf.format()<cr>",                                               desc = "Format" },
      { "<leader>lj", "<cmd>lua vim.diagnostic.goto_next()<cr>",                                         desc = "Next Diagnostic" },
      { "<leader>lk", "<cmd>lua vim.diagnostic.goto_prev()<cr>",                                         desc = "Prev Diagnostic" },
      { "<leader>ll", "<cmd>LspInfo<cr>",                                                                desc = "Info" },
      { "<leader>lq", "<cmd>lua vim.diagnostic.setloclist()<cr>",                                        desc = "Quickfix" },
      -- git
      { "<leader>gb", function() require('snacks').picker.git_branches() end,                            desc = "Git Branches" },
      { "<leader>gl", function() require('snacks').picker.git_log() end,                                 desc = "Git Log" },
      { "<leader>gL", function() require('snacks').picker.git_log_line() end,                            desc = "Git Log Line" },
      { "<leader>gs", function() require('snacks').picker.git_status() end,                              desc = "Git Status" },
      { "<leader>gS", function() require('snacks').picker.git_stash() end,                               desc = "Git Stash" },
      { "<leader>gd", function() require('snacks').picker.git_diff() end,                                desc = "Git Diff (Hunks)" },
      { "<leader>gf", function() require('snacks').picker.git_log_file() end,                            desc = "Git Log File" },
      { "<leader>gB", function() require('snacks').gitbrowse() end,                                      desc = "Git Browse" },
      { "<leader>gg", function() require("snacks").lazygit() end,                                        desc = "Lazygit", },
      { "<leader>go", function() require("snacks").lazygit.log() end,                                    desc = "Lazygit Log", },
      -- Grep
      { "<leader>sB", function() require('snacks').picker.grep_buffers() end,                            desc = "Grep Open Buffers" },
      { "<leader>sg", function() require('snacks').picker.grep() end,                                    desc = "Grep" },
      { "<leader>sw", function() require('snacks').picker.grep_word() end,                               desc = "Visual selection or word", mode = { "n", "x" } },
      -- search
      { '<leader>s"', function() require('snacks').picker.registers() end,                               desc = "Registers" },
      { '<leader>s/', function() require('snacks').picker.search_history() end,                          desc = "Search History" },
      { "<leader>sa", function() require('snacks').picker.autocmds() end,                                desc = "Autocmds" },
      { "<leader>sb", function() require('snacks').picker.lines() end,                                   desc = "Buffer Lines" },
      { "<leader>sc", function() require('snacks').picker.command_history() end,                         desc = "Command History" },
      { "<leader>sC", function() require('snacks').picker.commands() end,                                desc = "Commands" },
      { "<leader>sd", function() require('snacks').picker.diagnostics() end,                             desc = "Diagnostics" },
      { "<leader>sD", function() require('snacks').picker.diagnostics_buffer() end,                      desc = "Buffer Diagnostics" },
      { "<leader>sh", function() require('snacks').picker.help() end,                                    desc = "Help Pages" },
      { "<leader>sH", function() require('snacks').picker.highlights() end,                              desc = "Highlights" },
      { "<leader>si", function() require('snacks').picker.icons() end,                                   desc = "Icons" },
      { "<leader>sj", function() require('snacks').picker.jumps() end,                                   desc = "Jumps" },
      { "<leader>sk", function() require('snacks').picker.keymaps() end,                                 desc = "Keymaps" },
      { "<leader>sl", function() require('snacks').picker.loclist() end,                                 desc = "Location List" },
      { "<leader>sm", function() require('snacks').picker.marks() end,                                   desc = "Marks" },
      { "<leader>sM", function() require('snacks').picker.man() end,                                     desc = "Man Pages" },
      { "<leader>sp", function() require('snacks').picker.lazy() end,                                    desc = "Search for Plugin Spec" },
      { "<leader>sq", function() require('snacks').picker.qflist() end,                                  desc = "Quickfix List" },
      { "<leader>sR", function() require('snacks').picker.resume() end,                                  desc = "Resume" },
      { "<leader>su", function() require('snacks').picker.undo() end,                                    desc = "Undo History" },
      -- others
      { "<leader>q",  "<cmd>lua Snacks.bufdelete()<cr>",                                                 desc = "Buffer Delete" },
      { "<leader>lR", function() require('snacks').rename.rename_file() end,                             desc = "Rename File" },
      { "<leader>cR", function() require('snacks').rename.rename_file() end,                             desc = "Rename File" },
      { "<leader>c",  "<cmd>lua Snacks.terminal()<CR>",                                                  desc = "ToggleTerm" },
      { "<leader>o",  "<cmd>lua Snacks.terminal.open()<CR>",                                             desc = "Open Term" },
      { "<leader>uC", function() require('snacks').picker.colorschemes() end,                            desc = "Colorschemes" },
    },
  },
  {
    "sphamba/smear-cursor.nvim",
    opts = { smear_between_neighbor_lines = false, smear_insert_mode = false },
  },
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    event = "VeryLazy",
    config = function()
      require("tiny-inline-diagnostic").setup({ preset = "classic" })
    end,
  },
  -- LSP
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    dependencies = {
      { "saghen/blink.cmp" },
      { "b0o/schemastore.nvim", version = false },
      { "mason-org/mason.nvim", opts = { ui = { border = "rounded" } } },
      {
        "mason-org/mason-lspconfig.nvim",
        opts = {
          ensure_installed = {
            "lua_ls",
            "cssls",
            "html",
            "jsonls",
            "ts_ls",
            "tailwindcss",
            "svelte",
            "expert",
            "tinymist",
          },
        },
      },
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      { "j-hui/fidget.nvim", opts = {} },
    },
    config = function()
      -- ref: LazyVim & https://github.com/wookayin/dotfiles/blob/master/nvim/lua/config/lsp.lua
      -- lsp_diagnostics
      local icons = {
        [vim.diagnostic.severity.ERROR] = "✘",
        [vim.diagnostic.severity.WARN] = "",
        [vim.diagnostic.severity.INFO] = "",
        [vim.diagnostic.severity.HINT] = "󰌶",
      }
      vim.diagnostic.config({ virtual_text = false, signs = { text = icons } })

      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("kickstart-lsp-attach", { clear = true }),
        callback = function(event)
          local map = function(keys, func, desc, mode)
            mode = mode or "n"
            vim.keymap.set(mode, keys, func, { buffer = event.buf, desc = "LSP: " .. desc })
          end

          map("K", vim.lsp.buf.hover, "Hover Documentation")

          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method("textDocument/inlayHint") then
            map("<leader>lh", function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = event.buf }))
            end, "Toggle In[l]ay [H]ints")
          end
          if client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, event.buf, { autotrigger = true })
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
      --  When you add blink.cmp, luasnip, etc. Neovim now has *more* capabilities.
      --  So, we create new capabilities with blink.cmp, and then broadcast that to the servers.
      local capabilities = require("blink.cmp").get_lsp_capabilities()

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
        tinymist = {},
        expert = {},
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

      -- You can add other tools here that you want Mason to install
      -- for you, so that they are available from within Neovim.
      local ensure_installed = vim.tbl_keys(servers or {})
      -- vim.list_extend(ensure_installed, { "stylua" }) -- Used to format Lua code

      require("mason-lspconfig").setup({
        ensure_installed = ensure_installed, -- explicitly set to an empty table (Kickstart populates installs via mason-tool-installer)
        automatic_installation = false,
        handlers = {
          function(server_name)
            local server = servers[server_name] or {}
            -- This handles overriding only values explicitly passed
            -- by the server configuration above. Useful when disabling
            -- certain features of an LSP (for example, turning off formatting for tsserver)
            server.capabilities = vim.tbl_deep_extend("force", {}, capabilities, server.capabilities or {})
            vim.lsp.config(server_name, server)
            -- require("lspconfig")[server_name].setup(server)
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
    -- stylua: ignore
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>",              desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xs", "<cmd>Trouble symbols toggle<cr>",                  desc = "Symbols (Trouble)" },
      { "<leader>xS", "<cmd>Trouble lsp toggle<cr>",                      desc = "LSP references/definitions/... (Trouble)", },
      { "<leader>xL", "<cmd>Trouble loclist toggle<cr>",                  desc = "Location List (Trouble)" },
      { "<leader>xQ", "<cmd>Trouble qflist toggle<cr>",                   desc = "Quickfix List (Trouble)" },
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
    cmd = { "TodoTrouble" },
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    opts = { signs = false },
    -- stylua: ignore
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end,                                              desc = "Next Todo Comment" },
      { "[t",         function() require("todo-comments").jump_prev() end,                                              desc = "Previous Todo Comment" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>",                                                                   desc = "Todo (Trouble)" },
      { "<leader>xT", "<cmd>Trouble todo toggle filter = {tag = {TODO,FIX,FIXME}}<cr>",                                 desc = "Todo/Fix/Fixme (Trouble)" },
      { "<leader>st", function() require('snacks').picker.todo_comments() end,                                          desc = "Todo" },
      { "<leader>sT", function() require('snacks').picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end, desc = "Todo/Fix/Fixme" },
    },
  },

  -- auto completion
  { "windwp/nvim-autopairs", event = "InsertEnter", config = true },
  {
    "windwp/nvim-ts-autotag",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      require("nvim-ts-autotag").setup()
    end,
  },
  {
    "saghen/blink.cmp",
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*", -- use a release tag to download pre-built binaries
    dependencies = {
      "L3MON4D3/LuaSnip",
      version = "2.*",
      build = (function()
        if vim.fn.has("win32") == 1 or vim.fn.executable("make") == 0 then
          return
        end
        return "make install_jsregexp"
      end)(),
      dependencies = {
        {
          "rafamadriz/friendly-snippets",
          config = function()
            require("luasnip.loaders.from_vscode").lazy_load()
          end,
        },
      },
    },
    opts = {
      -- 'default' for mappings similar to built-in completion
      -- 'super-tab' for mappings similar to vscode (tab to accept, arrow keys to navigate)
      -- 'enter' for mappings similar to 'super-tab' but with 'enter' to accept
      -- See the full "keymap" documentation for information on defining your own keymap.
      keymap = { preset = "super-tab" },

      -- don't show in cmdline and search mode
      completion = {
        menu = {
          border = "single",

          -- nvim-cmp style menu
          draw = {
            columns = {
              { "label", "label_description", gap = 1 },
              { "kind_icon", gap = 1, "kind" },
            },
          },
        },
        -- Show documentation with <c-space>
        documentation = { window = { border = "single" }, auto_show = true, auto_show_delay_ms = 200 },
        -- Display a preview of the selected item on the current line
        ghost_text = { enabled = true },
      },

      -- Default list of enabled providers defined so that you can extend it
      -- elsewhere in your config, without redefining it, due to `opts_extend`
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
        per_filetype = { sql = { "snippets", "dadbod", "buffer" } },
        providers = { dadbod = { name = "Dadbod", module = "vim_dadbod_completion.blink" } },
      },

      snippets = { preset = "luasnip" },

      fuzzy = { implementation = "prefer_rust_with_warning" },

      -- Shows a signature help window while you type arguments for a function
      signature = { window = { border = "single" }, enabled = true },
    },
  },
  -- search/replace in multiple files
  -- {
  --   "MagicDuck/grug-far.nvim",
  --   opts = { headerMaxWidth = 80 },
  --   cmd = "GrugFar",
  --   keys = {
  --     {
  --       "<leader>S",
  --       function()
  --         local grug = require("grug-far")
  --         local ext = vim.bo.buftype == "" and vim.fn.expand("%:e")
  --         grug.open({
  --           transient = true,
  --           prefills = {
  --             filesFilter = ext and ext ~= "" and "*." .. ext or nil,
  --           },
  --         })
  --       end,
  --       mode = { "n", "v" },
  --       desc = "Search and Replace",
  --     },
  --   },
  -- },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = {
          icons_enabled = true,
          theme = "tokyonight",
          globalstatus = true,
          section_separators = "",
          component_separators = "",
          disabled_filetypes = { "Outline", "dashboard" },
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
          lualine_b = {}, -- "branch" },
          lualine_c = { "filesize", { "filename", path = 1 }, "diff" },
          lualine_x = { "diagnostics", "filetype" }, -- "encoding", "filetype", "filesize" },
          lualine_y = {
            { "location", padding = { left = 1, right = 0 } },
            { "progress", separator = " ", padding = { left = 1, right = 1 } },
          },
          lualine_z = {
            -- function()
            --   return " " .. os.date("%I:%M%p %d/%m")
            -- end,
          },
        },

        tabline = {},
        extensions = { "quickfix", "neo-tree", "fzf", "trouble", "mason", "aerial", "lazy" },
      })
    end,
  },

  -- file explorer
  {
    "nvim-neo-tree/neo-tree.nvim",
    lazy = false,
    version = "*",
    dependencies = { "MunifTanjim/nui.nvim", "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<F2>", "<cmd>Neotree toggle<CR>", desc = "Toggle NeoTree" },
    },
    deactivate = function()
      vim.cmd([[Neotree close]])
    end,
    init = function() end,
    opts = {
      close_if_last_window = true,
      enable_git_status = false,
      filesystem = {
        bind_to_cwd = false,
        follow_current_file = { enabled = true },
      },
      window = {
        width = 26,
        mappings = {
          ["<space>"] = "none",
        },
      },
      default_component_configs = {
        indent = {
          with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
          expander_highlight = "NeoTreeExpander",
        },
      },
      event_handlers = {
        {
          event = "neo_tree_buffer_enter",
          handler = function()
            vim.cmd([[ highlight TabLineFill guibg=#282c34 ]])
          end,
        },
      },
    },
  },
  -- Code skimming or outline for quick navigation
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialPrev", "AerialNext" },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    },
    keys = {
      { "<leader>a", "<cmd>AerialToggle!<CR>", desc = "AerialToggle" },
    },
  },
  { "folke/ts-comments.nvim", opts = {}, event = "VeryLazy" },
  {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    event = { "BufReadPost", "BufNewFile", "BufWritePre", "VeryLazy" },
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
        -- "tsx",
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
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    version = "1.*",
    opts = {}, -- lazy.nvim will implicitly calls `setup {}`
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = { current_line_blame = false },
    keys = {
      { "<leader>gk", "<cmd>Gitsigns prev_hunk<CR>", desc = "Prev Hunk" },
      { "<leader>gj", "<cmd>Gitsigns next_hunk<CR>", desc = "Next Hunk" },
      { "<leader>ghp", "<cmd>Gitsigns preview_hunk_inline<CR>", desc = "Preview Inline" },
      { "<leader>ghr", "<cmd>Gitsigns reset_hunk<CR>", desc = "Reset Hunk" },
    },
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    ft = { "sql", "plsql", "elixir", "eelixir" },
    lazy = true,
    dependencies = { "tpope/vim-dadbod", lazy = true },
    config = function()
      vim.g["db"] = "postgresql://postgres:@localhost/subledger_dev"
      vim.keymap.set("x", "<Plug>(DBExe)", "db#op_exec()", { expr = true })
      vim.keymap.set("n", "<Plug>(DBExe)", "db#op_exec()", { expr = true })
      vim.keymap.set("n", "<Plug>(DBExeLine)", "db#op_exec() . '_'", { expr = true })
      vim.keymap.set("x", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("n", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("o", "<leader>d", "<Plug>(DBExe)")
      vim.keymap.set("n", "<leader>dd", "<Plug>(DBExeLine)")
    end,
  },
  {
    "nvim-mini/mini.surround", -- sr({ sd' <select text>sa'
    keys = { "sr", "sh", "sf", "sF", "sd", "sn", { "sa", mode = "v" } }, -- Only load on these keystrokes
    version = false,
    config = function()
      require("mini.surround").setup()
    end,
  },
  {
    "nvim-mini/mini.align",
    keys = { { "ga", mode = "v" }, { "gA", mode = "v" } },
    version = false,
    config = function()
      require("mini.align").setup()
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
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
opt.hlsearch = true
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
opt.guicursor = "i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkon1,t:ver20"
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
opt.sidescrolloff = 1 -- Columns of context
opt.shiftround = true -- Round indent
opt.showbreak = "↪  "
opt.showbreak = "↪  "
opt.showmatch = true
opt.showmode = false -- Don't show mode since we have a statusline
vim.wo.signcolumn = "yes" -- Show sign column
opt.smartcase = true -- Don't ignore case with capitals
opt.inccommand = "split" -- Preview substitutions live, as you type!
opt.spelllang = { "en" }
opt.tabstop = 2 -- Number of spaces tabs count for
opt.shiftwidth = 2 -- Size of an indent
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
opt.undofile = true
opt.undolevels = 10000
opt.undodir = "/home/hvaria/.nvim/undo"
opt.completeopt = "menu,menuone,noselect" -- Completion options
opt.shiftwidth = 2 -- Size of an indent
opt.shortmess:append({ W = true, I = true, c = true, C = true })
opt.iskeyword:append("-") -- Hyphenated words recognized by searches (default: does not include '-')
opt.runtimepath:remove("/usr/share/vim/vimfiles") -- Separate Vim plugins from Neovim in case Vim still in use (default: includes this path if Vim is installed)
opt.wildmode = "longest:full,full" -- Command-line completion mode
opt.confirm = true -- operation that can fail to due unsave changes; instead raise a dialog asking if you wish to save the current file(s)
opt.winborder = "rounded"

-------------------- MAPPINGS ------------------------------
-- Personal common tasks
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

-- -- buffers
vim.keymap.set("n", "<Right>", "<cmd>BufferNext<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "<Left>", "<cmd>BufferPrevious<cr>", { desc = "Next buffer" })
vim.keymap.set("n", "[b", "<cmd>BufferMoveNext<cr>", { desc = "Prev buffer" })
vim.keymap.set("n", "]b", "<cmd>BufferMovePrevious<cr>", { desc = "Next buffer" })

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

-- Try and center these motions to the middle of the screen
vim.keymap.set("n", "<C-d>", "<C-d>zz", { silent = true })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { silent = true })
vim.keymap.set("n", "<C-o>", "<C-o>zz", { silent = true })
vim.keymap.set("n", "<C-i>", "<C-i>zz", { silent = true })

-- which-key
local wk = require("which-key")
wk.add({
  {
    mode = { "v" },
    { "<leader>.", "<cmd>normal gcc<CR>", desc = "Comment" },
    { "<leader>y", '"+y', desc = "Yank System Clipboard" },
  },
  {
    { "<leader>.", "<cmd>normal gcc<CR>", desc = "Comment" },
    { "<leader>h", "<cmd>split<CR>", desc = "Split horizontal" },
    { "<leader>v", "<C-w>v<C-w>l", desc = "Split vertical" },
    { "<leader>f", group = "Find" },
    { "<leader>g", group = "Git" },
    { "<leader>l", group = "LSP" },
    { "<leader>m", "<cmd>Mason<cr>", desc = "Mason [LSP Manager]" },
    { "<leader>p", group = "Persistence" },
    { "<leader>s", group = "Search" },
    { "<leader>t", group = "Test" },
    { "<leader>u", group = "UI Options" },
    { "<leader>x", group = "Lists" },
    { "<leader>z", "<cmd>Lazy<CR>", desc = "Lazy [Plugin Manager]" },
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
    vim.hl.on_yank()
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

-- Built-in omnifunc for sql
vim.api.nvim_create_autocmd("FileType", {
  group = augroup("sql_group"),
  pattern = "sql,elixir,eelixir",
  callback = function()
    vim.cmd([[setlocal omnifunc=vim_dadbod_completion#omni]])
    -- Remember to patch/add 'elixir' to s:filetypes in
    -- .local/share/nvim/lazy/vim-dadbod-completion/autoload/vim_dadbod_completion.vim
    vim.cmd([[call vim_dadbod_completion#fetch(str2nr(expand('<abuf>')))]])
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
