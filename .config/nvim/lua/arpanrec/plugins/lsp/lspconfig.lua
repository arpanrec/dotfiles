-- luacheck: globals vim

return {
  "neovim/nvim-lspconfig",
  lazy = false,
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    { "hrsh7th/cmp-nvim-lsp" },
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "folke/neodev.nvim",                   config = true },
    { "hrsh7th/vscode-langservers-extracted" },
  },
  config = function()
    local opts = { noremap = true, silent = true }
    local on_attach = function(client, bufnr)
      opts.buffer = bufnr

      -- set keybinds
      -- opts.desc = "Show LSP references"
      -- vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show definition, references

      -- opts.desc = "Show LSP definitions"
      -- vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show lsp definitions

      -- opts.desc = "Show LSP implementations"
      -- vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show lsp implementations

      -- opts.desc = "Show LSP type definitions"
      -- vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts) -- show lsp type definitions

      -- opts.desc = "Show buffer diagnostics"
      -- vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts) -- show  diagnostics for file

      opts.desc = "Show line diagnostics"
      vim.keymap.set("n", "<leader>vd", vim.diagnostic.open_float, opts)       -- show diagnostics for line

      opts.desc = "Go to previous diagnostic"
      vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)       -- jump to previous diagnostic in buffer

      opts.desc = "Go to next diagnostic"
      vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)       -- jump to next diagnostic in buffer

      opts.desc = "Show help for the method signature"
      vim.keymap.set("n", "<leader>vh", vim.lsp.buf.signature_help, opts)

      opts.desc = "Show documentation for what is under cursor"
      vim.keymap.set("n", "<leader>vk", vim.lsp.buf.hover, opts)       -- show documentation for what is under cursor

      opts.desc = "Go to declaration"
      vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)       -- go to declaration

      opts.desc = "Go to definition"
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)

      opts.desc = "Show lsp workspace_symbol"
      vim.keymap.set("n", "<leader>vws", vim.lsp.buf.workspace_symbol, opts)

      opts.desc = "Prompt for lsp code action"
      vim.keymap.set("n", "<leader>vca", vim.lsp.buf.code_action, opts)

      opts.desc = "Show current references"
      vim.keymap.set("n", "<leader>vrr", vim.lsp.buf.references, opts)

      opts.desc = "Rename a variable"
      vim.keymap.set("n", "<leader>vrn", vim.lsp.buf.rename, opts)

      opts.desc = "Format the code using LSP"
      vim.keymap.set({ "n", "v" }, "<leader>vfl", vim.lsp.buf.format, opts)
    end

    -- import cmp-nvim-lsp plugin
    local cmp_nvim_lsp = require("cmp_nvim_lsp")

    -- used to enable autocompletion (assign to every lsp server config)
    local capabilities = cmp_nvim_lsp.default_capabilities()

    -- Change the Diagnostic symbols in the sign column (gutter)
    -- (not in youtube nvim video)
    local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }

    for type, icon in pairs(signs) do
      local hl = "DiagnosticSign" .. type
      vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
    end

    -- import lspconfig plugin
    local lspconfig = require("lspconfig")

    -- configure html server
    lspconfig.html.setup({ capabilities = capabilities, on_attach = on_attach })

    -- configure css server
    lspconfig.cssls.setup({ capabilities = capabilities, on_attach = on_attach })

    -- configure tailwindcss server
    lspconfig.tailwindcss.setup({ capabilities = capabilities, on_attach = on_attach })

    -- configure svelte server
    lspconfig.svelte.setup({
      capabilities = capabilities,
      on_attach = function(client, bufnr)
        on_attach(client, bufnr)
        vim.api.nvim_create_autocmd("BufWritePost", {
          pattern = { "*.js", "*.ts" },
          callback = function(ctx)
            if client.name == "svelte" then
              client.notify("$/onDidChangeTsOrJsFile", { uri = ctx.file })
            end
          end,
        })
      end,
    })

    -- configure prisma orm server
    lspconfig.prismals.setup({ capabilities = capabilities, on_attach = on_attach })

    -- configure graphql language server
    lspconfig.graphql.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "graphql", "gql", "svelte", "typescriptreact", "javascriptreact" },
    })

    -- configure emmet language server
    lspconfig.emmet_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less", "svelte" },
    })

    lspconfig.tsserver.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {
        implicitProjectConfiguration = {
          checkJs = true,
        },
      },
    })

    -- -- configure eslint language server removed and added to lint.lua
    -- lspconfig.eslint.setup({
    --     capabilities = capabilities,
    --     on_attach = function(client, bufnr)
    --         on_attach(client, bufnr)
    --         vim.api.nvim_create_autocmd("BufWritePre", {
    --             buffer = bufnr,
    --             command = "EslintFixAll",
    --         })
    --     end,
    --     settings = {
    --         codeAction = {
    --             disableRuleComment = {
    --                 enable = true,
    --                 location = "separateLine",
    --             },
    --             showDocumentation = {
    --                 enable = true,
    --             },
    --         },
    --         codeActionOnSave = {
    --             enable = false,
    --             mode = "all",
    --         },
    --         experimental = {
    --             useFlatConfig = false,
    --         },
    --         format = false,
    --         nodePath = "",
    --         onIgnoredFiles = "off",
    --         problems = {
    --             shortenToSingleLine = false,
    --         },
    --         quiet = false,
    --         rulesCustomizations = {},
    --         run = "onType",
    --         useESLintClass = false,
    --         validate = "on",
    --         workingDirectory = {
    --             mode = "location",
    --         },
    --     },
    -- })

    local capabilities_cssls = vim.lsp.protocol.make_client_capabilities()
    capabilities_cssls.textDocument.completion.completionItem.snippetSupport = true
    lspconfig.cssls.setup({
      capabilities = capabilities_cssls,
      on_attach = on_attach,
    })

    lspconfig.css_variables.setup({ capabilities = capabilities, on_attach = on_attach })
    lspconfig.cssmodules_ls.setup({ capabilities = capabilities, on_attach = on_attach })

    lspconfig.jsonls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "json", "jsonc" },
      settings = {
        json = {
          schemas = {
            { fileMatch = { "package.json" },   url = "https://json.schemastore.org/package.json" },
            { fileMatch = { "tsconfig*.json" }, url = "https://json.schemastore.org/tsconfig.json" },
            {
              fileMatch = { ".prettierrc", ".prettierrc.json", "prettier.config.json" },
              url = "https://json.schemastore.org/prettierrc.json",
            },
            {
              fileMatch = { ".eslintrc", ".eslintrc.json" },
              url = "https://json.schemastore.org/eslintrc.json",
            },
            {
              fileMatch = { ".babelrc", ".babelrc.json", "babel.config.json" },
              url = "https://json.schemastore.rg/babelrc.json",
            },
            {
              fileMatch = { "lerna.json" },
              url = "https://json.schemastore.org/lerna.json",
            },
            {
              fileMatch = { "now.json", "vercel.json" },
              url = "https://json.schemastore.org/now.json",
            },
            {
              fileMatch = {
                ".stylelintrc",
                ".stylelintrc.json",
                "stylelint.config.json",
              },
              url = "http://json.schemastore.org/stylelintrc.json",
            },
          },
        },
      },
    })

    lspconfig.gopls.setup({ capabilities = capabilities, on_attach = on_attach })

    -- configure python server
    lspconfig.pyright.setup({ capabilities = capabilities, on_attach = on_attach })

    lspconfig.bashls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      filetypes = { "sh", "zsh" },
    })

    -- configure lua server (with special settingsi)
    if not package.loaded["neodev"] then
      require("neodev").setup({})
    end

    lspconfig.lua_ls.setup({
      capabilities = capabilities,
      on_attach = on_attach,
      settings = {       -- custom settings for lua
        Lua = {
          -- make the language server recognize "vim" global
          diagnostics = {
            globals = { "vim" },
          },
          workspace = {
            -- make language server aware of runtime files
            library = {
              [vim.fn.expand("$VIMRUNTIME/lua")] = true,
              [vim.fn.stdpath("config") .. "/lua"] = true,
            },
          },
          completion = {
            callSnippet = "Replace",
          },
        },
      },
    })

    lspconfig.ansiblels.setup({ capabilities = capabilities, on_attach = on_attach })

    lspconfig.yamlls.setup({
      capabilities = capabilities,
      filetypes = {
        "yaml",
        "yaml.docker-compose",
        "yaml.ansible",
      },
      on_attach = on_attach,
      settings = {
        yaml = {
          schemas = {
            ["http://json.schemastore.org/gitlab-ci.json"] = { ".gitlab-ci.yml" },
            ["https://json.schemastore.org/bamboo-spec.json"] = { "bamboo-specs/*.{yml,yaml}" },
            ["https://raw.githubusercontent.com/compose-spec/compose-spec/master/schema/compose-spec.json"] = {
              "docker-compose*.{yml,yaml}",
            },
            ["http://json.schemastore.org/github-workflow.json"] = { ".github/workflows/*.{yml,yaml}" },
            ["http://json.schemastore.org/github-action.json"] = { ".github/action.{yml,yaml}" },
            ["http://json.schemastore.org/prettierrc.json"] = { ".prettierrc.{yml,yaml}" },
            ["http://json.schemastore.org/stylelintrc.json"] = { ".stylelintrc.{yml,yaml}" },
            ["http://json.schemastore.org/circleciconfig"] = { ".circleci/**/*.{yml,yaml}" },

            -- ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/galaxy.json"] = { "galaxy.yml" },
            -- ["https://raw.githubusercontent.com/ansible/ansible-lint/main/src/ansiblelint/schemas/ansible.json#/$defs/tasks"] = { "**/tasks/*.{yml,yaml}" }
          },
        },
      },
    })

    lspconfig.marksman.setup({ capabilities = capabilities, on_attach = on_attach })
  end,
}
