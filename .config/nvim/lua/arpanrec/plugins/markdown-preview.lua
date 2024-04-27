-- luacheck: globals vim

if vim.fn.executable("yarn") == 0 then
    vim.notify("yarn is not installed, install it to use markdown-preview", vim.log.levels.ERROR, {})
    -- vim.api.nvim_err_writeln(debug.traceback("yarn is not installed, install it to use markdown-preview"))
    return {}
end

return {
    "iamcco/markdown-preview.nvim",
    lazy = false,
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    build = "cd app && yarn install",
    init = function()
        vim.g.mkdp_filetypes = { "markdown" }
    end,
    ft = { "markdown" },
}
