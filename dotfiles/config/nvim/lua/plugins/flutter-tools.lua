return {
    'nvim-flutter/flutter-tools.nvim',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select
    },
    config = function()
        -- plugins/flutter.lua
        local flutter_tools = require("flutter-tools")

        flutter_tools.setup({
            flutter_path = vim.fn.expand("$FLUTTER_HOME/bin/flutter"),  -- or absolute path
            dart_sdk_path = vim.fn.expand("$FLUTTER_HOME/bin/cache/dart-sdk"),
            -- OR let it auto-detect from `flutter` in PATH if FLUTTER_HOME isn’t set
            lsp = {
                on_attach = function(client, bufnr)
                    -- your LSP keymaps, etc.
                end,
                capabilities = require("cmp_nvim_lsp").default_capabilities(),
                color = { enabled = true }, -- inlay colors for Colors.*
            },
            debugger = { enabled = false }, -- enable if you want codelldb flow
        })

        -- do NOT also call: require("lspconfig").dartls.setup(...)

    end,
}
