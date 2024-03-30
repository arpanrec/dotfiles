-- luacheck: globals vim
return {
    "mfussenegger/nvim-lint",
    lazy = true,
    event = { "BufReadPre", "BufNewFile" }, -- to disable, comment this out
    config = function()
        local severities = {
            error = vim.diagnostic.severity.ERROR,
            fatal = vim.diagnostic.severity.ERROR,
            warning = vim.diagnostic.severity.WARN,
            refactor = vim.diagnostic.severity.INFO,
            info = vim.diagnostic.severity.INFO,
            convention = vim.diagnostic.severity.HINT,
        }

        local lint = require("lint")
        lint.linters.venv_pylint = {
            name = "venv_pylint",
            cmd = "python",
            stdin = false,
            args = {
                "-m",
                "pylint",
                "-f",
                "json",
            },
            ignore_exitcode = true,
            parser = function(output, bufnr)
                if output == "" then
                    return {}
                end
                local diagnostics = {}
                local buffer_path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":~:.")

                for _, item in ipairs(vim.json.decode(output) or {}) do
                    if not item.path or vim.fn.fnamemodify(item.path, ":~:.") == buffer_path then
                        local column = item.column > 0 and item.column or 0
                        local end_column = item.endColumn ~= vim.NIL and item.endColumn or column
                        table.insert(diagnostics, {
                            source = "pylint",
                            lnum = item.line - 1,
                            col = column,
                            end_lnum = item.line - 1,
                            end_col = end_column,
                            severity = assert(severities[item.type], "missing mapping for severity " .. item.type),
                            message = item.message .. " (" .. item.symbol .. ")",
                            code = item["message-id"],
                            user_data = {
                                lsp = {
                                    code = item["message-id"],
                                },
                            },
                        })
                    end
                end
                return diagnostics
            end,
        }

        lint.linters_by_ft = {

            javascript = { "eslint_d" },

            typescript = { "eslint_d" },

            javascriptreact = { "eslint_d" },

            typescriptreact = { "eslint_d" },

            svelte = { "eslint_d" },

            python = { "venv_pylint" },

            lua = { "luacheck" },

            yamllint = { "yamllint" },
        }

        local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

        vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
            group = lint_augroup,
            callback = function()
                lint.try_lint()
            end,
        })

        vim.keymap.set("n", "<leader>vl", function()
            lint.try_lint()
        end, { desc = "Trigger linting for current file" })
    end,
}
