-- ============================================================================
--  plugins/toggleterm.lua — integrated terminal with proper toggling
--
--  <C-\> toggles a floating terminal from anywhere (normal, insert, or
--  terminal mode). <leader>t opens the vertical (left-side) terminal in one
--  keystroke — kept as the only <leader>t* binding so there's no timeoutlen
--  wait before it fires.
-- ============================================================================

require("toggleterm").setup({
	open_mapping = [[<C-\>]],
	direction = "float",
	float_opts = { border = "rounded" },
	start_in_insert = true,
	insert_mappings = true,
	terminal_mappings = true,
	shade_terminals = true,
	persist_size = true,
	persist_mode = true,
})

-- Apply to every terminal buffer (toggleterm's own and plain :terminal). Without
-- the <Esc> tnoremap, <Esc> is forwarded to the running shell, so the user
-- gets stuck inside terminal-insert mode.
vim.api.nvim_create_autocmd("TermOpen", {
	group = vim.api.nvim_create_augroup("dream_term", { clear = true }),
	pattern = "term://*",
	callback = function(ev)
		vim.keymap.set("t", "<Esc>", [[<C-\><C-n>]], { buffer = ev.buf, desc = "Exit terminal mode" })
		vim.opt_local.number = false
		vim.opt_local.signcolumn = "no"
	end,
})
vim.keymap.set("n", "<leader>t", "<cmd>ToggleTerm direction=vertical size=80<CR>", { desc = "[T]erminal (vertical)" })

-- ----------------------------------------------------------------------------
-- Dedicated Claude Code terminal — kept on its own Terminal:new() instance so
-- it never shares state with the <C-\> floating terminal used for the dev
-- server. <leader>cc toggles it; close_on_exit=false preserves scrollback if
-- claude exits, so a fresh toggle restarts it cleanly.
-- ----------------------------------------------------------------------------
-- toggleterm ignores the `size` field on Terminal:new() for splits — it only
-- honors a size passed explicitly to :toggle(size) (or persisted from a prior
-- session, or the global config.size). So we compute the width on each toggle
-- and pass it in. This also keeps the pane responsive to window resizes.
local Terminal = require("toggleterm.terminal").Terminal
local claude = Terminal:new({
	cmd = "claude",
	hidden = true,
	direction = "vertical",
	start_in_insert = true,
	close_on_exit = false,
})

local function claude_width()
	return math.max(80, math.floor(vim.o.columns * 0.45))
end

vim.keymap.set("n", "<leader>cc", function()
	claude:toggle(claude_width())
end, { desc = "[C]laude [c]ode toggle" })

-- ----------------------------------------------------------------------------
-- LazyGit in a full-screen float at <leader>gg — the Omarchy/LazyVim staple,
-- done with toggleterm instead of a dedicated lazygit plugin. Gated on the
-- binary so the binding never errors on a machine without lazygit.
-- ----------------------------------------------------------------------------
if vim.fn.executable("lazygit") == 1 then
	local lazygit = Terminal:new({
		cmd = "lazygit",
		hidden = true,
		direction = "float",
		float_opts = {
			border = "rounded",
			width = function() return math.floor(vim.o.columns * 0.95) end,
			height = function() return math.floor(vim.o.lines * 0.92) end,
		},
		-- lazygit owns <Esc> for its own navigation; drop the dream_term
		-- <Esc> → normal-mode remap inside this terminal only.
		on_open = function(term)
			vim.keymap.set("t", "<Esc>", "<Esc>", { buffer = term.bufnr, nowait = true })
		end,
	})
	vim.keymap.set("n", "<leader>gg", function()
		lazygit:toggle()
	end, { desc = "[G]it: lazy[g]it" })
end
