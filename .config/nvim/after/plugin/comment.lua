local ft = require("Comment.ft")

-- Unsupported filetypes example
ft
-- Set only line comment
--    .set('yaml', '#%s')
-- Or set both line and block commentstring
    .set("javascript", { "//%s", "/*%s*/" })
-- 2. Metatable magic
ft.javascript = { "//%s", "/*%s*/" }
-- ft.yaml = '#%s'
-- Multiple filetypes
ft({ "go", "rust" }, ft.get("c"))
ft({ "toml", "graphql" }, "#%s")
