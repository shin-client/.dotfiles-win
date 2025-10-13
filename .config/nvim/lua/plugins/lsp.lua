return {
  "neovim/nvim-lspconfig",
  dependencies = {
    -- Mason - Quản lý LSP servers, formatters, linters
    "williamboman/mason.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim", -- Tự động cài đặt tools

    -- Autocompletion
    "hrsh7th/nvim-cmp",
    "hrsh7th/cmp-buffer",
    "hrsh7th/cmp-path",
    "saadparwaiz1/cmp_luasnip",
    "hrsh7th/cmp-nvim-lsp",
    "hrsh7th/cmp-nvim-lua",

    -- Snippets
    "L3MON4D3/LuaSnip",
    "rafamadriz/friendly-snippets",

    -- Formatter
    "stevearc/conform.nvim",
  },
  config = function()
    -- ============================================================
    -- 1. Mason - Quản lý LSP servers và tools (CHỈ ĐỂ CÀI ĐẶT)
    -- ============================================================
    require("mason").setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- ============================================================
    -- 2. Mason Tool Installer - Tự động cài LSP servers & tools
    -- ============================================================
    require("mason-tool-installer").setup({
      ensure_installed = {
        -- LSP Servers
        "lua-language-server",
        "typescript-language-server",
        "eslint-lsp",
        "css-lsp",
        "html-lsp",
        "json-lsp",
        "intelephense",
        "pyright",
        -- "nil",
        "tailwindcss-language-server",

        -- Formatters
        "prettier",
        "stylua",
        "black",
        "isort",
        "php-cs-fixer",
        -- "nixpkgs-fmt",

        -- Linters
        "eslint_d",
        "phpstan",
        "pylint",
      },
      auto_update = false,
      run_on_start = true, -- Tự động cài khi khởi động
    })

    -- ============================================================
    -- 3. Cấu hình chung cho LSP (API mới)
    -- ============================================================
    vim.lsp.config("*", {
      root_markers = { ".git" },
    })

    -- ============================================================
    -- 4. Cấu hình Diagnostics
    -- ============================================================
    vim.diagnostic.config({
      virtual_text = true,
      severity_sort = true,
      float = {
        style = "minimal",
        border = "rounded",
        source = "if_many",
        header = "",
        prefix = "",
      },
      signs = {
        text = {
          [vim.diagnostic.severity.ERROR] = "✘",
          [vim.diagnostic.severity.WARN] = "▲",
          [vim.diagnostic.severity.HINT] = "⚑",
          [vim.diagnostic.severity.INFO] = "»",
        },
      },
    })

    -- ============================================================
    -- 5. Cấu hình Floating Windows
    -- ============================================================
    local orig = vim.lsp.util.open_floating_preview
    ---@diagnostic disable-next-line: duplicate-set-field
    function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
      opts = opts or {}
      opts.border = opts.border or "rounded"
      opts.max_width = opts.max_width or 80
      opts.max_height = opts.max_height or 24
      opts.wrap = opts.wrap ~= false
      return orig(contents, syntax, opts, ...)
    end

    -- ============================================================
    -- 6. Capabilities cho LSP
    -- ============================================================
    local caps = require("cmp_nvim_lsp").default_capabilities()

    -- ============================================================
    -- 7. LspAttach - Keymaps & Auto-format (API mới)
    -- ============================================================
    local excluded_filetypes = { php = true }

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("my-lsp-attach", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client then
          return
        end

        local buf = args.buf
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { buffer = buf, silent = true, desc = desc })
        end

        -- Keymaps
        map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
        map("n", "gd", vim.lsp.buf.definition, "LSP: Go to Definition")
        map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to Declaration")
        map("n", "gi", vim.lsp.buf.implementation, "LSP: Go to Implementation")
        map("n", "go", vim.lsp.buf.type_definition, "LSP: Go to Type Definition")
        map("n", "gr", vim.lsp.buf.references, "LSP: References")
        map("n", "gs", vim.lsp.buf.signature_help, "LSP: Signature Help")
        map("n", "gl", vim.diagnostic.open_float, "LSP: Show Diagnostics")
        map("n", "<F2>", vim.lsp.buf.rename, "LSP: Rename")
        map("n", "<F4>", vim.lsp.buf.code_action, "LSP: Code Action")
        map("n", "[d", function()
          vim.diagnostic.jump({ count = -1, float = true, wrap = true })
        end, "LSP: Previous Diagnostic")
        map("n", "]d", function()
          vim.diagnostic.jump({ count = 1, float = true })
        end, "LSP: Next Diagnostic")

        -- Auto-format on save (chỉ cho LSP không có conform formatter)
        if
            not client:supports_method("textDocument/willSaveWaitUntil")
            and client:supports_method("textDocument/formatting")
            and not excluded_filetypes[vim.bo[buf].filetype]
        then
          vim.api.nvim_create_autocmd("BufWritePre", {
            group = vim.api.nvim_create_augroup("my-lsp-format", { clear = false }),
            buffer = buf,
            callback = function()
              vim.lsp.buf.format({
                bufnr = buf,
                name = client.name,
                timeout_ms = 1000,
                formatting_options = { tabSize = 2, insertSpaces = true },
              })
            end,
          })
        end
      end,
    })

    -- ============================================================
    -- 8. Conform.nvim - Auto-format với external formatters
    -- ============================================================
    require("conform").setup({
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettier" },
        typescript = { "prettier" },
        javascriptreact = { "prettier" },
        typescriptreact = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        html = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        php = { "php_cs_fixer" },
        nix = { "nixpkgs_fmt" },
      },
      format_on_save = {
        timeout_ms = 1000,
        lsp_fallback = true,
      },
    })

    -- Keymap để format thủ công
    vim.keymap.set({ "n", "v" }, "<F3>", function()
      require("conform").format({ async = true, lsp_fallback = true })
    end, { desc = "Format code" })

    -- ============================================================
    -- 9. Cấu hình Language Servers (SỬ DỤNG API MỚI vim.lsp.config)
    -- ============================================================

    -- Lua Language Server
    vim.lsp.config.lua_ls = {
      cmd = { "lua-language-server" },
      filetypes = { "lua" },
      root_markers = { { ".luarc.json", ".luarc.jsonc" }, ".git" },
      capabilities = caps,
      settings = {
        Lua = {
          runtime = { version = "LuaJIT" },
          diagnostics = { globals = { "vim" } },
          workspace = {
            checkThirdParty = false,
            library = vim.api.nvim_get_runtime_file("", true),
          },
          telemetry = { enable = false },
          format = {
            enable = true,
            defaultConfig = {
              indent_style = "space",
              indent_size = "2",
            },
          },
        },
      },
    }

    -- TypeScript/JavaScript
    vim.lsp.config.ts_ls = {
      cmd = { "typescript-language-server", "--stdio" },
      filetypes = {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      },
      root_markers = { "package.json", "tsconfig.json", "jsconfig.json", ".git" },
      capabilities = caps,
      settings = {
        completions = {
          completeFunctionCalls = true,
        },
      },
    }

    -- ESLint
    vim.lsp.config.eslint = {
      cmd = { "vscode-eslint-language-server", "--stdio" },
      filetypes = {
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
        "astro",
      },
      root_markers = { ".eslintrc.js", ".eslintrc.json", ".eslintrc.cjs", "package.json", ".git" },
      capabilities = caps,
      on_attach = function(_, bufnr)
        -- Auto-fix on save
        vim.api.nvim_create_autocmd("BufWritePre", {
          buffer = bufnr,
          callback = function()
            vim.cmd("EslintFixAll")
          end,
        })
      end,
    }

    -- CSS Language Server
    vim.lsp.config.cssls = {
      cmd = { "vscode-css-language-server", "--stdio" },
      filetypes = { "css", "scss", "less" },
      root_markers = { "package.json", ".git" },
      capabilities = caps,
      settings = {
        css = { validate = true },
        scss = { validate = true },
        less = { validate = true },
      },
    }

    -- HTML Language Server
    vim.lsp.config.html = {
      cmd = { "vscode-html-language-server", "--stdio" },
      filetypes = { "html", "templ" },
      root_markers = { "package.json", ".git" },
      capabilities = caps,
    }

    -- JSON Language Server
    vim.lsp.config.jsonls = {
      cmd = { "vscode-json-language-server", "--stdio" },
      filetypes = { "json", "jsonc" },
      root_markers = { ".git" },
      capabilities = caps,
    }

    -- PHP (Intelephense)
    vim.lsp.config.intelephense = {
      cmd = { "intelephense", "--stdio" },
      filetypes = { "php" },
      root_markers = { "composer.json", ".git" },
      capabilities = caps,
      settings = {
        intelephense = {
          files = {
            maxSize = 5000000,
          },
        },
      },
    }

    -- Python (Pyright)
    vim.lsp.config.pyright = {
      cmd = { "pyright-langserver", "--stdio" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
      capabilities = caps,
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
          },
        },
      },
    }

    -- Nix Language Server
    vim.lsp.config.nil_ls = {
      cmd = { "nil" },
      filetypes = { "nix" },
      root_markers = { "flake.nix", "default.nix", ".git" },
      capabilities = caps,
      settings = {
        ["nil"] = {
          formatting = {
            command = { "nixpkgs-fmt" },
          },
        },
      },
    }

    -- Tailwind CSS
    vim.lsp.config.tailwindcss = {
      cmd = { "tailwindcss-language-server", "--stdio" },
      filetypes = {
        "html",
        "css",
        "scss",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "vue",
        "svelte",
      },
      root_markers = { "tailwind.config.js", "tailwind.config.ts", ".git" },
      capabilities = caps,
    }

    -- ============================================================
    -- 10. Kích hoạt Language Servers (API mới)
    -- ============================================================
    vim.lsp.enable("lua_ls")
    vim.lsp.enable("ts_ls")
    vim.lsp.enable("eslint")
    vim.lsp.enable("cssls")
    vim.lsp.enable("html")
    vim.lsp.enable("jsonls")
    vim.lsp.enable("intelephense")
    vim.lsp.enable("pyright")
    -- vim.lsp.enable("nil_ls") -- Uncomment if you have installed nil
    vim.lsp.enable("tailwindcss")

    -- ============================================================
    -- 11. Nvim-cmp (Autocompletion)
    -- ============================================================
    local cmp = require("cmp")
    require("luasnip.loaders.from_vscode").lazy_load()

    vim.opt.completeopt = { "menu", "menuone", "noselect" }

    cmp.setup({
      preselect = "item",
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      window = {
        documentation = cmp.config.window.bordered(),
        completion = cmp.config.window.bordered(),
      },
      sources = {
        { name = "nvim_lsp", priority = 1000 },
        { name = "luasnip",  priority = 750, keyword_length = 2 },
        { name = "path",     priority = 500 },
        { name = "buffer",   priority = 250, keyword_length = 3 },
      },
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body)
        end,
      },
      formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, item)
          local icons = {
            Text = "",
            Method = "󰆧",
            Function = "󰊕",
            Constructor = "",
            Field = "󰜢",
            Variable = "󰀫",
            Class = "󰠱",
            Interface = "",
            Module = "",
            Property = "󰜢",
            Unit = "󰑭",
            Value = "󰎠",
            Enum = "",
            Keyword = "󰌋",
            Snippet = "",
            Color = "󰏘",
            File = "󰈙",
            Reference = "󰈇",
            Folder = "󰉋",
            EnumMember = "",
            Constant = "󰏿",
            Struct = "󰙅",
            Event = "",
            Operator = "󰆕",
            TypeParameter = "",
          }

          item.kind = string.format("%s %s", icons[item.kind] or "", item.kind)

          local menu_icons = {
            nvim_lsp = "[LSP]",
            luasnip = "[Snip]",
            buffer = "[Buf]",
            path = "[Path]",
          }
          item.menu = menu_icons[entry.source.name] or string.format("[%s]", entry.source.name)

          return item
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<CR>"] = cmp.mapping.confirm({ select = false }),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-f>"] = cmp.mapping.scroll_docs(5),
        ["<C-u>"] = cmp.mapping.scroll_docs(-5),
        ["<C-e>"] = cmp.mapping.abort(),

        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          else
            local col = vim.fn.col(".") - 1
            if col == 0 or vim.fn.getline("."):sub(col, col):match("%s") then
              fallback()
            else
              cmp.complete()
            end
          end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_prev_item()
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-d>"] = cmp.mapping(function(fallback)
          local luasnip = require("luasnip")
          if luasnip.jumpable(1) then
            luasnip.jump(1)
          else
            fallback()
          end
        end, { "i", "s" }),

        ["<C-b>"] = cmp.mapping(function(fallback)
          local luasnip = require("luasnip")
          if luasnip.jumpable(-1) then
            luasnip.jump(-1)
          else
            fallback()
          end
        end, { "i", "s" }),
      }),
    })
  end,
}
