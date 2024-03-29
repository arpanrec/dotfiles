return {
    "williamboman/mason.nvim",
    lazy = false,

    dependencies = {
        { "williamboman/mason-lspconfig.nvim" },
        { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    },

    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Open Mason Manage UI" } },
    build = ":MasonUpdate",
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
            ensure_installed = {},
            -- auto-install configured servers (with lspconfig)
            automatic_installation = true, -- not the same as ensure_installed
        })

        local mason_tool_installer = require("mason-tool-installer")

        mason_tool_installer.setup({
            ensure_installed = {
                "lua_ls",
                "gopls",
                "pyright",
                "marksman",
                "bashls",
                "pyright",
                "tsserver",
                "jsonls",
                "eslint",
                "html",
                "cssls",
                "tailwindcss",
                "svelte",
                "graphql",
                "emmet_ls",
                "prismals",
                "ansiblels",
                "yamlls",
                "cssmodules_ls",
                "marksman",
                "prettier",
                "stylua",
                "isort",
                "black",
                "pylint",
                "eslint_d",
                "yamlfmt",
                "yamllint",
                "ansible-lint",
                "css-variables-language-server",
            },
        })
    end,
}
