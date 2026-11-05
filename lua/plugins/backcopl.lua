
require("blink.cmp").setup({
	keymap = {
		-- `enter` preset wires <CR> → accept. Then we override <Tab>/<S-Tab> so
		-- they cycle the completion menu when it's open, fall back to snippet
		-- jumps inside a snippet, and finally fall through to a literal Tab.
		preset = "enter",
		["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
		["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
	},
	appearance = {
		-- Switch to "normal" if your font is "Nerd Font" (not "Nerd Font Mono")
		nerd_font_variant = "mono",
	},
	completion = {
		accept = { auto_brackets = { enabled = true } },
		documentation = { auto_show = true, auto_show_delay_ms = 200 },
		ghost_text = { enabled = false },
		menu = {
			draw = {
				components = {
					-- customize the drawing of kind icons
					kind_icon = {
						text = function(ctx)
							-- default kind icon
							local icon = ctx.kind_icon
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item =
									require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr ~= "" then
									icon = color_item.abbr
								end
							end
							return icon .. ctx.icon_gap
						end,
						highlight = function(ctx)
							-- default highlight group
							local highlight = "BlinkCmpKind" .. ctx.kind
							-- if LSP source, check for color derived from documentation
							if ctx.item.source_name == "LSP" then
								local color_item =
									require("nvim-highlight-colors").format(ctx.item.documentation, { kind = ctx.kind })
								if color_item and color_item.abbr_hl_group then
									highlight = color_item.abbr_hl_group
								end
							end
							return highlight
						end,
					},
				},
				treesitter = { "lsp" }, -- highlight snippet bodies with treesitter
			},
		},
	},
	sources = {
		providers = {
			snippets = {
				opts = {
					friendly_snippets = true,
				},
			},
		},
		default = { "lsp", "path", "snippets", "buffer" },
	},
	-- Prefer the Rust matcher (~6x faster) and let blink download a prebuilt
	-- binary on first run. Falls back to the Lua matcher if the download fails
	-- or the platform isn't supported.
	fuzzy = {
		implementation = "prefer_rust_with_warning",
		prebuilt_binaries = { download = true },
	},
	signature = { enabled = true },
})
