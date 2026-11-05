-- ============================================================================
--  plugins/editor.lua — editing quality-of-life
--
--  Contents:
--    * nvim-autopairs      — closes (), {}, [], "" in insert mode
--    * nvim-surround       — `ys<motion><char>`, `cs<old><new>`, `ds<char>`
--    * indent-blankline    — vertical guide for indent levels
--    * which-key           — popup help for multi-key sequences
--
--  Commenting (`gcc` / `gc<motion>` / visual `gc`) is Neovim's built-in
--  since 0.10 — Comment.nvim was removed as redundant.
-- ============================================================================

require("nvim-autopairs").setup({
	check_ts = true,
	disable_filetype = { "TelescopePrompt" },
})

--require("nvim-surround").setup()

-- require("ibl").setup({
--   indent = { char = "▏" },
-- scope runs treesitter queries on every redraw — the expensive half of ibl.
-- The plain indent guides are cheap; scope was already visually muted here
-- (start/end markers were hidden), so dropping it costs almost nothing.
--   scope  = { enabled = false },
-- })

require("which-key").setup({
	preset = "modern",
	win = { border = "rounded" },
})

-- Register top-level group descriptions so which-key labels them correctly.
-- Without these, multi-key prefixes show as "+N keymaps" instead of a name,
-- and the wrong label can hide what's actually under the prefix (the t/x
-- swap below was the original footgun: terminal lives at <leader>t, Trouble
-- lives at <leader>x).
--
-- Beyond the <leader> groups, this table also *documents* keymaps that are
-- defined elsewhere (plugin defaults, native 0.10+/0.12 builtins) so they
-- show up labelled in the which-key popup — entries with only a `desc` are
-- annotations, they don't create or change any mapping.
require("which-key").add({
	-- --- <leader> groups (the actual maps live in their plugin files) ---------
	{ "<leader>b", group = "Buffer (pin/close/pick)", icon = "" },
	{ "<leader>c", group = "Code AI (Claude/Copilot)", icon = "" },
	{ "<leader>f", group = "Find (telescope)", icon = "" },
	{ "<leader>g", group = "Git (hunks/blame/lazygit)", icon = "" },
	{ "<leader>l", group = "LSP (actions/format/Mason)", icon = "" },
	{ "<leader>s", group = "Search (telescope/grug-far)", icon = "" },
	{ "<leader>t", desc = "Terminal (vertical)", icon = "" },
	{ "<leader>x", group = "Trouble / Diagnostics", icon = "" },

	-- --- g-prefix: goto / native LSP / comment ---------------------------------
	-- gra/grn/grr/gri/grt are Neovim 0.12 builtin LSP defaults (deliberately
	-- not overridden — see CLAUDE.md). gd/gD/gl/K are bound on LspAttach.
	{ "gr", group = "LSP actions (native 0.12)" },
	{ "gra", desc = "LSP: code Action", mode = { "n", "x" } },
	{ "grn", desc = "LSP: reName symbol" },
	{ "grr", desc = "LSP: References" },
	{ "gri", desc = "LSP: Implementations" },
	{ "grt", desc = "LSP: Type definition" },
	{ "gc", group = "Comment (builtin)", mode = { "n", "x" } },
	{ "gcc", desc = "Comment current line" },
	{ "gt", desc = "Next buffer (right)" },
	{ "gT", desc = "Prev buffer (left)" },

	-- --- surround (nvim-surround) ----------------------------------------------
	{ "ys", desc = "Surround: add (ys<motion><char>)" },
	{ "cs", desc = "Surround: change (cs<old><new>)" },
	{ "ds", desc = "Surround: delete (ds<char>)" },
	{ "S", desc = "Surround selection", mode = "x" },

	-- --- bracket motions --------------------------------------------------------
	{ "[", group = "Prev (diagnostic/hunk/function…)" },
	{ "]", group = "Next (diagnostic/hunk/function…)" },

	-- --- window / tmux navigation (vim-tmux-navigator owns the maps) -----------
	{ "<C-h>", desc = "Go to left window/tmux pane" },
	{ "<C-j>", desc = "Go to lower window/tmux pane" },
	{ "<C-k>", desc = "Go to upper window/tmux pane" },
	{ "<C-l>", desc = "Go to right window/tmux pane" },

	-- --- buffer cycling ---------------------------------------------------------
	{ "<S-h>", desc = "Prev buffer" },
	{ "<S-l>", desc = "Next buffer" },
})
