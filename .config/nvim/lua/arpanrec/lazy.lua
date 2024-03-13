-- if ~/.ssh/id_rsa_gitlab exists, set git clone url to ssh instead of https
local lazy_git_url = "https://github.com/%s.git"

if vim.fn.filereadable(vim.fn.expand("~/.ssh/id_rsa_gitlab")) == 1 then
    lazy_git_url = "git@github.com:%s.git"
end

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        lazy_git_url:format("folke/lazy.nvim"),
        "--branch=stable",
        lazypath,
    })
end

vim.opt.rtp:prepend(lazypath)

vim.cmd([[ let g:neo_tree_remove_legacy_commands = 1 ]])

require("lazy").setup({ { import = "arpanrec.plugins" }, { import = "arpanrec.plugins.lsp" } }, {
    install = {
        colorscheme = { "nightfly" },
    },
    checker = {
        enabled = true,
        notify = false,
    },
    change_detection = {
        notify = false,
    },
    git = {
        log = { "-8" },
        timeout = 120,
        url_format = lazy_git_url,
        filter = true,
    },
})
