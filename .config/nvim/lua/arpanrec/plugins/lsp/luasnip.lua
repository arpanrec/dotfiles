-- luacheck: globals vim

return {
  "L3MON4D3/LuaSnip",
  dependencies = { { "rafamadriz/friendly-snippets" } },
  config = function()
    require("luasnip").config.set_config({ history = true })
  end,
}
