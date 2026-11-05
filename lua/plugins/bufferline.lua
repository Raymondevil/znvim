-- ============================================================================
--  plugins/bufferline.lua — tab-style buffer list along the top
--
--  Buffer navigation keymaps already live in config/keymaps.lua:
--    <S-h>/<S-l>   prev/next buffer
--    <leader>bd    delete buffer
-- ============================================================================

require("bufferline").setup({
  options = {
    mode                    = "buffers",
    diagnostics             = "nvim_lsp",
    diagnostics_indicator   = function(count, level)
      local icon = level:match("error") and " " or " "
      return " " .. icon .. count
    end,
    separator_style         = "slant",
    show_buffer_close_icons = false,
    show_close_icon         = false,
    always_show_bufferline  = true,
    -- Reserve space for the nvim-tree sidebar so the tabs line up with
    -- the actual editor area instead of the tree.
    offsets = {
      {
        filetype  = "NvimTree",
        text      = "File Explorer",
        highlight = "Directory",
        separator = true,
      },
    },
  },
})

local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

map("<leader>bp", "<cmd>BufferLineTogglePin<CR>",         "[B]uffer: toggle [p]in")
map("<leader>bc", "<cmd>BufferLineCloseOthers<CR>",       "[B]uffer: [c]lose others")
map("<leader>bh", "<cmd>BufferLineCloseLeft<CR>",         "[B]uffer: close [h]-left")
map("<leader>bl", "<cmd>BufferLineCloseRight<CR>",        "[B]uffer: close [l]-right")
map("<leader>bP", "<cmd>BufferLinePick<CR>",              "[B]uffer: [P]ick")

-- gt/gT cycle buffers in the order shown in the bufferline (respects pins),
-- mirroring their native tab-page meaning since this config uses buffers as
-- "tabs". <S-h>/<S-l> in config/keymaps.lua do the same via :bnext/:bprev.
map("gt", "<cmd>BufferLineCycleNext<CR>", "Next buffer (right)")
map("gT", "<cmd>BufferLineCyclePrev<CR>", "Prev buffer (left)")
