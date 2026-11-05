local o          = vim.o

-- --- Search -----------------------------------------------------------------
o.hlsearch       = true -- highlight matches; <Esc> in keymaps.lua clears them
o.incsearch      = true
o.ignorecase     = true
o.smartcase      = true -- case-sensitive when pattern contains a capital letter

-- --- Line numbers -----------------------------------------------------------
o.number         = false
o.relativenumber = false -- hybrid mode with `number`: current line shows its
-- absolute number, others show distance from cursor
o.signcolumn     = "yes" -- always show to avoid text jitter when diagnostics appear

-- --- Indentation ------------------------------------------------------------
o.tabstop        = 2 -- a tab character shows as 2 columns
o.softtabstop    = 2 -- <Tab> in insert mode inserts 2 spaces
o.shiftwidth     = 2 -- >> and << shift by 2
o.expandtab      = true
o.smartindent    = true
o.breakindent    = true -- wrapped lines keep their indentation

-- --- System ----------------------------------------------------------------
o.mouse          = "a"
o.clipboard      = "unnamedplus" -- system clipboard for y/p
o.undofile       = true          -- persistent undo across sessions
o.swapfile       = false
o.updatetime     = 200           -- faster CursorHold / diagnostics
o.timeoutlen     = 300           -- snappier which-key popup
-- Ghostty advertises the kitty keyboard protocol, which Neovim 0.12 auto-enables.
-- The protocol disambiguates <Esc> from escape sequences without a wait, so we
-- can drop the terminal-key timeout from the default 50ms to 10ms — makes
-- mode-switching out of insert/terminal mode feel instant.
o.ttimeoutlen    = 10
o.redrawtime     = 1500                              -- abandon slow syntax/regex highlight sooner (default 2000)
o.synmaxcol      = 240                               -- skip syntax highlighting past this column on long lines
o.confirm        = true                              -- prompt to save instead of erroring on :q / :bdelete
o.jumpoptions    = "stack,view"                      -- browser-style jumplist + restore view on jump
o.whichwrap      = vim.o.whichwrap .. ",<,>,[,],h,l" -- h/l + arrows wrap across line ends (LunarVim signature)
o.shortmess      = vim.o.shortmess .. "I"            -- skip the :intro splash screen
-- Second-stage diff alignment: re-aligns lines inside a changed block so
-- intra-line edits diff cleanly (gitsigns previews + :diffthis both benefit).
o.diffopt        = vim.o.diffopt .. ",linematch:60"

-- --- UI --------------------------------------------------------------------
o.termguicolors  = true
o.cursorline     = true
o.scrolloff      = 8
o.sidescrolloff  = 8
o.wrap           = true
o.smoothscroll   = true -- half-line scrolling on wrapped/folded buffers
o.splitright     = true
o.splitbelow     = true
o.showmode       = false -- lualine shows the mode
o.pumheight      = 10    -- cap completion popup height
o.completeopt    = "menuone,noselect,noinsert,fuzzy"
o.foldcolumn     = "1"   -- one-column fold gutter (treesitter folds set in plugins/treesitter.lua)
-- Tidier glyphs: blank end-of-buffer tildes, blank fold filler, simple
-- single-cell triangles for fold open/close (nerd-font glyphs trip
-- fillchars' "must be exactly one cell" check).
o.fillchars      = "eob: ,fold: ,foldopen:▾,foldclose:▸"
-- Default border for floating windows (LSP hover, signature help, etc.).
-- Floats that pass their own `border` keep it; this only fills in the rest.
-- Color comes from the `FloatBorder` highlight, set by catppuccin's native_lsp.
o.winborder      = "rounded"

-- Diagnostic signs via the modern API (no legacy sign_define calls)
vim.diagnostic.config({
  virtual_text     = { prefix = "●", spacing = 2 },
  severity_sort    = true,
  update_in_insert = false,
  float            = { border = "rounded", source = true },
  signs            = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN]  = "",
      [vim.diagnostic.severity.INFO]  = "",
      [vim.diagnostic.severity.HINT]  = "󰌵",
    },
  },
})

-- Disable a handful of unused built-in plugins for a marginally faster startup.
for _, name in ipairs({
  "gzip", "zip", "zipPlugin", "tar", "tarPlugin",
  "getscript", "getscriptPlugin", "vimball", "vimballPlugin",
  "2html_plugin", "matchit", "logiPat", "rrhelper",
  "netrw", "netrwPlugin", "netrwSettings", "netrwFileHandlers",
}) do
  vim.g["loaded_" .. name] = 1
end

-- Disable language providers we don't use. Silences the corresponding
-- :checkhealth warnings and skips the startup probe for each runtime.
vim.g.loaded_perl_provider    = 0
vim.g.loaded_ruby_provider    = 0
vim.g.loaded_node_provider    = 0
vim.g.loaded_python3_provider = 0
