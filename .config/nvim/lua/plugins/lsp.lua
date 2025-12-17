return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "williamboman/mason.nvim",
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        "hrsh7th/nvim-cmp",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "saadparwaiz1/cmp_luasnip",
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        "stevearc/conform.nvim",
    },
    config = function()
        -- 1. Setup Mason
        require("mason").setup({ ui = { border = "rounded" } })

        -- 2. Auto Install Tools
        require("mason-tool-installer").setup({
            ensure_installed = {
                "pyright", -- Python LSP
                "black",   -- Python Formatter
                "isort",   -- Python Import Sorter
                "lua-language-server",
                "stylua",
            },
        })

        -- 3. Config Diagnostics
        vim.diagnostic.config({
            float = { border = "rounded" },
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = "✘",
                    [vim.diagnostic.severity.WARN] = "▲",
                    [vim.diagnostic.severity.HINT] = "⚑",
                    [vim.diagnostic.severity.INFO] = "»",
                },
            },
        })

        -- 4. Capabilities (cho cmp)
        local capabilities = require("cmp_nvim_lsp").default_capabilities()

        -- 5. LspAttach (Keymaps & Settings)
        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                local opts = { buffer = ev.buf, silent = true }
                -- Keybindings
                vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
                vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
            end,
        })

        -- 6. CẤU HÌNH PYTHON (PYRIGHT) - API MỚI CHO NVIM 0.11+
        -- Lưu ý: Sử dụng vim.lsp.config('tên', { ... }) thay vì gán bằng dấu =
        vim.lsp.config('pyright', {
            cmd = { "pyright-langserver", "--stdio" },
            filetypes = { "python" },
            -- root_markers thay thế cho logic root_dir cũ
            root_markers = { "pyproject.toml", "setup.py", "requirements.txt", ".git" },
            capabilities = capabilities,
            settings = {
                python = {
                    analysis = {
                        autoSearchPaths = true,
                        useLibraryCodeForTypes = true,
                        diagnosticMode = "workspace",
                        typeCheckingMode = "basic", -- hoặc "strict"
                    },
                },
            },
        })

        -- Cấu hình Lua (Ví dụ khác để tham khảo)
        vim.lsp.config('lua_ls', {
            cmd = { "lua-language-server" },
            root_markers = { ".luarc.json", ".git" },
            capabilities = capabilities,
            settings = {
                Lua = {
                    diagnostics = { globals = { "vim" } },
                },
            },
        })

        -- 7. Kích hoạt Server
        -- Trong Nvim 0.11+, bạn dùng vim.lsp.enable()
        vim.lsp.enable('pyright')
        vim.lsp.enable('lua_ls')

        -- 8. Conform (Formatter)
        require("conform").setup({
            formatters_by_ft = {
                python = { "isort", "black" }, -- Chạy isort trước, sau đó black
                lua = { "stylua" },
            },
            format_on_save = {
                timeout_ms = 500,
                lsp_fallback = true,
            },
        })
        
        -- 9. Setup nvim-cmp (như cũ của bạn, đã rút gọn cho ngắn)
        local cmp = require("cmp")
        cmp.setup({
            snippet = { expand = function(args) require("luasnip").lsp_expand(args.body) end },
            mapping = cmp.mapping.preset.insert({
                ["<CR>"] = cmp.mapping.confirm({ select = true }),
                ["<C-Space>"] = cmp.mapping.complete(),
            }),
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
                { name = "buffer" },
            }),
        })
    end,
}