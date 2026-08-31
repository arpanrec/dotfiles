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
        vim.diagnostic.config({
            signs = {
                text = {
                    [vim.diagnostic.severity.ERROR] = " ",
                    [vim.diagnostic.severity.WARN] = " ",
                    [vim.diagnostic.severity.HINT] = "󰠠 ",
                    [vim.diagnostic.severity.INFO] = " ",
                },
            },
        })

        -- merged into every server config enabled via vim.lsp.enable()
        vim.lsp.config("*", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("mainpkg-lsp-attach", { clear = true }),
            callback = function(args)
                local opts = { noremap = true, silent = true, buffer = args.buf }

                opts.desc = "Show line diagnostics"
                vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)

                opts.desc = "Go to previous diagnostic"
                vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

                opts.desc = "Go to next diagnostic"
                vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

                opts.desc = "Show help for the method signature"
                vim.keymap.set("n", "<leader>vh", vim.lsp.buf.signature_help, opts)

                opts.desc = "Show documentation for what is under cursor"
                vim.keymap.set("n", "<leader>vk", vim.lsp.buf.hover, opts)

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

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
            end,
        })
    end,
}
