-- luacheck: globals vim

return {
    "neovim/nvim-lspconfig",
    lazy = false,
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        { "hrsh7th/cmp-nvim-lsp" },
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", config = true },
        { "hrsh7th/vscode-langservers-extracted" },
    },
    config = function()
        local opts = { noremap = true, silent = true }
        local on_attach = function(client, bufnr)
            opts.buffer = bufnr

            -- set keybinds
            -- opts.desc = "Show LSP references"
            -- vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

            -- opts.desc = "Show LSP definitions"
            -- vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

            -- opts.desc = "Show LSP implementations"
            -- vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

            -- opts.desc = "Show LSP type definitions"
            -- vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

            -- opts.desc = "Show buffer diagnostics"
            -- vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

            opts.desc = "Show line diagnostics"
            vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts) -- show diagnostics for line

            opts.desc = "Go to previous diagnostic"
            vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts) -- jump to previous diagnostic in buffer

            opts.desc = "Go to next diagnostic"
            vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts) -- jump to next diagnostic in buffer

            opts.desc = "Show help for the method signature"
            vim.keymap.set("n", "<leader>vh", vim.lsp.buf.signature_help, opts)

            opts.desc = "Show documentation for what is under cursor"
            vim.keymap.set("n", "<leader>vk", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

            opts.desc = "Go to declaration"
            vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

            opts.desc = "Go to definition"
            vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

            opts.desc = "Show lsp workspace_symbol"
            vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

            opts.desc = "Prompt for lsp code action"
            vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)

            opts.desc = "Show current references"
            vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)

            opts.desc = "Rename a variable"
            vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)

            opts.desc = "Format the code using LSP"
            vim.keymap.set({ "n", "v" }, "<leader>vfl", vim.lsp.buf.format, opts)
        end

        -- import cmp-nvim-lsp plugin
        local cmp_nvim_lsp = require("cmp_nvim_lsp")

        -- used to enable autocompletion (assign to every lsp server config)
        local capabilities = cmp_nvim_lsp.default_capabilities()

        -- Change the Diagnostic symbols in the sign column (gutter)
        -- (not in youtube nvim video)
        local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        -- import lspconfig plugin
        local lspconfig = require("lspconfig")

    end,
}
