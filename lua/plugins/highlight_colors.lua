-- ============================================================================
--  plugins/highlight_colors.lua — render color literals (#fff, rgb(), HSL,
--  CSS named colors, Tailwind classes) as colored swatches in the buffer.
-- ============================================================================

require("nvim-highlight-colors").setup({
  render              = "background",  -- "background" | "foreground" | "virtual"
  enable_named_colors = true,
  enable_tailwind     = true,
  enable_hex          = true,
  enable_rgb          = true,
  enable_hsl          = true,
})
