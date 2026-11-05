-- ============================================================================
--  plugins/completion.lua — blink.cmp (the modern replacement for nvim-cmp)
--
--  blink.cmp pulls LSP + path + snippets + buffer suggestions into a single,
--  fast popup menu. Snippet expansion (LSP snippet items, placeholder jumps)
--  uses Neovim's built-in vim.snippet via blink's default preset — LuaSnip
--  was removed because no user snippet library is loaded.
-- ============================================================================

-- --- Completion UI ----------------------------------------------------------
require("blink.cmp").setup({
  keymap = {
    -- `enter` preset wires <CR> → accept. Then we override <Tab>/<S-Tab> so
    -- they cycle the completion menu when it's open, fall back to snippet
    -- jumps inside a snippet, and finally fall through to a literal Tab.
    preset    = "enter",
    ["<Tab>"]   = { "select_next", "snippet_forward",  "fallback" },
    ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
  },
  appearance = {
    -- Switch to "normal" if your font is "Nerd Font" (not "Nerd Font Mono")
    nerd_font_variant = "mono",
  },
  completion = {
    accept         = { auto_brackets = { enabled = true } },
    documentation  = { auto_show = true, auto_show_delay_ms = 200 },
    ghost_text     = { enabled = false },
    menu = {
      draw = { treesitter = { "lsp" } },  -- highlight snippet bodies with treesitter
    },
  },
  sources = {
    default = { "lsp", "path", "snippets", "buffer" },
  },
  -- Prefer the Rust matcher (~6x faster) and let blink download a prebuilt
  -- binary on first run. Falls back to the Lua matcher if the download fails
  -- or the platform isn't supported.
  fuzzy = {
    implementation    = "prefer_rust_with_warning",
    prebuilt_binaries = { download = true },
  },
  signature = { enabled = true },
})
