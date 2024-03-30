-- luacheck: globals vim
return {
    "mhartington/formatter.nvim",
    version = nil,
    config = function()
        -- Provides the Format, FormatWrite, FormatLock, and FormatWriteLock commands
        require("formatter").setup({
            logging = true,
            log_level = vim.log.levels.WARN,
            filetype = {
                lua = { require("formatter.filetypes.lua").stylua },
                yaml = { require("formatter.filetypes.yaml").yamlfmt },
                python = { require("formatter.filetypes.python").black },
                ["yaml.ansible"] = { require("formatter.filetypes.yaml").yamlfmt },
            },
            vim.keymap.set({ "n", "v" }, "<leader>vff", function()
                vim.cmd(":Format")
            end, { desc = "Format current file using formatter" }),
        })
    end,
}
