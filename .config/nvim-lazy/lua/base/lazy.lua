local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end

require("lazy").setup({
    {
        "nvim-neo-tree/neo-tree.nvim",
          keys = {
            { "<leader>ft", "<cmd>Neotree toggle<cr>", desc = "NeoTree" },
          },
          config = function()
            require("neo-tree").setup()
          end,
      },
  })

vim.opt.rtp:prepend(lazypath)
