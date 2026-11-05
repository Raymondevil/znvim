# DreamNvim → vim.pack port

A modernization of [dreamsofcode-io/DreamNvim](https://github.com/dreamsofcode-io/DreamNvim) for Neovim 0.12+ using the native `vim.pack` plugin manager instead of lazy.nvim.

## What's different from upstream

| Upstream (DreamNvim)                 | This port                                                    |
| ------------------------------------ | ------------------------------------------------------------ |
| lazy.nvim                            | `vim.pack` (built-in to Neovim 0.12)                         |
| `nvim-cmp` stack (cmp, cmp-nvim-lsp, cmp-buffer, cmp-path, lspkind, …) | `blink.cmp` (single plugin, batteries included)              |
| `mason-lspconfig`                    | Dropped. Uses `vim.lsp.config` + `vim.lsp.enable` directly.  |
| Servers enabled unconditionally      | Enabled only if their binary is on `$PATH` (no warnings)     |
| Single `lua/plugins/*.lua` per plugin with lazy specs | Still modular, but each file is its own `setup()` called in order |

Core identity preserved: **Catppuccin Mocha**, **space leader**, **telescope**, **.templ filetype**, Mason binary installer, conform for format-on-save.

## Installation guide

Follow these steps top to bottom on a fresh machine and everything in this
config will work — LSP, formatting, fuzzy finding, git UI, Copilot, the lot.

### Step 0 — Requirements at a glance

| Tool | Why it's needed | Required? |
| ---- | --------------- | --------- |
| **Neovim ≥ 0.12** | `vim.pack`, `vim.lsp.config/enable`, `winborder`, builtin `gc` | Required |
| **git** | `vim.pack` clones plugins over HTTPS | Required |
| **C compiler + make** | compiles treesitter parsers and telescope-fzf-native | Required |
| **tree-sitter CLI** | the treesitter `main` branch shells out to it for `:TSInstall` | Required |
| **ripgrep** (`rg`) | telescope live grep (`<leader>fg`, `<leader>sg`) | Required |
| **fd** | faster file listing for telescope `find_files` | Recommended |
| **curl / unzip** | blink.cmp's prebuilt Rust matcher, Mason package downloads | Required |
| **A Nerd Font** | all the icons (statusline, tree, completion menu, gutter) | Required for icons |
| **Node.js ≥ 20** | `github/copilot.vim` runs on node | Only for Copilot |
| **lazygit** | the `<leader>gg` floating git UI | Recommended |
| **tmux** | vim-tmux-navigator pane hopping (`<C-h/j/k/l>`) | Optional |
| **claude** CLI | the `<leader>cc` Claude Code terminal | Optional |

### Step 1 — Install the system packages

**macOS (Homebrew):**

```bash
xcode-select --install   # C compiler + make (skip if already installed)
brew install neovim git tree-sitter ripgrep fd lazygit node
brew install --cask font-jetbrains-mono-nerd-font
```

**Ubuntu / Debian** (apt's neovim is too old — use the official release):

```bash
sudo apt update && sudo apt install -y git build-essential ripgrep fd-find curl unzip nodejs npm
curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
sudo rm -rf /opt/nvim && sudo tar -C /opt -xzf nvim-linux-x86_64.tar.gz
echo 'export PATH="/opt/nvim-linux-x86_64/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
sudo npm install -g tree-sitter-cli
# lazygit: grab the latest release binary
LAZYGIT_VERSION=$(curl -s https://api.github.com/repos/jesseduffield/lazygit/releases/latest | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tgz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tgz lazygit && sudo install lazygit -D -t /usr/local/bin/
```

**Arch:**

```bash
sudo pacman -S --needed neovim git base-devel tree-sitter-cli ripgrep fd lazygit nodejs npm ttf-jetbrains-mono-nerd
```

Then set your terminal's font to **JetBrainsMono Nerd Font** (or any Nerd Font).
Verify the foundation before moving on:

```bash
nvim --version | head -1   # must print v0.12 or newer
rg --version && tree-sitter --version && cc --version
```

### Step 2 — Clone this config

```bash
# Back up any existing setup first
mv ~/.config/nvim       ~/.config/nvim.bak       2>/dev/null
mv ~/.local/share/nvim  ~/.local/share/nvim.bak  2>/dev/null
mv ~/.local/state/nvim  ~/.local/state/nvim.bak  2>/dev/null
mv ~/.cache/nvim        ~/.cache/nvim.bak        2>/dev/null

git clone https://github.com/julianruizsa/nvim ~/.config/nvim
```

### Step 3 — First launch

```bash
nvim
```

What happens automatically, in order:

1. `vim.pack` clones every plugin into `~/.local/share/nvim/site/pack/core/opt/`
   at the exact revisions pinned in `nvim-pack-lock.json`. Clone output streams
   by — this only happens once.
2. telescope-fzf-native compiles itself (`make` runs automatically).
3. nvim-treesitter installs and compiles all parsers from the `ensure_install`
   list (lua, go, rust, typescript, svelte, …) — expect a minute of compiler
   churn the first time.
4. blink.cmp downloads its prebuilt Rust fuzzy-matcher binary.

If a plugin errors, a notification appears but the editor keeps working —
check `:messages` for the stack trace. Quit and reopen once everything
finishes, then run `:checkhealth` to confirm the foundation is green.

### Step 4 — Install language servers and formatters (Mason)

The config enables a server **only if its binary is on `$PATH`**, so nothing
warns or breaks if you skip a language you don't use. Install what you need:

```vim
:MasonInstall lua-language-server typescript-language-server svelte-language-server
:MasonInstall json-lsp yaml-language-server html-lsp css-lsp tailwindcss-language-server
:MasonInstall bash-language-server pyright
:MasonInstall stylua prettierd shfmt
```

Or pick interactively from the `:Mason` UI (`i` installs, `X` removes).
Mason's bin dir is prepended to `$PATH` in `init.lua`, so new installs are
picked up after restarting the affected buffer's LSP (`<leader>lr`) or nvim.

Servers that come from your toolchain instead of Mason (also auto-detected):
`gopls` (`go install golang.org/x/tools/gopls@latest`), `rust-analyzer`
(`rustup component add rust-analyzer`), `clangd` (ships with LLVM), `templ`.

Formatters used by format-on-save (conform falls back to the LSP when one is
missing): `stylua` (lua), `prettierd`/`prettier` (web/json/yaml/markdown),
`shfmt` (shell), `ruff`/`black` (python), `gofmt`/`goimports` (go, ships with
the toolchain), `rustfmt` (rust, ships with rustup).

### Step 5 — Optional extras

* **Copilot** — run `:Copilot setup` once to authenticate (needs node).
  `<M-Tab>` accepts suggestions; `<leader>cp` toggles them.
* **Claude Code** — install the [claude CLI](https://claude.com/claude-code);
  `<leader>cc` then toggles a dedicated side terminal.
* **tmux** — add [vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)'s
  snippet to `~/.tmux.conf` so `<C-h/j/k/l>` hops across nvim splits and tmux
  panes seamlessly.

### Troubleshooting first-run issues

* **Boxes/garbage instead of icons** → your terminal font isn't a Nerd Font.
* **`:TSInstall` fails** → `tree-sitter` CLI or a C compiler is missing (step 1).
* **Live grep is empty** → `rg` is not on `$PATH`.
* **No completions/diagnostics for a language** → its server binary isn't
  installed; check `:Mason` and `:checkhealth vim.lsp`.
* **Adding a parser later** → `:TSInstall <lang>` (the `main` branch only
  auto-installs on the very first setup).

## Updating

```
:lua vim.pack.update()      " update every plugin
:TSUpdate                   " rebuild treesitter parsers
:Mason                      " update LSP servers via the UI
```

## Layout

```
init.lua                       entry point
lua/
├── config/
│   ├── options.lua            vim options (o.number, o.tabstop, …)
│   ├── pack.lua               vim.pack.add() + load plugin modules in order
│   ├── keymaps.lua            non-plugin keymaps
│   └── autocmds.lua           non-plugin autocmds
└── plugins/
    ├── colorscheme.lua        catppuccin
    ├── treesitter.lua         nvim-treesitter + nvim-ts-autotag
    ├── telescope.lua          telescope + fzf-native
    ├── completion.lua         blink.cmp (builtin vim.snippet for snippets)
    ├── lsp.lua                mason + vim.lsp.config/enable
    ├── copilot.lua            github/copilot.vim (<M-Tab> accepts)
    ├── tree.lua               nvim-tree (file explorer)
    ├── git.lua                gitsigns (hunks, blame, gutter)
    ├── editor.lua             autopairs, surround, ibl, which-key (gc is builtin)
    ├── ui.lua                 lualine, todo-comments, trouble
    ├── bufferline.lua         bufferline.nvim (buffer tabs along the top)
    ├── highlight_colors.lua   color literals as swatches
    ├── grug_far.lua           project-wide find & replace UI
    ├── toggleterm.lua         terminals: <C-\>, <leader>cc (claude), <leader>gg (lazygit)
    └── misc.lua               undotree, tmux-navigator, conform
```

## Keymap cheat sheet

Leader is `<space>`. Keymaps live in the plugin file they belong to — e.g. telescope bindings are in `lua/plugins/telescope.lua`, LSP bindings in `lua/plugins/lsp.lua`, and non-plugin bindings in `lua/config/keymaps.lua`.

### Telescope — `<leader>f*` (Find)

| Keys         | Action                                  | Source                   |
| ------------ | --------------------------------------- | ------------------------ |
| `<leader><leader>` | Find files (Omarchy/LazyVim style) | `plugins/telescope.lua`  |
| `<leader>ff` | Find files                              | `plugins/telescope.lua`  |
| `<leader>fg` | Live grep                               | `plugins/telescope.lua`  |
| `<leader>sg` | Live grep (Omarchy/LazyVim style)       | `plugins/telescope.lua`  |
| `<leader>fb` | Buffers                                 | `plugins/telescope.lua`  |
| `<leader>fh` | Help tags                               | `plugins/telescope.lua`  |
| `<leader>fk` | Keymaps                                 | `plugins/telescope.lua`  |
| `<leader>fr` | Recent files (oldfiles)                 | `plugins/telescope.lua`  |
| `<leader>fd` | Diagnostics                             | `plugins/telescope.lua`  |
| `<leader>fs` | LSP document symbols                    | `plugins/telescope.lua`  |
| `<leader>fc` | Colorscheme picker                      | `plugins/telescope.lua`  |
| `<leader>/`  | Fuzzy-find in current buffer            | `plugins/telescope.lua`  |

Inside a telescope prompt (insert mode): `<Esc>` closes, `<C-j>`/`<C-k>` move selection.

### File explorer — nvim-tree

| Keys         | Action                                   | Source              |
| ------------ | ---------------------------------------- | ------------------- |
| `<leader>e`  | Toggle file explorer                     | `plugins/tree.lua`  |
| `<leader>E`  | Focus file explorer                      | `plugins/tree.lua`  |
| `<leader>fe` | Reveal current file in explorer          | `plugins/tree.lua`  |

Inside the tree: `?` opens the full keymap help. Common defaults — `<CR>` open, `o` open, `a` create, `d` delete, `r` rename, `x` cut, `c` copy, `p` paste, `R` refresh, `H` toggle hidden files.

### Buffer tabs — bufferline.nvim

| Keys         | Action                                   | Source                    |
| ------------ | ---------------------------------------- | ------------------------- |
| `<S-l>`      | Next buffer                              | `config/keymaps.lua`      |
| `<S-h>`      | Previous buffer                          | `config/keymaps.lua`      |
| `<leader>bd` | Delete current buffer                    | `config/keymaps.lua`      |
| `<leader>bp` | Toggle pin on current buffer             | `plugins/bufferline.lua`  |
| `<leader>bc` | Close all other buffers                  | `plugins/bufferline.lua`  |
| `<leader>bh` | Close buffers to the left                | `plugins/bufferline.lua`  |
| `<leader>bl` | Close buffers to the right               | `plugins/bufferline.lua`  |
| `<leader>bP` | Pick a buffer by letter                  | `plugins/bufferline.lua`  |

### Git — `<leader>g*`

| Keys         | Action                                   | Source             |
| ------------ | ---------------------------------------- | ------------------ |
| `]c`         | Next git hunk                            | `plugins/git.lua`  |
| `[c`         | Previous git hunk                        | `plugins/git.lua`  |
| `<leader>gs` | Stage hunk (toggles; also visual mode)   | `plugins/git.lua`  |
| `<leader>gr` | Reset hunk (also visual mode)            | `plugins/git.lua`  |
| `<leader>gp` | Preview hunk inline                      | `plugins/git.lua`  |
| `<leader>gb` | Blame line                               | `plugins/git.lua`  |
| `<leader>gB` | Toggle inline blame                      | `plugins/git.lua`  |
| `<leader>gd` | Diff buffer                              | `plugins/git.lua`  |
| `<leader>gS` / `<leader>gR` | Stage / reset entire buffer | `plugins/git.lua`  |
| `<leader>gg` | LazyGit (floating window)                | `plugins/toggleterm.lua` |

### LSP (active only when a server is attached)

| Keys       | Action                                         | Source             |
| ---------- | ---------------------------------------------- | ------------------ |
| `gd`       | Goto definition                                | `plugins/lsp.lua`  |
| `gD`       | Goto declaration                               | `plugins/lsp.lua`  |
| `K`        | Hover docs                                     | `plugins/lsp.lua`  |
| `gl`       | Line diagnostics (float)                       | `plugins/lsp.lua`  |
| `[d` `]d`  | Previous / next diagnostic                     | `plugins/lsp.lua`  |
| `gra`      | Code action                                    | Neovim 0.12 native |
| `grn`      | Rename                                         | Neovim 0.12 native |
| `grr`      | References                                     | Neovim 0.12 native |
| `gri`      | Implementation                                 | Neovim 0.12 native |
| `grt`      | Type definition                                | Neovim 0.12 native |

### Diagnostics / Trouble — `<leader>x*`

| Keys         | Action                                   | Source            |
| ------------ | ---------------------------------------- | ----------------- |
| `<leader>xx` | All diagnostics (Trouble)                | `plugins/ui.lua`  |
| `<leader>xb` | Buffer diagnostics                       | `plugins/ui.lua`  |
| `<leader>xq` | Quickfix list                            | `plugins/ui.lua`  |
| `<leader>xl` | Location list                            | `plugins/ui.lua`  |

### Completion — blink.cmp (insert-mode only)

| Keys         | Action                                             | Source                  |
| ------------ | -------------------------------------------------- | ----------------------- |
| `<Tab>`      | Next suggestion (menu), or jump snippet forward    | `plugins/completion.lua` |
| `<S-Tab>`    | Previous suggestion (menu), or jump snippet back   | `plugins/completion.lua` |
| `<CR>`       | Accept highlighted suggestion                      | blink.cmp `enter` preset |
| `<C-space>`  | Show menu / show documentation                     | blink.cmp `enter` preset |
| `<Up>` `<Down>` | Select prev / next in menu                      | blink.cmp `enter` preset |
| `<C-n>` `<C-p>` | Select next / prev (fallback to mappings)       | blink.cmp `enter` preset |
| `<C-e>`      | Cancel / hide menu                                 | blink.cmp `enter` preset |
| `<C-b>` `<C-f>` | Scroll docs up / down                           | blink.cmp `enter` preset |
| `<C-k>`      | Toggle signature help                              | blink.cmp `enter` preset |

`<Tab>` / `<S-Tab>` fall through: menu selection if the menu is open, snippet jump if inside a snippet, else a literal Tab character.

### Format / misc

| Keys          | Action                                   | Source             |
| ------------- | ---------------------------------------- | ------------------ |
| `<leader>lf`  | Format buffer/selection (conform)        | `plugins/misc.lua` |
| `<leader>u`   | Toggle Undotree                          | `plugins/misc.lua` |
| `:FormatDisable[!]` | Disable autoformat globally (`!` = buffer-local) | `plugins/misc.lua` |
| `:FormatEnable`     | Re-enable autoformat                       | `plugins/misc.lua` |

### Editing / movement (non-plugin)

| Keys          | Action                                   | Source                |
| ------------- | ---------------------------------------- | --------------------- |
| `<Esc>`       | Clear search highlight                   | `config/keymaps.lua`  |
| `<C-Up/Down>` | Resize window vertically                 | `config/keymaps.lua`  |
| `<C-Left/Right>` | Resize window horizontally            | `config/keymaps.lua`  |
| `<S-h>` `<S-l>`  | Previous / next buffer                | `config/keymaps.lua`  |
| `<leader>bd`  | Delete buffer                            | `config/keymaps.lua`  |
| `<leader>w`   | Write                                    | `config/keymaps.lua`  |
| `<leader>q`   | Quit (confirm)                           | `config/keymaps.lua`  |
| `J`           | Join lines without moving cursor         | `config/keymaps.lua`  |
| `n` / `N`     | Next / previous match, centered          | `config/keymaps.lua`  |
| `<C-d>` `<C-u>` | Half-page scroll, centered             | `config/keymaps.lua`  |
| `<` `>` (visual) | Indent/outdent, keep selection        | `config/keymaps.lua`  |
| `J` `K` (visual) | Move selection down / up              | `config/keymaps.lua`  |
| `<leader>p` (visual) | Paste over selection, keep register | `config/keymaps.lua`  |
| `<leader>y`   | Yank to system clipboard                 | `config/keymaps.lua`  |
| `<leader>Y`   | Yank line to system clipboard            | `config/keymaps.lua`  |
| `q` (in help/qf/man/lspinfo/checkhealth) | Close window  | `config/autocmds.lua` |
| `gcc` / `gc<motion>` / `gc` (visual) | Toggle comment | Neovim builtin |

### Terminals — toggleterm

| Keys          | Action                                   | Source                   |
| ------------- | ---------------------------------------- | ------------------------ |
| `<C-\>`       | Toggle floating terminal (any mode)      | `plugins/toggleterm.lua` |
| `<leader>t`   | Vertical terminal                        | `plugins/toggleterm.lua` |
| `<leader>cc`  | Toggle Claude Code side terminal         | `plugins/toggleterm.lua` |
| `<leader>gg`  | Toggle LazyGit float                     | `plugins/toggleterm.lua` |
| `<Esc>` (in terminal) | Back to normal mode (except lazygit) | `plugins/toggleterm.lua` |

### Copilot (insert mode)

| Keys      | Action                | Source                |
| --------- | --------------------- | --------------------- |
| `<M-Tab>` | Accept suggestion     | `plugins/copilot.lua` |
| `<M-]>` / `<M-[>` | Next / prev suggestion | `plugins/copilot.lua` |
| `<C-]>`   | Dismiss               | `plugins/copilot.lua` |
| `<leader>cp` (normal) | Toggle Copilot on/off | `plugins/copilot.lua` |

