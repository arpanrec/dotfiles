-- luacheck: globals vim

local opts = { noremap = true, silent = true }

opts.desc = "Open netrw"
vim.keymap.set("n", "<leader>pv", vim.cmd.Ex, opts)

opts.desc = "Move highlighted lines down"
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", opts)

opts.desc = "Move highlighted lines up"
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", opts)

opts.desc = "Append the line below followed by the current line with a space and keep the cursor in the same place"
vim.keymap.set("n", "J", "mzJ`z", opts)

opts.desc = "Jump half page down"
vim.keymap.set("n", "<C-d>", "<C-d>zz", opts)

opts.desc = "Jump half page up"
vim.keymap.set("n", "<C-u>", "<C-u>zz", opts)

opts.desc = "Keep the search text result in the middle"
vim.keymap.set("n", "n", "nzzzv", opts)

opts.desc = "Keep the search text result in the middle"
vim.keymap.set("n", "N", "Nzzzv", opts)

opts.desc = [[
    "Keeps the current copied text,
    by first deleting the selected text and place the copiied text into the void register."
]]
vim.keymap.set("x", "<leader>p", [["_dP]], opts)

opts.desc = "copy selected text to system clipboard in normal and visual mode"
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], opts)
opts.desc = "copy selected text to system clipboard in normal"
vim.keymap.set("n", "<leader>Y", [["+Y]], opts)

opts.desc = "Replace the word under the curson for the entire file"
vim.keymap.set("n", "<leader>vrn", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], opts)

opts.desc = "Make the current file executable"
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", opts)

-- Move to window using the <ctrl> hjkl keys
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to left window", remap = true })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window", remap = true })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window", remap = true })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to right window", remap = true })

-- Resize window using <ctrl> arrow keys
vim.keymap.set("n", "<C-S-Up>", "<cmd>resize +2<cr>", { desc = "Increase window height" })
vim.keymap.set("n", "<C-S-Down>", "<cmd>resize -2<cr>", { desc = "Decrease window height" })
vim.keymap.set("n", "<C-S-Left>", "<cmd>vertical resize -2<cr>", { desc = "Decrease window width" })
vim.keymap.set("n", "<C-S-Right>", "<cmd>vertical resize +2<cr>", { desc = "Increase window width" })

vim.keymap.set("n", "<leader>to", "<cmd>tabnew<CR>", { desc = "Open new tab" })        -- open new tab
vim.keymap.set("n", "<leader>tx", "<cmd>tabclose<CR>", { desc = "Close current tab" }) -- close current tab
vim.keymap.set("n", "<leader>tn", "<cmd>tabn<CR>", { desc = "Go to next tab" })        --  go to next tab
vim.keymap.set("n", "<leader>tp", "<cmd>tabp<CR>", { desc = "Go to previous tab" })    --  go to previous tab
--  move current buffer to new tab
vim.keymap.set("n", "<leader>tf", "<cmd>tabnew %<CR>", { desc = "Open current buffer in new tab" })
