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

-- -- auto pairs
-- {
--     "echasnovski/mini.pairs",
--     event = "VeryLazy",
--     opts = {},
--     keys = {
--         {
--             "<leader>up",
--             function()
--                 local Util = require("lazy.core.util")
--                 vim.g.minipairs_disable = not vim.g.minipairs_disable
--                 if vim.g.minipairs_disable then
--                     Util.warn("Disabled auto pairs", { title = "Option" })
--                 else
--                     Util.info("Enabled auto pairs", { title = "Option" })
--                 end
--             end,
--             desc = "Toggle auto pairs",
--         },
--     },
-- },

-- -- Fast and feature-rich surround actions. For text that includes
-- -- surrounding characters like brackets or quotes, this allows you
-- -- to select the text inside, change or modify the surrounding characters,
-- -- and more.
-- {
--     "echasnovski/mini.surround",
--     keys = function(_, keys)
--         -- Populate the keys based on the user's options
--         local plugin = require("lazy.core.config").spec.plugins["mini.surround"]
--         local opts = require("lazy.core.plugin").values(plugin, "opts", false)
--         local mappings = {
--             { opts.mappings.add,            desc = "Add surrounding",                     mode = { "n", "v" } },
--             { opts.mappings.delete,         desc = "Delete surrounding" },
--             { opts.mappings.find,           desc = "Find right surrounding" },
--             { opts.mappings.find_left,      desc = "Find left surrounding" },
--             { opts.mappings.highlight,      desc = "Highlight surrounding" },
--             { opts.mappings.replace,        desc = "Replace surrounding" },
--             { opts.mappings.update_n_lines, desc = "Update `MiniSurround.config.n_lines`" },
--         }
--         mappings = vim.tbl_filter(function(m)
--             return m[1] and #m[1] > 0
--         end, mappings)
--         return vim.list_extend(mappings, keys)
--     end,
--     opts = {
--         mappings = {
--             add = "gsa",            -- Add surrounding in Normal and Visual modes
--             delete = "gsd",         -- Delete surrounding
--             find = "gsf",           -- Find surrounding (to the right)
--             find_left = "gsF",      -- Find surrounding (to the left)
--             highlight = "gsh",      -- Highlight surrounding
--             replace = "gsr",        -- Replace surrounding
--             update_n_lines = "gsn", -- Update `n_lines`
--         },
--     },
-- },

-- -- comments
-- {
--     "JoosepAlviste/nvim-ts-context-commentstring",
--     lazy = true,
--     opts = {
--         enable_autocmd = false,
--     },
-- },
-- {
--     "echasnovski/mini.comment",
--     event = "VeryLazy",
--     opts = {
--         options = {
--             custom_commentstring = function()
--                 return require("ts_context_commentstring.internal").calculate_commentstring() or vim.bo
--                     .commentstring
--             end,
--         },
--     },
-- },

-- -- Better text-objects
-- {
--     "echasnovski/mini.ai",
--     -- keys = {
--     --   { "a", mode = { "x", "o" } },
--     --   { "i", mode = { "x", "o" } },
--     -- },
--     event = "VeryLazy",
--     opts = function()
--         local ai = require("mini.ai")
--         return {
--             n_lines = 500,
--             custom_textobjects = {
--                 o = ai.gen_spec.treesitter({
--                     a = { "@block.outer", "@conditional.outer", "@loop.outer" },
--                     i = { "@block.inner", "@conditional.inner", "@loop.inner" },
--                 }, {}),
--                 f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
--                 c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
--                 t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },
--             },
--         }
--     end,
--     config = function(_, opts)
--         require("mini.ai").setup(opts)
--         -- register all text objects with which-key
--         require("lazyvim.util").on_load("which-key.nvim", function()
--             ---@type table<string, string|table>
--             local i = {
--                 [" "] = "Whitespace",
--                 ['"'] = 'Balanced "',
--                 ["'"] = "Balanced '",
--                 ["`"] = "Balanced `",
--                 ["("] = "Balanced (",
--                 [")"] = "Balanced ) including white-space",
--                 [">"] = "Balanced > including white-space",
--                 ["<lt>"] = "Balanced <",
--                 ["]"] = "Balanced ] including white-space",
--                 ["["] = "Balanced [",
--                 ["}"] = "Balanced } including white-space",
--                 ["{"] = "Balanced {",
--                 ["?"] = "User Prompt",
--                 _ = "Underscore",
--                 a = "Argument",
--                 b = "Balanced ), ], }",
--                 c = "Class",
--                 f = "Function",
--                 o = "Block, conditional, loop",
--                 q = "Quote `, \", '",
--                 t = "Tag",
--             }
--             local a = vim.deepcopy(i)
--             for k, v in pairs(a) do
--                 a[k] = v:gsub(" including.*", "")
--             end

--             local ic = vim.deepcopy(i)
--             local ac = vim.deepcopy(a)
--             for key, name in pairs({ n = "Next", l = "Last" }) do
--                 i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
--                 a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
--             end
--             require("which-key").register({
--                 mode = { "o", "x" },
--                 i = i,
--                 a = a,
--             })
--         end)
--     end,
-- },
-- })
