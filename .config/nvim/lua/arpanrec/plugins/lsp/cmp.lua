-- luacheck: globals vim

return {
  "hrsh7th/nvim-cmp",
  version = false,   -- last release is way too old
  event = "InsertEnter",
  lazy = false,
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-path" },
    { "L3MON4D3/LuaSnip" },
    { "saadparwaiz1/cmp_luasnip" },
    { "hrsh7th/cmp-calc" },
    { "hrsh7th/cmp-emoji" },
    { "hrsh7th/cmp-vsnip" },
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/vim-vsnip-integ" },
    { "rafamadriz/friendly-snippets" },
    { "onsails/lspkind.nvim" },
  },
  opts = function()
    vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
    local cmp = require("cmp")
    local luasnip = require("luasnip")
    -- local lspkind = require("lspkind")
    local defaults = require("cmp.config.default")()
    return {
      completion = {
        completeopt = "menu,menuone,noinsert",
      },
      snippet = {       -- configure how nvim-cmp interacts with snippet engine
        expand = function(args)
          luasnip.lsp_expand(args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-e>"] = cmp.mapping.abort(),
        -- Rest of the maps are done from lspconfig
        -- ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
        -- ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
        -- ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        -- ["<C-f>"] = cmp.mapping.scroll_docs(4),
        -- ["<C-y>"] = cmp.mapping.confirm({ select = true }),     -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        -- ["<S-CR>"] = cmp.mapping.confirm({
        --     behavior = cmp.ConfirmBehavior.Replace,
        --     select = true,
        -- }),     -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        -- ["<C-CR>"] = function(fallback)
        --     cmp.abort()
        --     fallback()
        -- end,
      }),
      sources = cmp.config.sources({
        { name = "path" },
        { name = "nvim_lsp" },
        { name = "nvim_lua" },
        { name = "buffer" },
        { name = "emoji" },
        { name = "calc" },
        { name = "vsnip" },
        { name = "json" },
        { name = "cmdline" },
        { name = "luasnip", keyword_length = 2 },
        { name = "buffer",  keyword_length = 3 },
        { name = "cmdline" },
        { name = "emoji" },
        { name = "calc" },
        { name = "vsnip" },
      }),
      -- formatting = {
      --     format = function(_, item)
      --         local icons = require("lazyvim.config").icons.kinds
      --         if icons[item.kind] then
      --             item.kind = icons[item.kind] .. item.kind
      --         end
      --         return item
      --     end,
      -- },
      -- formatting = {
      --     format = lspkind.cmp_format({
      --         maxwidth = 50,
      --         ellipsis_char = "...",
      --     }),
      -- },
      experimental = {
        ghost_text = {
          hl_group = "CmpGhostText",
        },
      },
      sorting = defaults.sorting,
    }
  end,
  config = function(_, opts)
    for _, source in ipairs(opts.sources) do
      source.group_index = source.group_index or 1
    end
    require("cmp").setup(opts)
  end,
}
