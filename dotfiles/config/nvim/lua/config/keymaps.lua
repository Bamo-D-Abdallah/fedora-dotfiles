-- Oil --
local map = vim.keymap

map.set('n', '<C-n>', function() vim.cmd("Oil") end, { desc = 'Goes to the current directory of the file using Oil' })



-- Tmux --
map.set("n", "<C-f>", "<cmd>silent !tmux neww ~/.config/tmux/tmux-sessionizer<CR>")



-- Harpoon --
local harpoon = require("harpoon")

map.set("n", "<leader>ha", function() harpoon:list():add() end)
map.set("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
map.set("n", "<leader>1", function() harpoon:list():select(1) end)
map.set("n", "<leader>2", function() harpoon:list():select(2) end)
map.set("n", "<leader>3", function() harpoon:list():select(3) end)
map.set("n", "<leader>4", function() harpoon:list():select(4) end)


-- Telescope --
local builtin = require('telescope.builtin')


map.set('n', '<leader>ff', function() builtin.find_files() end, { desc = 'Telescope find files' })
map.set('n', '<leader>fg', function() builtin.live_grep() end, { desc = 'Telescope live grep' })
map.set('n', '<leader>fb', function() builtin.buffers() end, { desc = 'Telescope buffers' })
map.set('n', '<leader>fh', function() builtin.help_tags() end, { desc = 'Telescope help tags' })
map.set('n', '<leader>fr', function() builtin.git_files() end, { desc = 'Telescope find files based on git' })
map.set('n', '<leader>fd', function() builtin.diagnostics() end, { desc = 'Telescope find diagnostics' })

map.set("n", "<leader>ft", function() vim.cmd('TodoTelescope') end, { desc = "Shows the files in telescope with Todo comments" })



-- Undotree --
map.set('n', '<A-u>', vim.cmd.UndotreeToggle, { desc = "Toggles Undotree" })




---
-- LSP
---

-- uppercase `K`: on a variable, object, class, .., etc. Shows information about it such as its Datatype, return type for function names.
-- `gd`: 
-- `gD`:
-- `gi`
-- `go`
-- `gr`
-- `gs`
-- `<leader>ca`
-- '<leader>cf' to format code (uses none-ls)
map.set("n", "<leader>cf", vim.lsp.buf.format, { desc = "[C]ode [F]ormat" })




-- cmp
-- `CTRL-k` next item in the list
-- `CTRL-j` previous item in the list
-- `CTRL-b` scroll up the documentation
-- `CTRL-f` scroll down the documentation
-- `CTRL-Space` Show the list
-- `CTRL-e` abort the list


-- luasnip
local luasnip = require("luasnip")


map.set({ "i" }, "<C-K>", function() luasnip.expand() end, { silent = true })
map.set({ "i", "s" }, "<C-L>", function() luasnip.jump(1) end, { silent = true })
map.set({ "i", "s" }, "<C-J>", function() luasnip.jump(-1) end, { silent = true })

map.set({ "i", "s" }, "<C-E>", function()
    if luasnip.choice_active() then
        luasnip.change_choice(1)
    end
end, { silent = true })





-- Dadbod
map.set("n", "<A-p>", function() vim.cmd('DBUIToggle') end, { desc = "Opens the Dadbod UI (for database)" })




-- Neotest --
--[[
map.set("n", "<leader>tm", function() vim.cmd('Neotest summary') end, { desc = "Opens the test menu summary" })

map.set("n", "<leader>tc", function() vim.cmd('Neotest run') end, { desc = "Runs the current test under the curssor" })

map.set("n", "<leader>tr", function() require("neotest").run.run(vim.fn.expand("%")) end, { desc = "Runs the current test file" })

map.set("n", "<M-s>", function() vim.cmd('Neotest stop') end, { desc = "Stops the tests" })

map.set("n", "<leader>tp", function() vim.cmd('Neotest output') end, { desc = "Shows the output of the test" }) ]]




-- Comment --
-- Ctrl + / to comment both in normal mode and visual mode


-- TODO comments
-- Mark with:
-- -- TODO 
-- -- WARN, WARNING
-- -- NOTE, INFO
-- -- TEST, FAILED, PASSED


map.set("n", "<M-f>", function() vim.cmd('TodoLocList') end, { desc = "Shows the output of the test" })


--[[ -- Debugger --
local dap = require('dap')

map.set("n", "<M-d>", function() require('dapui').toggle() end, { desc = "Toggles the debugger UI" })
map.set('n', '<M-b>', function() dap.toggle_breakpoint() end, { desc = "toggles a breakpoint" })
map.set('n', '<M-B>', function() dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ') end, { desc = "toggles a breakpoint" }) ]]






-- Floating terminal --
--[[ map.set("n", "<M-t>", function() require('FTerm').toggle() end, { desc = "Shows the output of the test" })
map.set("t", "<M-t>", '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>') ]]


-- CsvView --
map.set("n", "<leader>csv", function()
    vim.cmd("CsvViewToggle")
    vim.api.nvim_set_hl(0, "CsvViewHeaderLine", { fg = "#ffffff", bg = "#3a3a3a", bold = true })
    vim.api.nvim_set_hl(0, "CsvViewStickyHeaderSeparator", { fg = "#aaaaaa", underline = true })
end, { desc = "Toggle CSV format "})


-- Nvim Git Worktree
map.set("n", "<leader>fw", function() require('telescope').extensions.git_worktrees() end, { desc = "Show telescope for git worktrees" })
