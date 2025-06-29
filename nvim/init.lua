require("config.lazy")
require("config.keymaps")
require("config.lsp-configuration")
require("current-theme")

vim.opt.nu = true
vim.opt.relativenumber = true

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.timeoutlen = 1000

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.loader.enable()   -- For caching plugins

--vim.opt.autoindent = true
vim.opt.smartindent = true

-- vim.opt.colorcolumn = "80" -- in case you wanted to see a limit of how long your code should be


vim.opt.spelllang = 'en_us'
vim.opt.spell = true

local signs = { Error = "󰅚 ", Warn = "󰀪 ", Hint = "󰌶 ", Info = " " }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
