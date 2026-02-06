local cmp = require("cmp")
local cmp_autopairs = require("nvim-autopairs.completion.cmp")

local ts_node_func_parens_disabled = {
    -- ecma
    named_imports = true,
    -- rust
    use_declaration = true,
}

local default_handler = cmp_autopairs.filetypes["*"]["("].handler
cmp_autopairs.filetypes["*"]["("].handler = function(char, item, bufnr, rules, commit_character)
    default_handler(char, item, bufnr, rules, commit_character)
end

cmp.event:on(
    "confirm_done",
    cmp_autopairs.on_confirm_done({
        sh = false,
    })
)
