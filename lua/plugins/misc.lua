-- ============================================================================
--  plugins/misc.lua — undotree, tmux interop, formatter
-- ============================================================================

-- --- Undotree (visual undo history, toggled by <leader>u) -------------------
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle [U]ndotree" })

-- --- vim-tmux-navigator (seamless <C-h/j/k/l> across tmux + nvim) -----------
vim.g.tmux_navigator_no_mappings = 0   -- leave its defaults in place

-- --- conform.nvim (format-on-save) ------------------------------------------
local conform = require("conform")
conform.setup({
  formatters_by_ft = {
    lua              = { "stylua" },
    python           = { "ruff_format", "black", stop_after_first = true },
    go               = { "gofmt", "goimports" },
    rust             = { "rustfmt", lsp_format = "fallback" },
    javascript       = { "prettierd", "prettier", stop_after_first = true },
    typescript       = { "prettierd", "prettier", stop_after_first = true },
    javascriptreact  = { "prettierd", "prettier", stop_after_first = true },
    typescriptreact  = { "prettierd", "prettier", stop_after_first = true },
    svelte           = { "prettierd", "prettier", stop_after_first = true },
    html             = { "prettierd", "prettier", stop_after_first = true },
    css              = { "prettierd", "prettier", stop_after_first = true },
    json             = { "prettierd", "prettier", stop_after_first = true },
    yaml             = { "prettierd", "prettier", stop_after_first = true },
    markdown         = { "prettierd", "prettier", stop_after_first = true },
    sh               = { "shfmt" },
  },
  format_on_save = function(bufnr)
    -- Allow disabling per-buffer or globally via `vim.g.disable_autoformat`.
    if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then return end
    -- Skip on bigfiles — formatters on multi-MB buffers stall the save.
    if vim.b[bufnr].bigfile then return end
    -- 2s cap: prettierd's first format per project cold-starts a daemon and
    -- loads local prettier + plugins (svelte/tailwind), which blows past a
    -- tight cap. Warm formats take ~10-30ms, so this rarely engages.
    return { timeout_ms = 2000, lsp_format = "fallback" }
  end,
})

-- Toggle format-on-save on the fly.
vim.api.nvim_create_user_command("FormatDisable", function(args)
  if args.bang then vim.b.disable_autoformat = true else vim.g.disable_autoformat = true end
end, { desc = "Disable autoformat (use ! for buffer-local)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
  vim.b.disable_autoformat = false
  vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat" })

-- Manual format shortcut
vim.keymap.set({ "n", "v" }, "<leader>lf",
  function() conform.format({ async = true, lsp_format = "fallback" }) end,
  { desc = "[L]SP [f]ormat buffer/range" })
