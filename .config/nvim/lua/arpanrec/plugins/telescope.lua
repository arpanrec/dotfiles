return {
    "nvim-telescope/telescope.nvim",
    tag = "0.1.5",
    dependencies = {
        { "nvim-lua/plenary.nvim" },
        { "nvim-telescope/telescope-ui-select.nvim" },
    },
    lazy = false,
    config = function()
        require("telescope").setup({
            defaults = { file_ignore_patterns = { "node_modules", "venv", ".venv,", ".git" } },
            pickers = { find_files = { hidden = false } }
        })
        -- telescope.load_extension("ui-select")
    end,
}
