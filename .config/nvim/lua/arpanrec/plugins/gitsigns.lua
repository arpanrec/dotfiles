-- luacheck: globals vim

return {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    lazy = false,
    config = true,
}
