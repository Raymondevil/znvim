vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle [U]ndotree" })

-- --- vim-tmux-navigator (seamless <C-h/j/k/l> across tmux + nvim) -----------
vim.g.tmux_navigator_no_mappings = 0 -- leave its defaults in place

-- --- conform.nvim (format-on-save) ------------------------------------------
local conform = require("conform")
conform.setup({
	formatters_by_ft = {
		lua = { "stylua" },
		python = { "ruff_format", "black", stop_after_first = true },
		go = { "gofmt", "goimports" },
		rust = { "rustfmt", lsp_format = "fallback" },
		javascript = { "prettierd", "prettier", stop_after_first = true },
		typescript = { "prettierd", "prettier", stop_after_first = true },
		javascriptreact = { "prettierd", "prettier", stop_after_first = true },
		typescriptreact = { "prettierd", "prettier", stop_after_first = true },
		html = { "prettierd", "prettier", stop_after_first = true },
		css = { "prettierd", "prettier", stop_after_first = true },
		json = { "prettierd", "prettier", stop_after_first = true },
		yaml = { "prettierd", "prettier", stop_after_first = true },
		markdown = { "prettierd", "prettier", stop_after_first = true },
		sh = { "shfmt" },
	},
	format_on_save = function(bufnr)
		-- Allow disabling per-buffer or globally via `vim.g.disable_autoformat`.
		if vim.g.disable_autoformat or vim.b[bufnr].disable_autoformat then
			return
		end
		-- Skip on bigfiles — formatters on multi-MB buffers stall the save.
		if vim.b[bufnr].bigfile then
			return
		end
		-- 200ms cap (was 500): if a formatter is cold or slow you find out fast,
		-- and conform falls through to LSP/none rather than blocking the save.
		return { timeout_ms = 200, lsp_format = "fallback" }
	end,
})

-- Toggle format-on-save on the fly.
vim.api.nvim_create_user_command("FormatDisable", function(args)
	if args.bang then
		vim.b.disable_autoformat = true
	else
		vim.g.disable_autoformat = true
	end
end, { desc = "Disable autoformat (use ! for buffer-local)", bang = true })

vim.api.nvim_create_user_command("FormatEnable", function()
	vim.b.disable_autoformat = false
	vim.g.disable_autoformat = false
end, { desc = "Re-enable autoformat" })

-- Manual format shortcut
vim.keymap.set({ "n", "v" }, "<leader>lf", function()
	conform.format({ async = true, lsp_format = "fallback" })
end, { desc = "[L]SP [f]ormat buffer/range" })
