-- ============================================================================
--  plugins/copilot.lua — github/copilot.vim
--
--  copilot.vim is a Vimscript plugin: no setup() to call, just globals and
--  keymaps. Authenticate once with `:Copilot setup` (or `:Copilot auth` on
--  newer builds) after a restart; check status with `:Copilot status`.
--
--  Suggestion accept is bound to <M-Tab> (Option+Tab on macOS) to mirror
--  Zed's keybinding. blink.cmp owns <Tab> for menu navigation, so the two
--  don't fight: <Tab> cycles completions, <M-Tab> takes the Copilot ghost.
-- ============================================================================

-- Disable Copilot's default <Tab> mapping — blink.cmp owns <Tab>.
vim.g.copilot_no_tab_map     = true
vim.g.copilot_assume_mapped  = true

-- Per-filetype enable. Default on; flip off where ghost text is noise.
vim.g.copilot_filetypes = {
  ["*"]           = true,
  TelescopePrompt = false,
  gitcommit       = false,
  gitrebase       = false,
  hgcommit        = false,
}

-- Accept suggestion (Option+Tab, matching Zed). expr+replace_keycodes is
-- the form copilot.vim's README documents — copilot#Accept returns the
-- keys to feed back, falling through to "\\<CR>" when no suggestion shows.
vim.keymap.set("i", "<M-Tab>", 'copilot#Accept("\\<CR>")', {
  expr            = true,
  replace_keycodes = false,
  silent          = true,
  desc            = "Copilot: accept suggestion",
})

vim.keymap.set("i", "<C-]>",  "<Plug>(copilot-dismiss)",   { desc = "Copilot: dismiss" })
vim.keymap.set("i", "<M-]>",  "<Plug>(copilot-next)",      { desc = "Copilot: next suggestion" })
vim.keymap.set("i", "<M-[>",  "<Plug>(copilot-previous)",  { desc = "Copilot: previous suggestion" })
vim.keymap.set("i", "<M-\\>", "<Plug>(copilot-suggest)",   { desc = "Copilot: trigger suggestion" })

-- Toggle ghost-text suggestions globally. `:Copilot disable` sets
-- g:copilot_enabled = 0; `:Copilot enable` clears it. nil/unset = enabled.
vim.keymap.set("n", "<leader>cp", function()
  local off = vim.g.copilot_enabled == 0 or vim.g.copilot_enabled == false
  if off then
    vim.cmd("Copilot enable")
    vim.notify("Copilot: suggestions enabled", vim.log.levels.INFO)
  else
    vim.cmd("Copilot disable")
    vim.notify("Copilot: suggestions disabled", vim.log.levels.WARN)
  end
end, { desc = "Copilot: toggle suggestions" })
