-- ============================================================================
--  plugins/dropbar.lua — breadcrumbs winbar (file > class > method)
--
--  The modern successor to LunarVim's nvim-navic winbar. Sources resolve
--  automatically per buffer: LSP document symbols when a server is attached,
--  treesitter otherwise, headings in markdown, path segments everywhere.
--  Every crumb is clickable, and <leader>; opens an interactive picker.
-- ============================================================================

require("dropbar").setup({})

local api = require("dropbar.api")
vim.keymap.set("n", "<leader>;", api.pick,               { desc = "Breadcrumbs: pick symbol" })
vim.keymap.set("n", "[;",        api.goto_context_start, { desc = "Breadcrumbs: go to context start" })
vim.keymap.set("n", "];",        api.select_next_context, { desc = "Breadcrumbs: select next context" })
