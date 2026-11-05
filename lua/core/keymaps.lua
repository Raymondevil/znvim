-- ============================================================================
--  config/keymaps.lua — keymaps that don't belong to a specific plugin
--
--  Plugin-owned keymaps live inside lua/plugins/<plugin>.lua so each plugin
--  is self-contained.
-- ============================================================================

local map = function(mode, lhs, rhs, desc)
	vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc })
end

-- --- Search highlight quick-clear -------------------------------------------
map("n", "<Esc>", "<cmd>nohlsearch<CR>", "Clear search highlight")

-- --- Window resize ----------------------------------------------------------
map("n", "<C-Up>", "<cmd>resize -2<CR>", "Resize window up")
map("n", "<C-Down>", "<cmd>resize +2<CR>", "Resize window down")
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", "Resize window left")
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", "Resize window right")

-- --- Window splits / layout -------------------------------------------------
-- LazyVim-style: `|` is visually a vertical bar, `-` is horizontal.
-- `<C-w>` pseudo-equivalents already work; these just surface in which-key.
map("n", "<leader>|", "<cmd>vsplit<CR>", "Split window vertically (right)")
map("n", "<leader>-", "<cmd>split<CR>", "Split window horizontally (below)")
map("n", "<leader>=", "<C-w>=", "Equalize window sizes")

-- --- Buffer navigation ------------------------------------------------------
-- <S-h>/<S-l> is the LazyVim/Omarchy convention. gt/gT also cycle buffers,
-- but follow the bufferline's visual order — see plugins/bufferline.lua.
map("n", "<S-l>", "<cmd>bnext<CR>", "Next buffer")
map("n", "<S-h>", "<cmd>bprevious<CR>", "Prev buffer")
map("n", "<leader>bd", "<cmd>bdelete<CR>", "Delete buffer")

-- --- Better defaults --------------------------------------------------------
map("n", "J", "mzJ`z", "Join lines without moving cursor")
map("n", "n", "nzzzv", "Next match, centered")
map("n", "N", "Nzzzv", "Prev match, centered")
map("n", "<C-d>", "<C-d>zz", "Half-page down, centered")
map("n", "<C-u>", "<C-u>zz", "Half-page up, centered")

-- --- Visual-mode stays in visual mode after indent --------------------------
map("v", "<", "<gv", "Outdent, keep selection")
map("v", ">", ">gv", "Indent, keep selection")

-- --- Move selection up/down -------------------------------------------------
map("x", "J", ":move '>+1<CR>gv=gv", "Move selection down")
map("x", "K", ":move '<-2<CR>gv=gv", "Move selection up")

-- --- Yank / paste niceties --------------------------------------------------
-- Replace selection with default register WITHOUT polluting the register.
map("x", "<leader>p", [["_dP]], "Paste over selection without yanking")
-- Yank to system clipboard explicitly (our options.lua already defaults to it,
-- but keep the explicit binding for when people toggle clipboard off).
map({ "n", "v" }, "<leader>y", [["+y]], "Yank to system clipboard")
map("n", "<leader>Y", [["+Y]], "Yank line to system clipboard")

-- --- Save / quit ------------------------------------------------------------
map("n", "<leader>w", "<cmd>w<CR>", "Write")
-- `confirm = true` in options.lua makes :bdelete prompt on unsaved changes,
-- so we don't need the explicit `:confirm` modifier here.
map("n", "<leader>q", "<cmd>bdelete<CR>", "Close buffer")
map("n", "<leader>zz", ":tabnew ", "nuevo")
map("n", "<leader>xx", ":tabnew ~/.config/nvim/lua/", "nuevo")
map("n", "<leader>vv", ":tabnew ~/.config/nvim/colors/", "nuevo")
map("n", "<leader>dd", ":tabnew ~/.config/nvim/init.lua<CR>", "nuevo") -- Cambiado a init.lua
map("n", "<leader>xc", ":tabnew ~/.local/share/nvim/", "nuevo")
map("n", "<leader>se", ":source $MYVIMRC<CR>", "nuevo")
map("n", "<leader>p", ":PlugInstall<CR>")
map("n", "<leader><space>", ":noh<CR>", "nuevo")

-- Buffers
map("n", "<Tab>$", ":bnext<CR>", "nuevo")
map("n", "<Tab>~", ":bprevious<CR>", "nuevo")

-- Terminal Splits
map("n", "<leader>$s", "<C-w>s<C-w>j:terminal<CR>:set nonumber<CR>a")
map("n", "<leader>$v", "<C-w>v<C-w>l:terminal<CR>:set nonumber<CR>a")
map("n", "<SPACE>a", ":FzfLua diagnostics_document<CR>", "nuevo")

-- Colores e Interfaz
map("n", "<A-w>", "24<C-w>+")
