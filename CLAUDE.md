# CLAUDE.md

Guidance for Claude Code sessions in this repo. Read before making changes.

## What this repo is

A personal Neovim config — a port of [dreamsofcode-io/DreamNvim](https://github.com/dreamsofcode-io/DreamNvim) to **Neovim 0.12+** using the native **`vim.pack`** plugin manager (no lazy.nvim, no packer). It is not a distribution; it is a single-user config that happens to mirror DreamNvim's feature set.

This IS a git repo (history restarted June 2026). `nvim-pack-lock.json` is tracked deliberately — it pins plugin revisions; commit it when intentionally upgrading. `.claude/settings.local.json` is gitignored.

## Layout and load order

```
init.lua                  Entry — vim.loader, leader, Mason PATH, filetypes, then requires config/*.
lua/config/
  options.lua             vim.o + vim.diagnostic.config + disabled built-ins/providers (loads first)
  pack.lua                vim.pack.add() + per-plugin safe_require() in a fixed order
  keymaps.lua             Non-plugin keymaps only
  autocmds.lua            Non-plugin autocmds (yank-highlight, q-to-close, last-cursor, PackChanged, …)
lua/plugins/
  colorscheme.lua         catppuccin (MUST load first — others read its highlights)
  treesitter.lua          nvim-treesitter (main) + ts-autotag + treesitter-context + textobjects
  telescope.lua           telescope + fzf-native
  completion.lua          blink.cmp — vim.snippet for snippets (MUST load before lsp.lua)
  lsp.lua                 mason + vim.lsp.config/enable (pulls blink capabilities)
  copilot.lua             github/copilot.vim — <M-Tab> accepts (blink owns <Tab>)
  tree.lua                nvim-tree (file explorer)
  git.lua                 gitsigns (gutter + hunks)
  editor.lua              autopairs, surround, ibl, which-key (commenting is builtin gc)
  ui.lua                  lualine, todo-comments, trouble
  bufferline.lua          bufferline.nvim (top-of-screen buffer tabs)
  dropbar.lua             dropbar.nvim (breadcrumbs winbar: file > class > method)
  highlight_colors.lua    nvim-highlight-colors (color literals as swatches)
  grug_far.lua            grug-far (interactive find/replace UI)
  misc.lua                undotree, vim-tmux-navigator, conform (format-on-save)
  toggleterm.lua          toggleterm + Claude Code terminal (<leader>cc) + lazygit float (<leader>gg)
```

Plugin load order is set in `lua/config/pack.lua` and is *significant*:

* `colorscheme` first so every plugin that reads highlights sees them.
* `completion` before `lsp` because `lsp.lua` calls `require("blink.cmp").get_lsp_capabilities()`.
* Everything else is grouped by topic, not by dependency.

`safe_require()` in `pack.lua` pcall-wraps each module so one plugin's error doesn't halt the rest — errors surface as `vim.notify` messages. When diagnosing "plugin X silently did nothing", check `:messages` first.

## Project conventions

### File ownership
* **Each plugin file owns its own `setup()` and its own keymaps.** Don't move plugin keymaps to `config/keymaps.lua` — that file is for non-plugin bindings only.
* Adding a plugin means: (1) add source URL to `vim.pack.add()` in `config/pack.lua`, (2) add `safe_require("name")` in the correct slot, (3) create `lua/plugins/name.lua` with its setup + keymaps.
* Removing a plugin means: reverse all three of the above, **then** delete the install dir. `vim.pack` does not auto-prune — if `~/.local/share/nvim/site/pack/core/opt/<name>` still exists, the next launch "repairs" the lock file by re-adding it. Use `:lua vim.pack.del({ "<name>" })` (headless works too) to remove cleanly.

### Style
* Use `vim.o` everywhere, not `vim.opt`. In 0.12+ `vim.o` accepts the same types with less overhead.
* Use `vim.keymap.set` with a `desc` — which-key picks up the descriptions automatically.
* Prefer `vim.api.nvim_create_autocmd` with a named `augroup` (e.g. `dream_user`, `dream_lsp_attach`, `dream_treesitter_start`, `dream_term`) so reloads don't duplicate.
* Diagnostic signs go through `vim.diagnostic.config({ signs = { text = { ... } } })` — not legacy `sign_define`.
* LSP server configs go through `vim.lsp.config(name, {...})` + `vim.lsp.enable({...})` — **do not** use `require("lspconfig").server.setup()`. The `wanted` table in `lsp.lua` gates `vim.lsp.enable` by `vim.fn.executable()` so missing binaries never warn.
* Which-key group prefixes are registered in `editor.lua` (`<leader>{b,c,f,g,l,s,t,x}`). When you add a new `<leader>X*` namespace, add the group there too — otherwise the popup shows "+N keymaps" instead of a label.

### Don't add
* `mason-lspconfig` — deliberately dropped; `vim.lsp.enable` + Mason's PATH prepend (set in `init.lua`) replaces it.
* `nvim-cmp` and friends — replaced by `blink.cmp`.
* `Comment.nvim` — removed; Neovim 0.10+ ships `gc`/`gcc` natively.
* `LuaSnip` — removed; blink's default preset uses builtin `vim.snippet`. Only re-add if a user snippet library is needed.
* A lazy-loading layer — `vim.pack` is synchronous by design. Don't try to simulate `lazy.nvim`'s `event`/`cmd` triggers.

## Catppuccin integrations — the footgun

catppuccin accepts `integrations.<name> = true` as a shorthand, and its `mapper.lua` normalizes `true` → `{ enabled = true, ...defaults... }` — **but only during `M.compile()`**. When the hash-based compile cache is warm (every run after the first), normalization is skipped and the raw `true` leaks through. Any integration whose module indexes its options table (e.g. `O.integrations.lualine.<flavour>`, `O.integrations.blink_cmp.style`, `O.integrations.gitsigns.transparent`) then errors with `attempt to index a boolean value`.

**Rule:** for any integration whose group file in `~/.local/share/nvim/site/pack/core/opt/nvim/lua/catppuccin/groups/integrations/<name>.lua` reads sub-fields of its own options, use `{ enabled = true }` instead of `= true`. Safe integrations to set to `true`: `mason`, `treesitter`, `which_key`. Unsafe (need the table form): `lualine`, `blink_cmp`, `gitsigns`, `native_lsp`, `telescope`, `indent_blankline`.

The `plugins/ui.lua` lualine theme is wired as the string `"catppuccin-mocha"` (matches the `flavour` in `colorscheme.lua`). catppuccin ships `lualine/themes/catppuccin-{nvim,mocha,latte,frappe,macchiato}.lua` — there is **no** plain `catppuccin.lua`, so passing `theme = "catppuccin"` produces a "theme not found" warning. Keep the flavour string in sync if you change `colorscheme.lua`'s `flavour`.

## Treesitter gotchas (`main` branch)

This config tracks `nvim-treesitter`'s `main` branch, which has a different API from `master`:

* Option name is `ensure_install` (noun), not `ensure_installed`.
* Highlights **must be started manually** — a `FileType` autocmd in `plugins/treesitter.lua` calls `pcall(vim.treesitter.start, buf)` per buffer.
* Folds use `foldexpr = v:lua.vim.treesitter.foldexpr()` with `foldlevel = 99` (open by default), set in `plugins/treesitter.lua`.
* Parsers only install on *fresh* setup. To add parsers later: `:TSInstall <lang>` then `:TSUpdate`. The `PackChanged` autocmd in `config/autocmds.lua` notifies when nvim-treesitter itself updates.
* `treesitter-textobjects` also tracks `main`. The new API has no queries-via-configs registration — `select_textobject` and `move.goto_*` are called directly with `@capture.kind` queries (see the keymaps at the bottom of `plugins/treesitter.lua`).

If highlighting disappears in a known-good filetype, the parser is missing — `:TSInstall <lang>`.

**Downstream compat:** third-party plugins that import `nvim-treesitter.parsers` (expecting `ft_to_lang`) or `nvim-treesitter.configs` (expecting `is_enabled`) will error under `main` — those modules no longer export those functions. Telescope's buffer previewer hits this, which is why `plugins/telescope.lua` sets `preview = { treesitter = { enable = false } }` and lets telescope fall back to the built-in regex highlighter. If another plugin hits the same issue, prefer disabling its treesitter path over shimming the missing APIs (shimming `ft_to_lang` alone isn't enough — the whole `configs` module is gone).

## LSP gotchas (Neovim 0.12 native)

* `vim.lsp.document_color.enable(false)` is set in `lsp.lua` because Neovim 0.12 enables it by default, and `tailwindcss-language-server` paints color swatches behind every `bg-[...]`/`text-[...]`/`hover:bg-[...]` class. Re-enable with `:lua vim.lsp.document_color.enable(true)` if you want the decorations.
* Servers are gated by `vim.fn.executable()` against the binary names in the `wanted` table in `lsp.lua`. Adding a server: append `<lspconfig_name> = "<binary_name>"` and (if it needs settings) a matching `vim.lsp.config(name, {...})` block above. No `vim.lsp.enable` call needed — the loop at the bottom of `lsp.lua` picks it up.
* Default LSP keymaps from 0.12 (`gra`, `grn`, `grr`, `gri`, `grt`) are intentionally NOT overridden — they handle multi-client deduplication better than custom remaps. The `LspAttach` autocmd only adds `gd`, `gD`, `K`, `gl`, `[d`, `]d`.
* JSON/YAML schemas are pulled from `schemastore.nvim` — see the `jsonls`/`yamlls` config blocks.
* `svelte` server has an extra `BufWritePost *.js,*.ts` autocmd in its `on_attach` to push `$/onDidChangeTsOrJsFile` notifications — without that, `.svelte` diagnostics go stale when a related TS/JS file changes.

## Completion / Copilot coordination

`<Tab>` is owned by **blink.cmp** (cycles menu → snippet jump → fallback to literal Tab). Copilot's default `<Tab>` accept would fight that, so `plugins/copilot.lua` sets `copilot_no_tab_map = true` + `copilot_assume_mapped = true` and binds accept to `<M-Tab>` (Option+Tab on macOS, Zed-style). If you ever want Copilot to own `<Tab>` again, you need to undo both Copilot globals **and** drop `<Tab>` from blink's keymap table — half-measures break completion.

Snippet expansion is via Neovim's builtin `vim.snippet` (blink's default preset — no `snippets.preset` key set). No user snippet library is loaded — snippets only come from LSP server responses.

## toggleterm gotcha — `size` ignored on `Terminal:new()` for splits

`plugins/toggleterm.lua` exposes a dedicated Claude Code terminal at `<leader>cc`. toggleterm ignores the `size` field passed to `Terminal:new()` for splits — it only honors a size passed explicitly to `:toggle(size)` (or one persisted from a prior session, or the global config `size`). The plugin file works around this by computing the width on each toggle (`math.max(80, math.floor(vim.o.columns * 0.45))`) and passing it into `claude:toggle(width)`. If you add another `Terminal:new()` instance and the split size looks wrong, this is why — always pass the size at toggle time.

`<C-\>` toggles the floating "scratch" terminal from any mode. `<leader>t{t,h,v}` open extra ones in float/horizontal/vertical layouts. A `TermOpen` autocmd in the same file remaps `<Esc>` → `<C-\><C-n>` so you don't get stuck in terminal-insert mode.

## Testing changes

The fastest sanity check is a headless launch:

```bash
nvim --headless -c "qa" 2>&1 | head
```

A clean exit with no output means every `safe_require` succeeded. Anything printed is a load error — read the stack trace; the file path points at the offending plugin module.

For deeper checks:

```bash
# Messages after startup (catches deferred errors that don't surface at qa time)
nvim --headless -c "lua vim.defer_fn(function() print(vim.api.nvim_exec2('messages',{output=true}).output); vim.cmd('qa!') end, 300)" 2>&1

# Specific picker / module
nvim --headless -c "lua require('telescope.builtin').find_files()" -c "qa" 2>&1

# Health check for one subsystem
nvim --headless -c "checkhealth telescope" -c "qa!" 2>&1
```

Write a throwaway file to `/tmp/...` to capture `:checkhealth` output if you need the full report.

## Locations

* Plugin install dir: `~/.local/share/nvim/site/pack/core/opt/`
* Pack lock file: `nvim-pack-lock.json` in repo root (mutated by `vim.pack.update()`; auto-repaired on launch from the install dir)
* State: `~/.local/state/nvim/` (undo history lives here — `o.undofile = true`)
* Cache: `~/.cache/nvim/` (vim.loader bytecode cache)

When debugging a plugin, read the installed source directly under `~/.local/share/nvim/site/pack/core/opt/<plugin>/lua/...` — that's what's actually running, and it's more reliable than GitHub READMEs which can be ahead of the pinned version.

## Updating

```vim
:lua vim.pack.update()    " update every plugin; refreshes nvim-pack-lock.json
:lua vim.pack.del({"x"})  " uninstall plugin x (also removes from lock)
:TSUpdate                 " rebuild treesitter parsers after a treesitter bump
:Mason                    " update LSP servers via UI
```

`nvim-pack-lock.json` is what pins revisions — commit changes to it when intentionally upgrading.
