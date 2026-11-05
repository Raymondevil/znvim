-- ============================================================================
--  plugins/telescope.lua — fuzzy finder
-- ============================================================================

local actions   = require("telescope.actions")
local telescope = require("telescope")

telescope.setup({
  defaults = {
    prompt_prefix        = "  ",
    selection_caret      = " ",
    -- filename_first puts the basename up front, then the full directory path —
    -- crucial for SvelteKit-style routes where every file is `+page.svelte`.
    path_display         = { filename_first = { reverse_directories = false } },
    sorting_strategy     = "ascending",
    layout_strategy      = "horizontal",
    layout_config        = {
      prompt_position = "top",
      horizontal      = { width = 0.9, preview_width = 0.55 },
    },
    file_ignore_patterns = { "node_modules", "%.git/" },
    -- Disable telescope's treesitter preview path. It assumes the master-branch
    -- nvim-treesitter API (`nvim-treesitter.parsers.ft_to_lang`,
    -- `nvim-treesitter.configs.is_enabled`) which doesn't exist on the `main`
    -- branch we pin in config/pack.lua. Previews fall back to regex syntax
    -- highlighting, which is fine for a scratch buffer.
    preview = { treesitter = { enable = false } },
    mappings = {
      i = {
        ["<esc>"] = actions.close,
        ["<C-k>"] = actions.move_selection_previous,
        ["<C-j>"] = actions.move_selection_next,
      },
    },
  },
  pickers = {
    find_files = { previewer = false, layout_config = { width = 0.7 } },
    buffers    = { previewer = false, layout_config = { width = 0.7 } },
    oldfiles   = { previewer = false, layout_config = { width = 0.7 } },
  },
  extensions = {
    fzf = {
      fuzzy                   = true,
      override_generic_sorter = true,
      override_file_sorter    = true,
      case_mode               = "smart_case",
    },
  },
})

-- Load the native fzf sorter; compiles on first install via vim.pack.
pcall(telescope.load_extension, "fzf")

-- DreamNvim-flavored keymaps (all under <leader>f for "find")
local builtin = require("telescope.builtin")
local map     = function(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { desc = desc }) end

map("<leader>ff", builtin.find_files,  "[F]ind [F]iles")
map("<leader>fg", builtin.live_grep,   "[F]ind by [G]rep")
-- Omarchy/LazyVim muscle memory: Space-Space fuzzy-finds files, <leader>sg greps.
map("<leader><leader>", builtin.find_files, "Find files")
map("<leader>sg", builtin.live_grep, "[S]earch by [g]rep (live)")
map("<leader>fb", builtin.buffers,     "[F]ind [B]uffers")
map("<leader>fh", builtin.help_tags,   "[F]ind [H]elp")
map("<leader>fk", builtin.keymaps,     "[F]ind [K]eymaps")
map("<leader>fr", builtin.oldfiles,    "[F]ind [R]ecent files")
map("<leader>fd", builtin.diagnostics, "[F]ind [D]iagnostics")
map("<leader>fs", builtin.lsp_document_symbols, "[F]ind [S]ymbols")
map("<leader>fc", builtin.colorscheme, "[F]ind [C]olorscheme")
map("<leader>fm", builtin.marks,       "[F]ind [M]arks")
map("<leader>fw", builtin.grep_string, "[F]ind [W]ord under cursor")
map("<leader>f.", builtin.resume,      "[F]ind: resume last picker")
map("<leader>fF", function()
  -- Find files in the directory of the current buffer (instead of cwd) — handy
  -- for poking around a sibling component without having to type the path.
  builtin.find_files({ cwd = vim.fn.expand("%:p:h") })
end, "[F]ind [F]iles in current buffer's dir")
map("<leader>/",  builtin.current_buffer_fuzzy_find, "Search current buffer")

-- LunarVim search-group muscle memory: <leader>s* mirrors LunarVim's
-- telescope taxonomy. <leader>sr / <leader>sw / <leader>ss stay with
-- grug-far (plugins/grug_far.lua) — recent files remains at <leader>fr.
map("<leader>st", builtin.live_grep,   "[S]earch [t]ext (live grep)")
map("<leader>sf", builtin.find_files,  "[S]earch [f]iles")
map("<leader>sh", builtin.help_tags,   "[S]earch [h]elp")
map("<leader>sk", builtin.keymaps,     "[S]earch [k]eymaps")
map("<leader>sc", builtin.colorscheme, "[S]earch [c]olorscheme")
map("<leader>sl", builtin.resume,      "[S]earch: resume [l]ast")
