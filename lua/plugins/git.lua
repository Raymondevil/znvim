-- ============================================================================
--  plugins/git.lua — gitsigns (gutter marks + hunks)
-- ============================================================================

require("gitsigns").setup({
  signs = {
    add          = { text = "▎" },
    change       = { text = "▎" },
    delete       = { text = "" },
    topdelete    = { text = "" },
    changedelete = { text = "▎" },
    untracked    = { text = "▎" },
  },
  current_line_blame = false,
  on_attach = function(bufnr)
    local gs  = require("gitsigns")
    local map = function(lhs, rhs, desc, opts)
      vim.keymap.set("n", lhs, rhs,
        vim.tbl_extend("force", { buffer = bufnr, desc = desc }, opts or {}))
    end

    -- In a diff window, fall through to vim's native ]c / [c (jump between
    -- diff blocks). Otherwise jump between gitsigns hunks. expr=true is
    -- required so the returned key sequence is what gets executed.
    map("]c", function()
      if vim.wo.diff then return "]c" end
      vim.schedule(function() gs.nav_hunk("next") end)
      return "<Ignore>"
    end, "Next git hunk", { expr = true })

    map("[c", function()
      if vim.wo.diff then return "[c" end
      vim.schedule(function() gs.nav_hunk("prev") end)
      return "<Ignore>"
    end, "Prev git hunk", { expr = true })

    -- stage_hunk on an already-staged hunk un-stages it (toggle), which is
    -- why there's no separate undo_stage binding (the API deprecated it).
    map("<leader>gs", gs.stage_hunk,     "[G]it [s]tage hunk (toggle)")
    map("<leader>gr", gs.reset_hunk,     "[G]it [r]eset hunk")
    -- Visual-mode stage/reset for partial hunks.
    vim.keymap.set("v", "<leader>gs", function()
      gs.stage_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "[G]it [s]tage selection" })
    vim.keymap.set("v", "<leader>gr", function()
      gs.reset_hunk({ vim.fn.line("."), vim.fn.line("v") })
    end, { buffer = bufnr, desc = "[G]it [r]eset selection" })
    map("<leader>gp", gs.preview_hunk_inline, "[G]it [p]review hunk (inline)")
    map("<leader>gb", gs.blame_line,     "[G]it [b]lame line")
    map("<leader>gB", gs.toggle_current_line_blame, "[G]it toggle inline [B]lame")
    map("<leader>gd", gs.diffthis,       "[G]it [d]iff buffer")
    map("<leader>gS", gs.stage_buffer,   "[G]it [S]tage entire buffer")
    map("<leader>gR", gs.reset_buffer,   "[G]it [R]eset entire buffer")
  end,
})
