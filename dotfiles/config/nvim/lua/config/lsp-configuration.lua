---
-- LSP configuration
---
local lsp_zero = require('lsp-zero')

local lsp_attach = function(_, bufnr)
    local opts = {buffer = bufnr}


    vim.keymap.set('n', 'K', '<cmd>lua vim.lsp.buf.hover()<cr>', opts)
    vim.keymap.set('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<cr>', opts)
    vim.keymap.set('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<cr>', opts)
    vim.keymap.set('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<cr>', opts)
    vim.keymap.set('n', 'go', '<cmd>lua vim.lsp.buf.type_definition()<cr>', opts)
    vim.keymap.set('n', 'gr', '<cmd>lua vim.lsp.buf.references()<cr>', opts)
    vim.keymap.set('n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<cr>', opts)
    vim.keymap.set('n', '<leader>cr', '<cmd>lua vim.lsp.buf.rename()<cr>', opts)
    vim.keymap.set('n', '<leader>ca', '<cmd>lua vim.lsp.buf.code_action()<cr>', opts)
end

lsp_zero.extend_lspconfig({
    sign_text = true,
    lsp_attach = lsp_attach,
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
})

-- These are just examples. Replace them with the language
-- servers you have installed in your system
--require('lspconfig').gleam.setup({})
--require('lspconfig').rust_analyzer.setup({})

---
-- MASON
---
require('mason').setup({})
require('mason-lspconfig').setup({
    -- Replace the language servers listed here 
    -- with the ones you want to install
    ensure_installed = {'lua_ls', 'rust_analyzer'},
    handlers = {
        function(server_name)
            if server_name == "dartls" then return end
            require('lspconfig')[server_name].setup({})
        end,
    },
})



require('lspconfig').lua_ls.setup{
    settings = {
        Lua = {
            diagnostics = {
                globals = { 'vim' }
            }
        }
    }
}


---
-- Autocompletion setup
---
local luasnip = require("luasnip")
local cmp = require('cmp')
require("luasnip.loaders.from_vscode").lazy_load()


cmp.setup({
    window = {
        completion = cmp.config.window.bordered(),
        documentation = cmp.config.window.bordered(),
    },

    formatting = {
        fields = { "kind", "abbr", "menu" },
        format = function(entry, vim_item)
            local kind = require("lspkind").cmp_format({ mode = "symbol_text", maxwidth = 50 })(entry, vim_item)
            local strings = vim.split(kind.kind, "%s", { trimempty = true })
            kind.kind = " " .. (strings[1] or "") .. " "
            kind.menu = "    (" .. (strings[2] or "") .. ")"

            return kind
        end,
    },
    -- How should completion options be displayed to us?
    completion = {
        -- menu: display options in a menu
        -- menuone: automatically select the first option of the menu
        -- preview: automatically display the completion candiate as you navigate the menu
        -- noselect: prevent neovim from automatically selecting a completion option while navigating the menu
        competeopt = "menu,menuone,preview,noselect"
    },
    -- setup snippet support based on the active lsp and the current text of the file
    snippet = {
        expand = function(args)
            luasnip.lsp_expand(args.body)
        end
    },
    -- setup how we interact with completion menus and options
    mapping = cmp.mapping.preset.insert({
        -- previous suggestion
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        -- next suggestion
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-d>"] = cmp.mapping.scroll_docs(4),
        -- show completion suggestions
        ["<C-Space>"] = cmp.mapping.complete(),
        -- close completion window
        ["<C-e>"] = cmp.mapping.abort(),
        -- confirm completion, only when you explicitly selected an option
        ["<CR>"] = cmp.mapping.confirm({ select = false})
    }),
    -- Where and how should cmp rank and find completions
    -- Order matters, cmp will provide lsp suggestions above all else
    sources = cmp.config.sources({
        { name = 'nvim_lsp' },
        { name = 'luasnip' },
        { name = 'buffer' },
        { name = 'path' },
        { name = "vim-dadbod-completion", priority = 700 },
    })
})




---
-- Auto tags --
---

require('nvim-ts-autotag').setup({
  opts = {
    -- Defaults
    enable_close = true, -- Auto close tags
    enable_rename = true, -- Auto rename pairs of tags
    enable_close_on_slash = false -- Auto close on trailing </
  },
  -- Also override individual filetype configs, these take priority.
  -- Empty by default, useful if one of the "opts" global settings
  -- doesn't work well in a specific filetype
  per_filetype = {
  }
})



---
-- Auto pairs
---
local cmp_autopairs = require('nvim-autopairs.completion.cmp')
cmp.event:on(
  'confirm_done',
  cmp_autopairs.on_confirm_done()
)

local npairs = require("nvim-autopairs")
local Rule = require('nvim-autopairs.rule')

-- change default fast_wrap
npairs.setup({
    check_ts = true,
    ts_config = {
        lua = {'string'},-- it will not add a pair on that treesitter node
        javascript = {'template_string'},
        java = false,-- don't check treesitter on java
    },
    fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = [=[[%'%"%>%]%)%}%,]]=],
        end_key = '$',
        before_key = 'h',
        after_key = 'l',
        cursor_pos_before = true,
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        manual_position = true,
        highlight = 'Search',
        highlight_grey='Comment'
    },
})

local ts_conds = require('nvim-autopairs.ts-conds')


-- press % => %% only while inside a comment or string
npairs.add_rules({
  Rule("%", "%", "lua")
    :with_pair(ts_conds.is_ts_node({'string','comment'})),
  Rule("$", "$", "lua")
    :with_pair(ts_conds.is_not_ts_node({'function'}))
})


