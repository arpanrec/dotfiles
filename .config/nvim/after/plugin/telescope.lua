local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files in project directory" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live grep, searches a string in entire project" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Find open buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Find vim help apis and docs" })
vim.keymap.set("n", "<C-p>", builtin.git_files, { desc = "Find files which are present in git" })

vim.keymap.set("n", "<leader>ps", function()
    if vim.fn.executable("rg") == 0 then
        print("Ripgrep is not installed")
        return
    end

    builtin.grep_string({
        search = vim.fn.input("Grep String > "),
    })
end, {
    desc = "Find a string in entire project directory",
})
