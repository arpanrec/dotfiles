return {
    "nvim-treesitter/nvim-treesitter",
    run = ":TSUpdate",
    lazy = false,
    config = function()
        require 'nvim-treesitter.configs'.setup {
            ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "python", "go", "bash", "tsx",
                "json", "javascript", "typescript", "html", "css", "yaml", "rust", "dockerfile", "graphql", "jsonc", },
            sync_install = false,
            auto_install = true,
            highlight = {
                enable = true,
                additional_vim_regex_highlighting = false,
            },
            indent = {
                enable =true,
            },
        }
    end,
}
