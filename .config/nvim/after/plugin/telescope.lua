local telescope = require("telescope.builtin")
vim.keymap.set("n", "<leader>fa",
    function()
        telescope.find_files({ hidden = true, no_ignore = true, no_ignore_parent = true })
    end,
    { desc = "Find all files" })
vim.keymap.set("n", "<leader>ff", telescope.find_files, { desc = "Smart find files in project directory" })
vim.keymap.set("n", "<leader>fg", telescope.live_grep,
    { desc = "Live grep, searches a string in entire project" })
vim.keymap.set("n", "<leader>fb", telescope.buffers, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", telescope.help_tags, { desc = "Find vim help apis and docs" })
vim.keymap.set("n", "<C-p>", telescope.git_files, { desc = "Find files which are present in git" })

vim.keymap.set("n", "<leader>ps", function()
    if vim.fn.executable("rg") == 0 then
        print("Ripgrep is not installed")
        return
    end

    telescope.grep_string({
        search = vim.fn.input("Grep String > "),
    })
end, {
    desc = "Find a string in entire project directory",
})
