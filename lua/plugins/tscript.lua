local api = require("typescript-tools.api")
require("typescript-tools").setup({
    handlers = {
        ["textDocument/publishDiagnostics"] = api.filter_diagnostics({ 80006 }),
    },
    settings = {

        separate_diagnostic_server = true,

        publish_diagnostic_on = "insert_leave",

        expose_as_code_action = {},

        tsserver_path = nil,

        tsserver_plugins = {},

        tsserver_max_memory = "auto",

        tsserver_format_options = {
            allowIncompleteCompletions = false,
            allowRenameOfImportPath = false,
        },
        tsserver_file_preferences = {
            includeInlayParameterNameHints = "all",
            includeCompletionsForModuleExports = true,
            quotePreference = "auto",
        },

        tsserver_locale = "en",

        complete_function_calls = false,
        include_completions_with_insert_text = true,

        code_lens = "off",

        disable_member_code_lens = true,

        jsx_close_tag = {
            enable = false,
            filetypes = { "javascriptreact", "typescriptreact" },
        },
    },
})
