vim.pack.add({
	{ src = "https://github.com/nvim-telescope/telescope.nvim", version = "0.1.x" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter", version = "main" },
	{ src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects", version = "main" },
	{ src = "https://github.com/saghen/blink.cmp", version = vim.version.range("1") },
	"https://github.com/akinsho/bufferline.nvim",
	"https://github.com/akinsho/toggleterm.nvim",
	"https://github.com/b0o/schemastore.nvim", -- JSON/YAML schemas
	"https://github.com/Bekaboo/dropbar.nvim", -- breadcrumbs winbar (LunarVim's navic, modernized)
	"https://github.com/brenoprata10/nvim-highlight-colors",
	"https://github.com/catppuccin/nvim",
	"https://github.com/christoomey/vim-tmux-navigator",
	"https://github.com/folke/noice.nvim",
	"https://github.com/folke/todo-comments.nvim",
	"https://github.com/folke/trouble.nvim",
	"https://github.com/folke/which-key.nvim",
	"https://github.com/github/copilot.vim",
	"https://github.com/grapp-dev/nui-components.nvim",
	"https://github.com/iamcco/markdown-preview.nvim",
	"https://github.com/ibhagwan/fzf-lua",
	"https://github.com/junegunn/fzf.vim",
	"https://github.com/kylechui/nvim-surround",
	"https://github.com/lewis6991/gitsigns.nvim",
	"https://github.com/lukas-reineke/indent-blankline.nvim",
	"https://github.com/MagicDuck/grug-far.nvim",
	"https://github.com/mason-org/mason.nvim",
	"https://github.com/mbbill/undotree",
	"https://github.com/MunifTanjim/nui.nvim",
	"https://github.com/neovim/nvim-lspconfig",
	"https://github.com/neovim-treesitter/treesitter-parser-registry",
	"https://github.com/nvim-lualine/lualine.nvim",
	"https://github.com/nvim-lua/plenary.nvim",
	"https://github.com/nvim-telescope/telescope-fzf-native.nvim",
	"https://github.com/nvim-tree/nvim-tree.lua",
	"https://github.com/nvim-tree/nvim-web-devicons",
	"https://github.com/nvim-treesitter/nvim-treesitter-context",
	"https://github.com/pmizio/typescript-tools.nvim",
	"https://github.com/rafamadriz/friendly-snippets",
	"https://github.com/rcarriga/nvim-notify",
	"https://github.com/stevearc/aerial.nvim",
	"https://github.com/stevearc/conform.nvim",
	"https://github.com/uga-rosa/ccc.nvim",
	"https://github.com/windwp/nvim-autopairs",
	"https://github.com/windwp/nvim-ts-autotag",
	"https://github.com/vifm/vifm.vim.git",
	"https://github.com/nvimdev/lspsaga.nvim.git",
})
local function safe_require(mod)
	local ok, err = pcall(require, "plugins." .. mod)
	if not ok then
		vim.notify(("Failed loading plugins.%s: %s"):format(mod, err), vim.log.levels.ERROR)
	end
end

safe_require("colorscheme") -- FIRST
safe_require("treesitter")
safe_require("telescope")
safe_require("completion") -- blink.cmp — before LSP
safe_require("lsp") -- uses blink.cmp capabilities
safe_require("tree")
safe_require("git")
safe_require("editor")
safe_require("bufferline")
safe_require("dropbar")
safe_require("highlight_colors")
safe_require("grug_far")
safe_require("misc")
safe_require("toggleterm")
safe_require("bufferline")
safe_require("ui")
safe_require("noice")
safe_require("h_color")
safe_require("treesitter-textobjects")
safe_require("treesitter")
safe_require("fzf-lua")
safe_require("confor")
safe_require("tscript")
