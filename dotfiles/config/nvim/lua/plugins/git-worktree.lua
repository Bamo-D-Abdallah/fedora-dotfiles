return {
    "ThePrimeagen/git-worktree.nvim",
    config = function()
        -- ---------- Setup ----------
        require("git-worktree").setup({
            change_directory_command = "tcd",
            update_on_change = true,
            update_on_change_command = "e .",
            clearjumps_on_change = true,
            autopush = false,
        })

        -- ---------- Helpers ----------
        local function git_root()
            local r = vim.fn.systemlist("git rev-parse --show-toplevel")[1]
            return (r and r ~= "") and r or vim.fn.getcwd()
        end

        local function repo_name()
            return vim.fn.fnamemodify(git_root(), ":t")
        end

        local function default_worktree_path(branch)
            -- Suggest: ~/worktrees/<repo>/<branch>
            return vim.fn.expand("~/src/worktrees/") .. repo_name() .. "/" .. branch
        end

        local function ensure_parent_dir(path)
            -- Make sure parent directory exists (git makes leaf, not parents)
            local parent = vim.fn.fnamemodify(path, ":h")
            if vim.fn.isdirectory(parent) == 0 then
                vim.fn.mkdir(parent, "p")
            end
        end

        local function to_abs(path)
            if path == nil or path == "" then return git_root() end
            if path:sub(1, 1) == "~" then
                return vim.fn.expand(path)
            end
            if path:match("^/") then
                return path
            end
            return git_root() .. "/" .. path
        end

        local function normalize_branch(name)
            if not name or name == "" then return "" end
            name = name:gsub("^refs/heads/", "")
            name = name:gsub("^remotes/[^/]+/", "")
            return name
        end

        local function branch_exists_local(branch)
            branch = normalize_branch(branch)
            vim.fn.system({ "git", "show-ref", "--verify", "--quiet", "refs/heads/" .. branch })
            return vim.v.shell_error == 0
        end

        local function worktree_list()
            local lines = vim.fn.systemlist("git worktree list --porcelain")
            local items, cur = {}, nil
            for _, l in ipairs(lines) do
                if l:match("^worktree ") then
                    cur = { path = l:gsub("^worktree ", "") }
                    table.insert(items, cur)
                elseif cur and l:match("^branch ") then
                    cur.branch = normalize_branch(l:gsub("^branch ", ""))
                end
            end
            return items
        end

        -- ---------- Make cwd change stick (Oil-safe, absolute path) ----------
        local Worktree = require("git-worktree")
        Worktree.on_tree_change(function(op, meta)
            if op == Worktree.Operations.Switch then
                vim.schedule(function()
                    if vim.bo.filetype == "oil" then vim.cmd("enew") end
                    local abs = to_abs(meta.path)
                    vim.cmd("tcd " .. vim.fn.fnameescape(abs))
                    pcall(function() require("oil").open(abs) end)
                    print("TAB cwd -> " .. vim.fn.getcwd())
                end)
            end
        end)

        -- ---------- Telescope extension (if available) ----------
        pcall(function() require("telescope").load_extension("git_worktree") end)

        -- ---------- Menus ----------
        local function delete_worktree_menu()
            local items = worktree_list()
            if #items == 0 then
                vim.notify("No worktrees to delete", vim.log.levels.INFO)
                return
            end
            vim.ui.select(items, {
                prompt = "Delete worktree",
                format_item = function(it) return string.format("%s  [%s]", it.path, it.branch or "?") end,
            }, function(choice)
                if not choice then return end
                require("git-worktree").delete_worktree(choice.path)
            end)
        end
        local function switch_worktree_menu()
            local ok, ext = pcall(function() return require("telescope").extensions.git_worktree end)
            if ok then
                return ext.git_worktrees() -- <CR> switch, <C-d> delete, <C-f> force toggle
            end
            local items = worktree_list()
            if #items == 0 then
                vim.notify("No worktrees found", vim.log.levels.INFO)
                return
            end
            vim.ui.select(items, {
                prompt = "Switch to worktree",
                format_item = function(it) return string.format("%s  [%s]", it.path, it.branch or "?") end,
            }, function(choice)
                if not choice then return end
                require("git-worktree").switch_worktree(choice.path)
            end)
        end

        -- Telescope-driven smart create with branch picker (+ Ctrl-n for new branch)
        local function create_worktree_with_branch_picker()
            local ok_b, builtin = pcall(require, "telescope.builtin")
            local ok_a, actions = pcall(function() return require("telescope.actions") end)
            local ok_s, action_state = pcall(function() return require("telescope.actions.state") end)
            if not (ok_b and ok_a and ok_s) then
                return vim.notify("Telescope not available", vim.log.levels.ERROR)
            end

            builtin.git_branches({
                prompt_title = "Select branch (or <C-n> for new)",
                attach_mappings = function(prompt_bufnr, map)
                    -- Enter: pick selected branch (local or remote)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)
                        local entry = action_state.get_selected_entry()
                        local branch = entry and normalize_branch(entry.value) or nil
                        if not branch or branch == "" then return end

                        local default_path = default_worktree_path(branch)
                        local path = vim.fn.input("Path for new worktree: ", default_path)
                        if path == "" then return end
                        path = to_abs(path)
                        ensure_parent_dir(path)

                        if branch_exists_local(branch) then
                            -- Existing local branch → no -b
                            local out = vim.fn.systemlist({ "git", "worktree", "add", path, branch })
                            if vim.v.shell_error ~= 0 then
                                vim.notify(table.concat(out, "\n"), vim.log.levels.ERROR)
                                return
                            end
                        else
                            -- New local branch (may track remote) → let plugin handle -b + upstream
                            local upstream = vim.fn.input("Upstream remote (default: origin): ", "origin")
                            if upstream == "" then upstream = "origin" end
                            require("git-worktree").create_worktree(path, branch, upstream)
                        end

                        require("git-worktree").switch_worktree(path)
                    end)

                    -- Ctrl-n: create a completely new branch
                    map("i", "<C-n>", function()
                        actions.close(prompt_bufnr)
                        local new_branch = vim.fn.input("New branch name: ")
                        if new_branch == "" then return end
                        local path = vim.fn.input("Path for new worktree: ", default_worktree_path(new_branch))
                        if path == "" then return end
                        path = to_abs(path)
                        ensure_parent_dir(path)
                        local upstream = vim.fn.input("Upstream remote (default: origin): ", "origin")
                        if upstream == "" then upstream = "origin" end
                        require("git-worktree").create_worktree(path, new_branch, upstream)
                        require("git-worktree").switch_worktree(path)
                    end)

                    return true
                end,
            })
        end

        -- ---------- Keymaps ----------
        local map = vim.keymap
        map.set("n", "<leader>ws", switch_worktree_menu, { desc = "Worktrees: switch / list" })
        map.set("n", "<leader>wc", create_worktree_with_branch_picker, { desc = "Worktrees: create (pick branch)" })
        map.set("n", "<leader>wd", delete_worktree_menu, { desc = "Worktrees: delete" })
        map.set("n", "<leader>wo", function()
            local ok, oil = pcall(require, "oil")
            if ok then oil.open(vim.fn.getcwd()) else vim.notify("oil.nvim not found", vim.log.levels.WARN) end
        end, { desc = "Oil at current worktree" })
    end,
}
