local o = vim.o
vim.g.mapleader = ','

o.mouse = 'a'
o.undofile = true -- persistent undo across sessions
o.swapfile = false
o.updatetime = 200 -- faster CursorHold / diagnostics
o.timeoutlen = 300 -- snappier which-key popup
-- Ghostty advertises the kitty keyboard protocol, which Neovim 0.12 auto-enables.
-- The protocol disambiguates <Esc> from escape sequences without a wait, so we
-- can drop the terminal-key timeout from the default 50ms to 10ms — makes
-- mode-switching out of insert/terminal mode feel instant.
o.ttimeoutlen = 10
o.synmaxcol = 240 -- skip syntax highlighting past this column on long lines
o.confirm = true -- prompt to save instead of erroring on :q / :bdelete
o.jumpoptions = "stack,view" -- browser-style jumplist + restore view on jump
-- Second-stage diff alignment: re-aligns lines inside a changed block so
-- intra-line edits diff cleanly (gitsigns previews + :diffthis both benefit).
o.diffopt = vim.o.diffopt .. ",linematch:60"

-- --- UI --------------------------------------------------------------------
o.termguicolors = true


o.breakindent = true
o.breakindentopt = 'list:-1'
o.colorcolumn = '+1'
o.background = "dark"
o.clipboard = "unnamedplus"
o.cursorline = false
o.linebreak = true
o.list = true
o.number = false
o.pumheight = 10
o.ruler = true

o.showmode = true
o.signcolumn = 'yes'
o.splitbelow = true
o.splitkeep = 'screen'
o.splitright = true
o.wrap = true

o.cursorlineopt = 'screenline,number'


o.fillchars = 'eob: ,fold:╌'
o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '


o.foldlevel = 1
o.foldmethod = 'marker'
o.foldnestmax = 10



o.autoindent = true
o.expandtab = true
o.formatoptions = 'rqnl1j'
o.ignorecase = true
o.incsearch = true

o.shiftwidth = 2
o.smartcase = true
o.smartindent = true
o.spelloptions = 'camel'
o.tabstop = 2
o.virtualedit = 'block'







o.formatlistpat = [[^\s*[0-9\-\+\*]\+[\.\)]*\s\+]]
o.winborder = "rounded"


vim.diagnostic.config({
  virtual_text = { prefix = "●", spacing = 2 },
  severity_sort = true,
  update_in_insert = false,
  float = { border = "rounded", source = true },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = "",
      [vim.diagnostic.severity.WARN] = "",
      [vim.diagnostic.severity.INFO] = "",
      [vim.diagnostic.severity.HINT] = "󰌵"
    }
  }
})


for _, name in ipairs({
  "gzip",
  "zip",
  "zipPlugin",
  "tar",
  "tarPlugin",
  "getscript",
  "getscriptPlugin",
  "vimball",
  "vimballPlugin",
  "2html_plugin",
  "matchit",
  "logiPat",
  "rrhelper",
  "netrw",
  "netrwPlugin",
  "netrwSettings",
  "netrwFileHandlers"
}) do
  vim.g["loaded_" .. name] = 1
end



vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_python3_provider = 0



vim.g.markdown_recommended_style = 0

vim.filetype.add({

  extension = {

    env = "dotenv"
  },

  filename = {

    [".env"] = "dotenv",

    ["env"] = "dotenv"
  },

  pattern = {

    ["[jt]sconfig.*.json"] = "jsonc",

    ["%.env%.[%w_.-]+"] = "dotenv"
  }
})
