-- ============================================================================
--  plugins/tree.lua — nvim-tree (file explorer)
--
--  netrw is disabled in config/options.lua, which is what nvim-tree expects.
-- ============================================================================

require("nvim-tree").setup({
  sort_by = "case_sensitive",
  view = {
    width           = 32,
    side            = "left",
    preserve_window_proportions = true,
  },
  renderer = {
    group_empty   = true,
    highlight_git = true,
    indent_markers = { enable = true },
    icons = {
      show = { file = true, folder = true, folder_arrow = true, git = true },
    },
  },
  filters = {
    dotfiles = false,
    custom   = { "^\\.git$", "^node_modules$" },
  },
  git          = { enable = true, ignore = false },
  diagnostics  = { enable = true, show_on_dirs = true },
  update_focused_file = { enable = true, update_root = false },
  actions = {
    open_file = { quit_on_open = false, resize_window = true },
  },
})

local map = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc, silent = true }) end

map("<leader>e",  "<cmd>NvimTreeToggle<CR>",   "Toggle file [e]xplorer")
map("<leader>E",  "<cmd>NvimTreeFocus<CR>",    "Focus file [E]xplorer")
map("<leader>fe", "<cmd>NvimTreeFindFile<CR>", "Reveal current file in explorer")
