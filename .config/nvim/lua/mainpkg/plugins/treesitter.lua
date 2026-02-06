-- luacheck: globals vim

return {
    "nvim-treesitter/nvim-treesitter",
    version = false,
    init = function(plugin)
        -- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
        -- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
        -- no longer trigger the **nvim-treesitter** module to be loaded in time.
        -- Luckily, the only things that those plugins need are the custom queries, which we make available
        -- during startup.

        require("lazy.core.loader").add_to_rtp(plugin)
    end,
    dependencies = {
        { "nvim-treesitter/nvim-treesitter-context" },
        { "nvim-treesitter/nvim-treesitter-textobjects" },
    },
    build = ":TSUpdate",
}
