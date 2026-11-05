local function safe_require(mod)
    local ok, err = pcall(require, "plugins." .. mod)
    if not ok then
        vim.notify(("Failed loading plugins.%s: %s"):format(mod, err), vim.log.levels.ERROR)
    end
end

safe_require("editor")
safe_require("bufferline")
safe_require("ui")
safe_require("lsp")
safe_require("noice")
safe_require("completion")
safe_require("h_color")
safe_require("treesitter-textobjects")
safe_require("treesitter")
safe_require("fzf-lua")
safe_require("confor")
safe_require("aeria")
