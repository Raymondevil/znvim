-- ============================================================================
--  DreamNvim — ported to Neovim 0.12+ and vim.pack
--  Original: https://github.com/dreamsofcode-io/DreamNvim
--
--  Entry point. Keep this file tiny: set the leader first, then hand off
--  to modules under lua/config and lua/plugins.
-- ============================================================================

-- Enable Neovim's Lua bytecode cache. Must run before any require() so cached
-- modules (config.*, plugins.*) hit the cache on this run, not the next one.
vim.loader.enable()

-- Leader must be set BEFORE any plugin loads, because plugins bind to whatever
-- the leader is at their load time.
vim.g.mapleader = ","
vim.g.maplocalleader = ","

-- Prepend Mason's bin directory to $PATH so any LSP server / formatter Mason
-- installs becomes discoverable to Neovim (via vim.fn.executable) without a
-- shell restart. Keep this early — before any plugin tries to spawn a server.
do
  local is_windows = vim.uv.os_uname().sysname == "Windows_NT"
  local sep = is_windows and ";" or ":"
  vim.env.PATH = vim.fn.stdpath("data") .. "/mason/bin" .. sep .. vim.env.PATH
end

-- DreamNvim ships a .templ filetype binding (Go templ). Keep it, but via the
-- modern vim.filetype.add API rather than an autocmd.
vim.filetype.add({
  extension = {
    templ = "templ",
    svelte = "svelte",
  },
})

-- Load pieces in a deterministic order:
--   1. options  — must be set before UI-visible things render
--   2. pack     — downloads / activates plugins
--   3. plugins  — calls each plugin's setup()
--   4. keymaps  — non-plugin keymaps (plugin keymaps live with their plugin)
--   5. autocmds — non-plugin autocmds
require("config.options")
require("config.pack")
require("config.keymaps")
require("config.autocmds")
