-- ============================================================================
--  plugins/grug_far.lua — interactive find / replace across files
--
--  Inside the grug-far buffer, <localleader> is the prefix for buffer-local
--  actions. The most common one is <localleader>r to apply replacements after
--  typing your search and replace strings.
-- ============================================================================

require("grug-far").setup({})

vim.keymap.set("n", "<leader>sr",
  function() require("grug-far").open() end,
  { desc = "[S]earch and [R]eplace (grug-far)", silent = true })

vim.keymap.set("n", "<leader>sw",
  function() require("grug-far").open({ prefills = { search = vim.fn.expand("<cword>") } }) end,
  { desc = "[S]earch [w]ord under cursor", silent = true })

vim.keymap.set("x", "<leader>ss",
  function() require("grug-far").with_visual_selection() end,
  { desc = "[S]earch visual [s]election", silent = true })
