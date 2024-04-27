-- luacheck: globals vim

vim.keymap.set("n", "<leader>gs", vim.cmd.Git, { desc = "Open git status" })
