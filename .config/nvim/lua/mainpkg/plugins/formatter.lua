-- luacheck: globals vim

return {
    "stevearc/conform.nvim",
    config = function()
        require("conform").setup({
            log_level = vim.log.levels.TRACE,
            notify_on_error = true,
            -- format_on_save = {
            --     timeout_ms = 3000,
            --     async = false,
            --     quiet = false,
            -- },
            formatters_by_ft = {
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                markdown = { "prettier" },
                lua = { "stylua" },
                python = { "isort", "black" },
                ["yaml.ansible"] = { "prettier" },
                yaml = { "prettier" },
            },
        })
    end,
}
