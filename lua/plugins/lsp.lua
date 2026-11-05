-- ============================================================================
--  plugins/lsp.lua — LSP using Neovim 0.12's native vim.lsp API
--
--  Architecture:
--    * Mason     — installs language-server binaries on demand via :Mason UI.
--    * nvim-lspconfig — ships default configs (root markers, cmd args, filetypes)
--                     for ~200 servers; in 0.12 it exposes them through
--                     vim.lsp.config under the server's name.
--    * blink.cmp — we ask blink for its "capabilities" (what completion
--                  features it supports) and advertise those to every server.
--    * We deliberately SKIP mason-lspconfig. In 0.12 the automatic bridge is
--      no longer needed — vim.lsp.enable() + Mason's PATH prepend is enough.
-- ============================================================================

require("mason").setup({
	ui = {
		border = "rounded",
		icons = {
			package_installed = "√",
			package_pending = "×",
			package_uninstalled = "∑",
		},
	},
})

-- Merge blink's completion capabilities onto Neovim's defaults so every
-- server we enable knows we support snippets, resolveSupport, etc.
local capabilities = require("blink.cmp").get_lsp_capabilities()

-- A global default that applies to every server.
vim.lsp.config("*", { capabilities = capabilities })

-- Turn off the LSP `documentColor` decorations. Neovim 0.12 enables them by
-- default, which made tailwindcss-language-server paint color swatches behind
-- every `bg-[...]` / `text-[...]` / `hover:bg-[...]` class. Toggle back on with
--   :lua vim.lsp.document_color.enable(true)
vim.lsp.document_color.enable(false)

-- ---------------------------------------------------------------------------
-- Server-specific overrides
-- ---------------------------------------------------------------------------
vim.lsp.config("lua_ls", {
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				-- Restrict the workspace library to Neovim's own runtime instead of
				-- scanning every directory on the runtimepath. The full scan
				-- (`nvim_get_runtime_file("", true)`) is the canonical recipe but
				-- walks every plugin's tree — measurable on startup AND on each
				-- lua_ls re-index. Tradeoff: completion for plugin APIs (e.g.
				-- `require("telescope.builtin")`) is less complete; vim.* still works.
				library = { vim.env.VIMRUNTIME },
				checkThirdParty = false,
			},
			telemetry = { enable = false },
		},
	},
})

vim.lsp.config("jsonls", {
	settings = {
		json = {
			schemas = require("schemastore").json.schemas(),
			validate = { enable = true },
		},
	},
})

vim.lsp.config("yamlls", {
	settings = {
		yaml = {
			schemaStore = { enable = false, url = "" },
			schemas = require("schemastore").yaml.schemas(),
		},
	},
})

-- Svelte: the LSP needs a nudge when a related TS/JS file changes, otherwise
-- diagnostics in .svelte files go stale.
vim.lsp.config("svelte", {
	root_markers = { "svelte.config.js", "package.json", ".git" },
	on_attach = function(client)
		vim.api.nvim_create_autocmd("BufWritePost", {
			pattern = { "*.js", "*.ts" },
			callback = function(ctx)
				client:notify("$/onDidChangeTsOrJsFile", { uri = vim.uri_from_fname(ctx.match) })
			end,
		})
	end,
})

-- ---------------------------------------------------------------------------
-- Which servers to enable — filtered by executable presence
-- ---------------------------------------------------------------------------
-- Key  = lspconfig server name
-- Val  = binary name we probe via vim.fn.executable()
local wanted = {
	lua_ls = "lua-language-server",
	--emmylua_ls = "lua-language-server",
	pyright = "pyright-langserver",
	ts_ls = "typescript-language-server",
	svelte = "svelteserver",
	bashls = "bash-language-server",
	jsonls = "vscode-json-language-server",
	yamlls = "yaml-language-server",
	html = "vscode-html-language-server",
	cssls = "vscode-css-language-server",
	tailwindcss = "tailwindcss-language-server",
	rust_analyzer = "rust-analyzer",
	gopls = "gopls",
	templ = "templ", -- Go templ (matches DreamNvim's filetype)
	clangd = "clangd",
}

local to_enable = {}
for server, bin in pairs(wanted) do
	if vim.fn.executable(bin) == 1 then
		table.insert(to_enable, server)
	end
end
if #to_enable > 0 then
	vim.lsp.enable(to_enable)
end

-- ---------------------------------------------------------------------------
-- Global LSP keymaps (not buffer-scoped).
-- ---------------------------------------------------------------------------
-- Restart every LSP client attached to the current buffer. Stops the clients
-- with force=true, then re-fires FileType so vim.lsp.enable's attach autocmd
-- picks them back up. Using FileType (instead of `:edit`) preserves unsaved
-- changes and cursor position.
vim.keymap.set("n", "<leader>lr", function()
	local clients = vim.lsp.get_clients({ bufnr = 0 })
	if #clients == 0 then
		vim.notify("LSP: no clients attached to this buffer", vim.log.levels.WARN)
		return
	end
	local names = {}
	for _, c in ipairs(clients) do
		table.insert(names, c.name)
	end
	for _, c in ipairs(clients) do
		vim.lsp.stop_client(c.id, true)
	end
	vim.notify("LSP: restarting " .. table.concat(names, ", "))
	vim.defer_fn(function()
		vim.api.nvim_exec_autocmds("FileType", { buffer = 0 })
	end, 200)
end, { desc = "[L]SP [R]estart (current buffer's clients)" })

-- Convenience aliases for the common per-buffer LSP actions. These duplicate
-- the native `gra` / `grn` defaults but surface in which-key under <leader>l,
-- which is the discoverability win.
vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, { desc = "[L]SP code [a]ction" })
vim.keymap.set("n", "<leader>ln", vim.lsp.buf.rename, { desc = "[L]SP re[n]ame symbol" })

-- Toggle inlay hints. ts_ls / rust_analyzer / gopls all surface useful ones,
-- but they're noisy when reading code, so a quick toggle is handy.
vim.keymap.set("n", "<leader>lh", function()
	local enabled = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
	vim.lsp.inlay_hint.enable(not enabled, { bufnr = 0 })
	vim.notify("LSP inlay hints: " .. (not enabled and "on" or "off"))
end, { desc = "[L]SP toggle inlay [h]ints" })

vim.keymap.set("n", "<leader>li", "<cmd>checkhealth vim.lsp<CR>", { desc = "[L]SP [i]nfo (checkhealth)" })
vim.keymap.set("n", "<leader>lm", "<cmd>Mason<CR>", { desc = "[L]SP [M]ason" })

-- ---------------------------------------------------------------------------
-- LSP keymaps — bound per-buffer, only when a server attaches.
--
-- NOTE: Neovim 0.12 provides these as defaults (see `:h lsp-defaults`) and
-- they handle multi-client deduplication better than custom remaps:
--   gra — code action    grn — rename    grr — references
--   gri — implementation grt — type def
-- We intentionally don't override them.
-- ---------------------------------------------------------------------------
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("dream_lsp_attach", { clear = true }),
	callback = function(args)
		-- Don't run an LSP against bigfiles — the bigfile autocmd in
		-- config/autocmds.lua marks the buffer; we detach immediately if a
		-- server attached anyway (some attach before BufReadPost runs).
		-- vim.schedule defers the detach past the current event-loop iteration,
		-- otherwise it races the client's async init and the detach is a no-op.
		if vim.b[args.buf].bigfile then
			vim.schedule(function()
				vim.lsp.buf_detach_client(args.buf, args.data.client_id)
			end)
			return
		end

		local map = function(lhs, rhs, desc)
			vim.keymap.set("n", lhs, rhs, { buffer = args.buf, desc = desc, silent = true })
		end

		map("gd", vim.lsp.buf.definition, "LSP: Goto Definition")
		map("gD", vim.lsp.buf.declaration, "LSP: Goto Declaration")
		map("K", vim.lsp.buf.hover, "LSP: Hover")
		map("gl", vim.diagnostic.open_float, "LSP: Line diagnostics")

		map("[d", function()
			vim.diagnostic.jump({ count = -1, float = true })
		end, "Prev diagnostic")
		map("]d", function()
			vim.diagnostic.jump({ count = 1, float = true })
		end, "Next diagnostic")

		-- Reference highlighting (LunarVim shipped vim-illuminate for this; the
		-- native LSP request covers it with zero plugins). After `updatetime` ms
		-- idle, other occurrences of the symbol under the cursor light up via the
		-- LspReference{Text,Read,Write} groups — styled by catppuccin's
		-- native_lsp integration. Cleared again on any cursor movement.
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client:supports_method("textDocument/documentHighlight") then
			local hl_group = vim.api.nvim_create_augroup("dream_lsp_highlight", { clear = false })
			vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
				group = hl_group,
				buffer = args.buf,
				callback = vim.lsp.buf.document_highlight,
			})
			vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
				group = hl_group,
				buffer = args.buf,
				callback = vim.lsp.buf.clear_references,
			})
			vim.api.nvim_create_autocmd("LspDetach", {
				group = vim.api.nvim_create_augroup("dream_lsp_highlight_detach", { clear = true }),
				callback = function(ev)
					vim.lsp.buf.clear_references()
					vim.api.nvim_clear_autocmds({ group = "dream_lsp_highlight", buffer = ev.buf })
				end,
			})
		end
	end,
})
