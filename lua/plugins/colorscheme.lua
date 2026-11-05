-- ============================================================================
--  plugins/colorscheme.lua — Catppuccin (Dreams of Code's signature theme)
-- ============================================================================

require("catppuccin").setup({
  flavour = "mocha", -- latte, frappe, macchiato, mocha
  transparent_background = false,
  term_colors = true,
  color_overrides = {
    mocha = {
      base = "#06131f",
      mantle = "#040d18",
      crust = "#020811",
      surface0 = "#0e2336",
      surface1 = "#1a3550",
      surface2 = "#2a4768",
      overlay0 = "#7a8aa8",
      overlay1 = "#8d9bb8",
      overlay2 = "#a3aac4",
    },
  },
  styles = {
    comments = { "italic" },
    conditionals = { "italic" },
  },
  -- Comment fg defaults to `overlay2`, which is also used by
  -- `@punctuation.bracket` — making parens and comments visually identical.
  -- Override Comment directly so brackets keep their color.
  custom_highlights = function(_)
    return {
      Comment = { fg = "#7a8aa8", style = { "italic" } },
    }
  end,
  -- Integrations whose group module indexes sub-fields of its own options
  -- table MUST be passed as `{ enabled = true }`, not `true`. catppuccin
  -- normalizes `true` → `{ enabled = true }` only inside M.compile(); on
  -- cache-warm runs (every run after the first) the raw `true` leaks
  -- through and the integration errors with "attempt to index a boolean".
  -- Safe-as-`true`: mason, treesitter, which_key.
  integrations = {
    blink_cmp = { enabled = true },
    dropbar = { enabled = true, color_mode = true },
    gitsigns = { enabled = true },
    indent_blankline = { enabled = true, scope_color = "lavender" },
    lualine = { enabled = true },
    mason = true,
    native_lsp = { enabled = true },
    telescope = { enabled = true },
    treesitter = true,
    which_key = true,
  },
})

vim.cmd.colorscheme("color-9")
