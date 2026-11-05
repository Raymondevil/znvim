-- ============================================================================
--  plugins/treesitter.lua — nvim-treesitter (main branch)
--
--  The main branch of nvim-treesitter has a different API than master:
--    * `ensure_install` (noun) replaces `ensure_installed`.
--    * Parsers are ONLY installed on a fresh setup; to add one after,
--      run `:TSInstall <lang>` and `:TSUpdate`.
--    * Highlights must be started manually via `vim.treesitter.start()`.
--      We do that in a FileType autocmd so every buffer gets it automatically.
-- ============================================================================

require("nvim-treesitter").setup({
  ensure_install = {
    -- Core
    "lua", "luadoc", "vim", "vimdoc", "query",
    -- Shell / config
    "bash", "json", "jsonc", "yaml", "toml",
    -- Web
    "html", "css", "javascript", "typescript", "tsx", "svelte",
    -- Docs
    "markdown", "markdown_inline", "regex",
    -- Languages Dreams of Code uses in videos
    "go", "gomod", "gosum", "gotmpl", "templ",
    "rust",
    "python",
    "c", "cpp",
  },
})

-- Auto-start highlighting for any buffer whose filetype has a parser, and
-- wire treesitter-backed folds per-window. We honor the bigfile/mediumfile
-- flags set by config/autocmds.lua: bigfiles get nothing, mediumfiles keep
-- highlights but use manual folds (treesitter's foldexpr is the slow part on
-- long buffers — it re-parses the tree on every redraw).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("dream_treesitter_start", { clear = true }),
  callback = function(args)
    if vim.b[args.buf].bigfile then return end
    pcall(vim.treesitter.start, args.buf)
    if not vim.b[args.buf].mediumfile then
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
    end
  end,
})

vim.o.foldlevel = 99  -- start with all folds open

-- Auto-close HTML/JSX/Svelte tags when typing </
require("nvim-ts-autotag").setup({
  opts = {
    enable_close          = true,
    enable_rename         = true,
    enable_close_on_slash = false,
  },
})

-- ---------------------------------------------------------------------------
-- treesitter-context — sticky function/class header pinned at top of window
-- as you scroll inside a long body. Defaults are sensible; cap at 3 lines so
-- it never eats more than a small slice of the viewport.
-- ---------------------------------------------------------------------------
require("treesitter-context").setup({
  enable            = true,
  max_lines         = 3,
  min_window_height = 20,
  trim_scope        = "outer",
})

-- ---------------------------------------------------------------------------
-- treesitter-textobjects (main branch API). On the new API there is no
-- queries-via-configs registration — you call select/move helpers directly
-- with `@capture.kind` queries from the textobjects query files.
-- ---------------------------------------------------------------------------
require("nvim-treesitter-textobjects").setup({
  select = { lookahead = true },
  move   = { set_jumps = true },
})

local select_to = require("nvim-treesitter-textobjects.select").select_textobject
local move      = require("nvim-treesitter-textobjects.move")

-- Visual / operator-pending selection: `vaf`, `dif`, `cic`, etc.
vim.keymap.set({ "x", "o" }, "af", function() select_to("@function.outer",  "textobjects") end, { desc = "a function" })
vim.keymap.set({ "x", "o" }, "if", function() select_to("@function.inner",  "textobjects") end, { desc = "inner function" })
vim.keymap.set({ "x", "o" }, "ac", function() select_to("@class.outer",     "textobjects") end, { desc = "a class" })
vim.keymap.set({ "x", "o" }, "ic", function() select_to("@class.inner",     "textobjects") end, { desc = "inner class" })
vim.keymap.set({ "x", "o" }, "aa", function() select_to("@parameter.outer", "textobjects") end, { desc = "a parameter" })
vim.keymap.set({ "x", "o" }, "ia", function() select_to("@parameter.inner", "textobjects") end, { desc = "inner parameter" })

-- Movement. ]c / [c are deliberately skipped — gitsigns owns those for hunks.
vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer",      "textobjects") end, { desc = "Next function start" })
vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer", "textobjects") end, { desc = "Prev function start" })
vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer",        "textobjects") end, { desc = "Next function end"   })
vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer",   "textobjects") end, { desc = "Prev function end"   })
vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.inner",     "textobjects") end, { desc = "Next parameter"     })
vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.inner","textobjects") end, { desc = "Prev parameter"     })
