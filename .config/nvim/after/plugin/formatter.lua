-- luacheck: globals vim

vim.api.nvim_create_user_command("Conform", function(args)
    local range = nil
    if args.count ~= -1 then
        local end_line = vim.api.nvim_buf_get_lines(0, args.line2 - 1, args.line2, true)[1]
        range = {
            start = { args.line1, 0 },
            ["end"] = { args.line2, end_line:len() },
        }
    end
    require("conform").format({ async = true, lsp_fallback = false, range = range })
end, { range = true })

vim.keymap.set("n", "<leader>vff", vim.cmd.Conform, { desc = "Format file using conform" })
