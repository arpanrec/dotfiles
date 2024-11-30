-- luacheck: globals vim

local lazy_git_url = "https://github.com/%s.git"

if vim.fn.filereadable(vim.fn.expand("~/.ssh/github.com")) == 1 then
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

require("lazy").setup({ { import = "mainpkg.plugins" }, { import = "mainpkg.plugins.lsp" } }, {
    defaults = {
        lazy = false, -- should plugins be lazy-loaded?
        version = nil,
        -- default `cond` you can use to globally disable a lot of plugins
        -- when running inside vscode for example
        cond = nil, ---@type boolean|fun(self:LazyPlugin):boolean|nil
        -- version = "*", -- enable this to try installing the latest stable versions of plugins
    },
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
