-- ============================================================================
--  config/autocmds.lua — non-plugin autocmds
-- ============================================================================

local augroup = vim.api.nvim_create_augroup("dream_user", { clear = true })

-- Brief highlight of yanked text so it's obvious what was copied.
vim.api.nvim_create_autocmd("TextYankPost", {
    group = augroup,
    callback = function()
        vim.hl.on_yank({ higroup = "IncSearch", timeout = 150 })
    end,
})

-- Rebalance splits when the terminal is resized.
vim.api.nvim_create_autocmd("VimResized", {
    group = augroup,
    command = "tabdo wincmd =",
})

-- Trim trailing whitespace on save (skip markdown where it's significant).
-- vim.api.nvim_create_autocmd("BufWritePre", {
--     group = augroup,
--     callback = function(args)
--         if not vim.bo[args.buf].modifiable then
--             return
--         end
--         if vim.bo[args.buf].filetype == "markdown" then
--             return
--         end
--         local view = vim.fn.winsaveview()
--         vim.cmd([[%s/\s\+$//e]])
--         vim.fn.winrestview(view)
--     end,
-- })

-- Press `q` to close common helper windows (help, qf, man, lspinfo, ...).
vim.api.nvim_create_autocmd("FileType", {
    group = augroup,
    pattern = { "help", "man", "qf", "lspinfo", "checkhealth", "notify" },
    callback = function(ev)
        vim.bo[ev.buf].buflisted = false
        vim.keymap.set("n", "q", "<cmd>close<CR>", { buffer = ev.buf, silent = true })
    end,
})

-- Return to the last cursor position when reopening a file.
vim.api.nvim_create_autocmd("BufReadPost", {
    group = augroup,
    callback = function(args)
        local mark = vim.api.nvim_buf_get_mark(args.buf, '"')
        local lcount = vim.api.nvim_buf_line_count(args.buf)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Notify when treesitter updates, so the user knows to run :TSUpdate.
vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup,
    callback = function(ev)
        if ev.data and ev.data.spec and ev.data.spec.name == "nvim-treesitter" then
            vim.notify("Treesitter updated — run :TSUpdate to rebuild parsers.", vim.log.levels.INFO)
        end
    end,
})

-- local BIGFILE_BYTES = 1024 * 1024
-- local BIGFILE_LINES = 5000
-- local MEDIUMFILE_BYTES = 512 * 1024
-- local MEDIUMFILE_LINES = 2000
--
-- vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
--     group = augroup,
--     callback = function(args)
--         local size = vim.fn.getfsize(args.file)
--         if size <= 0 then
--             return
--         end
--         if size > BIGFILE_BYTES then
--             vim.b[args.buf].bigfile = true
--         elseif size > MEDIUMFILE_BYTES then
--             vim.b[args.buf].mediumfile = true
--         end
--     end,
-- })
--
-- vim.api.nvim_create_autocmd("BufReadPost", {
--     group = augroup,
--     callback = function(args)
--         -- Lines may push a small/medium file into a higher tier.
--         if not vim.b[args.buf].bigfile then
--             local lines = vim.api.nvim_buf_line_count(args.buf)
--             if lines > BIGFILE_LINES then
--                 vim.b[args.buf].bigfile = true
--                 vim.b[args.buf].mediumfile = nil
--             elseif lines > MEDIUMFILE_LINES and not vim.b[args.buf].mediumfile then
--                 vim.b[args.buf].mediumfile = true
--             end
--         end
--
--         if vim.b[args.buf].bigfile then
--             -- Synchronous parts: buffer-local options that don't race other autocmds.
--             vim.opt_local.swapfile = false
--             vim.opt_local.undofile = false
--             vim.opt_local.foldmethod = "manual"
--             vim.b[args.buf].copilot_enabled = false
--
--             -- Deferred: treesitter + LSP + syntax cleanup. The built-in filetype-
--             -- detection autocmd runs ON BufReadPost and fires FileType *during*
--             -- BufReadPost — that means treesitter (and LSP) attach BEFORE this
--             -- callback gets a chance. Worse, a synchronous teardown here can be
--             -- undone by ts-autotag / treesitter-context / the syntax loader that
--             -- also run on FileType. vim.schedule defers to the next event-loop
--             -- tick, by which point the whole FileType chain has settled.
--             vim.schedule(function()
--                 if not vim.api.nvim_buf_is_valid(args.buf) then
--                     return
--                 end
--                 pcall(vim.treesitter.stop, args.buf)
--                 vim.bo[args.buf].syntax = ""
--                 for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
--                     vim.lsp.buf_detach_client(args.buf, client.id)
--                 end
--             end)
--         elseif vim.b[args.buf].mediumfile then
--             -- Keep highlights, but skip treesitter foldexpr (the slow part).
--             vim.opt_local.foldmethod = "manual"
--         end
--     end,
-- })
--
-- vim.api.nvim_create_autocmd({ "FileChangedShellPost" }, {
--     pattern = "*",
--     group = augroup,
--     callback = function()
--         vim.notify("File changed on disk. Buffer reloaded!", vim.log.levels.WARN, { title = "nvim-config" })
--     end,
-- })

local lsp_fmt_group = vim.api.nvim_create_augroup("LspFormattingGroup", {})
vim.api.nvim_create_autocmd("BufWritePost", {
    group = lsp_fmt_group,
    callback = function(ev)
        local efm = vim.lsp.get_clients({ name = "efm", bufnr = ev.buf })

        if vim.tbl_isempty(efm) then
            return
        end

        vim.lsp.buf.format({ name = "efm" })
    end,
})
