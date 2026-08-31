# Keybindings

Leader key: `<space>` (set in `lua/mainpkg/init.lua`).

Mode codes: `n` normal, `v` visual, `x` visual (excludes select mode), `i` insert.

## Editing and motion

Source: `lua/mainpkg/keymap.lua`

| Mode | Keys          | Action                                                                                                                           |
| ---- | ------------- | -------------------------------------------------------------------------------------------------------------------------------- |
| n    | `<leader>pv`  | Open netrw                                                                                                                       |
| v    | `J`           | Move selected lines down                                                                                                         |
| v    | `K`           | Move selected lines up                                                                                                           |
| n    | `J`           | Join line below, keep cursor position                                                                                            |
| n    | `<C-d>`       | Half page down, keep cursor centered                                                                                             |
| n    | `<C-u>`       | Half page up, keep cursor centered                                                                                               |
| n    | `n`           | Next search match, keep cursor centered                                                                                          |
| n    | `N`           | Previous search match, keep cursor centered                                                                                      |
| x    | `<leader>p`   | Paste over selection without overwriting the register                                                                            |
| n, v | `<leader>y`   | Yank to the system clipboard                                                                                                     |
| n    | `<leader>Y`   | Yank line to the system clipboard                                                                                                |
| n    | `<leader>vrn` | Prefill `:%s` to replace the word under the cursor across the file (overridden by LSP rename when an LSP is attached, see below) |
| n    | `<leader>x`   | Make the current file executable (`chmod +x`)                                                                                    |

## Windows

Source: `lua/mainpkg/keymap.lua`

| Mode | Keys          | Action                 |
| ---- | ------------- | ---------------------- |
| n    | `<leader>wh`  | Go to the left window  |
| n    | `<leader>wj`  | Go to the lower window |
| n    | `<leader>wk`  | Go to the upper window |
| n    | `<leader>wl`  | Go to the right window |
| n    | `<C-S-Up>`    | Increase window height |
| n    | `<C-S-Down>`  | Decrease window height |
| n    | `<C-S-Left>`  | Decrease window width  |
| n    | `<C-S-Right>` | Increase window width  |

## Tabs

Source: `lua/mainpkg/keymap.lua`

| Mode | Keys         | Action                               |
| ---- | ------------ | ------------------------------------ |
| n    | `<leader>to` | Open a new tab                       |
| n    | `<leader>tx` | Close the current tab                |
| n    | `<leader>tn` | Go to the next tab                   |
| n    | `<leader>tp` | Go to the previous tab               |
| n    | `<leader>tf` | Open the current buffer in a new tab |

## Search (Telescope)

Source: `after/plugin/telescope.lua`

| Mode | Keys         | Action                                                                |
| ---- | ------------ | --------------------------------------------------------------------- |
| n    | `<leader>fa` | Find all files, including hidden and ignored ones                     |
| n    | `<leader>ff` | Find files in the project directory                                   |
| n    | `<leader>fg` | Live grep across the project                                          |
| n    | `<leader>fb` | Find open buffers                                                     |
| n    | `<leader>fh` | Find help tags                                                        |
| n    | `<C-p>`      | Find git-tracked files                                                |
| n    | `<leader>ps` | Prompt for a string and grep it across the project (requires ripgrep) |

## File explorer (Neo-tree)

Source: `lua/mainpkg/plugins/neo-tree.lua`, `after/plugin/neo-tree.lua`

| Mode | Keys         | Action                                     |
| ---- | ------------ | ------------------------------------------ |
| n    | `<leader>nt` | Open Neo-tree and reveal the current file  |
| i    | `<esc>`      | Stop insert mode in a Neo-tree popup input |

Inside a Neo-tree window (buffer-local mappings):

| Keys                                     | Action                                                                                              |
| ---------------------------------------- | --------------------------------------------------------------------------------------------------- |
| `<space>`                                | Toggle node                                                                                         |
| `<cr>`, double-click                     | Open                                                                                                |
| `<esc>`                                  | Cancel / close preview or floating window                                                           |
| `P`                                      | Toggle preview (floating)                                                                           |
| `l`                                      | Focus preview                                                                                       |
| `S`                                      | Open in a split                                                                                     |
| `s`                                      | Open in a vertical split                                                                            |
| `t`                                      | Open in a new tab                                                                                   |
| `w`                                      | Open with window picker                                                                             |
| `C`                                      | Close node                                                                                          |
| `z`                                      | Close all nodes                                                                                     |
| `a`                                      | Add file                                                                                            |
| `A`                                      | Add directory                                                                                       |
| `d`                                      | Delete                                                                                              |
| `r`                                      | Rename                                                                                              |
| `y`                                      | Copy to clipboard                                                                                   |
| `x`                                      | Cut to clipboard                                                                                    |
| `p`                                      | Paste from clipboard                                                                                |
| `c`                                      | Copy                                                                                                |
| `m`                                      | Move                                                                                                |
| `<q>`                                    | Close the Neo-tree window                                                                           |
| `R`                                      | Refresh                                                                                             |
| `?`                                      | Show help                                                                                           |
| `<`, `>`                                 | Previous / next source                                                                              |
| `i`                                      | Show file details                                                                                   |
| `<bs>`                                   | Navigate up a directory (filesystem, buffers sources)                                               |
| `.`                                      | Set root (filesystem, buffers sources)                                                              |
| `H`                                      | Toggle hidden files (filesystem source)                                                             |
| `/`                                      | Fuzzy finder (filesystem source)                                                                    |
| `D`                                      | Fuzzy finder for directories (filesystem source)                                                    |
| `#`                                      | Fuzzy sorter (filesystem source)                                                                    |
| `f`                                      | Filter on submit (filesystem source)                                                                |
| `<c-x>`                                  | Clear filter (filesystem source)                                                                    |
| `[g`, `]g`                               | Previous / next git-modified item (filesystem source)                                               |
| `o`                                      | Show order-by help (all sources)                                                                    |
| `oc`, `od`, `og`, `om`, `on`, `os`, `ot` | Order by created, diagnostics, git status, modified, name, size, type (`og` filesystem source only) |
| `bd`                                     | Delete buffer (buffers source)                                                                      |
| `A`                                      | Git add all (git status source)                                                                     |
| `gu`                                     | Git unstage file (git status source)                                                                |
| `ga`                                     | Git add file (git status source)                                                                    |
| `gr`                                     | Git revert file (git status source)                                                                 |
| `gc`                                     | Git commit (git status source)                                                                      |
| `gp`                                     | Git push (git status source)                                                                        |
| `gg`                                     | Git commit and push (git status source)                                                             |

## Git

Source: `after/plugin/fugetive.lua`

| Mode | Keys         | Action                   |
| ---- | ------------ | ------------------------ |
| n    | `<leader>gs` | Open git status (`:Git`) |

## LSP

Source: `lua/mainpkg/plugins/lsp/lspconfig.lua`. Buffer-local, active once an LSP client attaches to the buffer.

| Mode | Keys          | Action                                                                                                               |
| ---- | ------------- | -------------------------------------------------------------------------------------------------------------------- |
| n    | `<leader>vd`  | Show diagnostics for the current line                                                                                |
| n    | `[d`          | Go to the previous diagnostic in the buffer                                                                          |
| n    | `]d`          | Go to the next diagnostic in the buffer                                                                              |
| n    | `<leader>vh`  | Show signature help                                                                                                  |
| n    | `<leader>vk`  | Show hover documentation                                                                                             |
| n    | `gD`          | Go to declaration                                                                                                    |
| n    | `gd`          | Go to definition                                                                                                     |
| n    | `<leader>vws` | Show workspace symbols                                                                                               |
| n    | `<leader>vca` | Show code actions                                                                                                    |
| n    | `<leader>vrr` | Show references                                                                                                      |
| n    | `<leader>vrn` | Rename the symbol under the cursor (overrides the global `<leader>vrn` substitute mapping while the LSP is attached) |
| n, v | `<leader>vfl` | Format with the LSP client                                                                                           |

## Diagnostics and Trouble

Source: `after/plugin/trouble.lua`

| Mode | Keys         | Action                           |
| ---- | ------------ | -------------------------------- |
| n    | `<leader>xx` | Toggle Trouble                   |
| n    | `<leader>xw` | Toggle workspace diagnostics     |
| n    | `<leader>xd` | Toggle document diagnostics      |
| n    | `<leader>xq` | Toggle the quickfix list         |
| n    | `<leader>xl` | Toggle the location list         |
| n    | `gR`         | Toggle LSP references in Trouble |

## Completion (insert mode)

Source: `lua/mainpkg/plugins/lsp/cmp.lua`, nvim-cmp's `preset.insert` defaults

| Keys        | Action                                                                |
| ----------- | --------------------------------------------------------------------- |
| `<C-Space>` | Trigger completion                                                    |
| `<C-e>`     | Abort completion                                                      |
| `<Down>`    | Select the next item                                                  |
| `<Up>`      | Select the previous item                                              |
| `<C-n>`     | Select the next item, or trigger completion if the menu is closed     |
| `<C-p>`     | Select the previous item, or trigger completion if the menu is closed |
| `<C-y>`     | Confirm the selected item                                             |

## Comments

Source: `lua/mainpkg/plugins/numtostr-comment.lua` (Comment.nvim)

| Mode | Keys         | Action                                   |
| ---- | ------------ | ---------------------------------------- |
| n    | `gcc`        | Toggle a line comment                    |
| n    | `gbc`        | Toggle a block comment                   |
| n, v | `gc{motion}` | Line comment over a motion or selection  |
| n, v | `gb{motion}` | Block comment over a motion or selection |
| n    | `gcO`        | Add a comment on the line above          |
| n    | `gco`        | Add a comment on the line below          |
| n    | `gcA`        | Add a comment at the end of the line     |

## Formatting and linting

Source: `after/plugin/formatter.lua`, `lua/mainpkg/plugins/lint.lua`

| Mode | Keys          | Action                                           |
| ---- | ------------- | ------------------------------------------------ |
| n    | `<leader>vff` | Format the file with conform.nvim                |
| n    | `<leader>vl`  | Trigger linting for the current file (nvim-lint) |

## Plugin management

Source: `lua/mainpkg/plugins/lsp/mason.lua`

| Mode | Keys         | Action            |
| ---- | ------------ | ----------------- |
| n    | `<leader>cm` | Open the Mason UI |

## Undo history

Source: `after/plugin/undotree.lua`

| Mode | Keys        | Action          |
| ---- | ----------- | --------------- |
| n    | `<leader>u` | Toggle Undotree |
