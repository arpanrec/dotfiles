-- luacheck: globals vim

return {
    "nvim-telescope/telescope.nvim",
    version = "*", -- track the latest tagged release, per telescope's own recommendation
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope-ui-select.nvim" },
        -- native sorter, strongly recommended by telescope's docs for sorting performance
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    },
    lazy = false,
    config = function()
        local telescope = require("telescope")
        telescope.setup({
            defaults = { file_ignore_patterns = { "node_modules", "venv", ".venv,", ".git" } },
            pickers = { find_files = { hidden = false } }
        })
        telescope.load_extension("ui-select")
        telescope.load_extension("fzf")
    end,
}
