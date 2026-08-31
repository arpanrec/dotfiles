-- luacheck: globals vim

return {
    "mason-org/mason.nvim",
    lazy = false,

    dependencies = {
        { "mason-org/mason-lspconfig.nvim" },
        { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    },

    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Open Mason Manage UI" } },
    config = function()
        -- import mason
        local mason = require("mason")
        -- enable mason and configure icons
        mason.setup({
            ui = {
                icons = {
                    package_installed = "✓",
                    package_pending = "➜",
                    package_uninstalled = "✗",
                },
            },
        })

        local mason_lspconfig = require("mason-lspconfig")

        mason_lspconfig.setup({
            -- list of servers for mason to install
            ---@type string[]
            ensure_installed = {
                -- LSP
                "lua_ls",
                "gopls",
                "marksman",
                "bashls",
                "rust_analyzer",
                -- "pyright",
                -- "ts_ls",
                "jsonls",
                -- "html",
                -- "cssls",
                -- "tailwindcss",
                -- "svelte",
                -- "graphql",
                -- "emmet_ls",
                -- "prismals",
                "ansiblels",
                "yamlls",
                -- "cssmodules_ls",
                "marksman",
                -- DAP
                -- Linter
                -- "eslint", -- This is not useded for lsp, but for linting only
                -- Formatter
            },

            -- automatically vim.lsp.enable() every server installed above
            automatic_enable = true,
        })

        local mason_tool_installer = require("mason-tool-installer")

        mason_tool_installer.setup({
            ensure_installed = {
                -- LSP
                -- "css-variables-language-server",
                -- DAP
                -- Linter
                "luacheck",
                -- "pylint",
                "yamllint",
                -- Formatter
                "yamlfmt",
                "stylua",
                -- "black",
                "prettier",
            },
        })
    end,
}
