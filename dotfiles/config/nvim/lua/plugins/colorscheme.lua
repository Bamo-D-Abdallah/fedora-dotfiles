return {
    {
        "catppuccin/nvim",
        name = "catppuccin",
        priority = 1000,
        opts = {
            flavour = "mocha",
            transparent_background = true,
        },
    },
    {
        "EdenEast/nightfox.nvim",
        opts = {
            palettes = {
                all = {
                    yellow = "#f77878",

                    sel0 = "#3e4a5b", -- Popup bg, visual selection bg
                    sel1 = "#4f6074", -- Popup sel bg, search bg
                    -- bg2 = "#ffffff",
                    -- bg3 = "#c7ddff",
                    -- bg4 = "#f77878",
                    -- fg0 ="#000000" ,
                    -- fg1 = "#ffffff",
                    -- fg2 = "#000000",
                    -- fg3 = "#d6d3d3",
                }
            },
            options = {
                transparent = true,
            }
        },
    },
    {
        "tiagovla/tokyodark.nvim",
        lazy = true,
        opts = {
            transparent_background = true
        }
    },
    {
        'diegoulloao/neofusion.nvim',
        lazy = true,
        opts = {
            terminal_colors = true, -- add neovim terminal colors
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                emphasis = true,
                comments = true,
                operators = false,
                folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = true,
        }
    },
    {
        'navarasu/onedark.nvim',
        configs = true,
        opts = {
            style = 'deep', -- Default theme style. Choose between 'dark', 'darker', 'cool', 'deep', 'warm', 'warmer' and 'light'
            transparent = false,  -- Show/hide background
            term_colors = true, -- Change terminal color as per the selected theme style
            ending_tildes = false, -- Show the end-of-buffer tildes. By default they are hidden
            cmp_itemkind_reverse = false, -- reverse item kind highlights in cmp menu

            -- toggle theme style ---
            toggle_style_key = nil, -- keybind to toggle theme style. Leave it nil to disable it, or set it to a string, for example "<leader>ts"
            toggle_style_list = {'dark', 'darker', 'cool', 'deep', 'warm', 'warmer', 'light'}, -- List of styles to toggle between

            -- Change code style ---
            -- Options are italic, bold, underline, none
            -- You can configure multiple style with comma separated, For e.g., keywords = 'italic,bold'
            code_style = {
                comments = 'italic',
                keywords = 'none',
                functions = 'none',
                strings = 'none',
                variables = 'none'
            },

            -- Lualine options --
            lualine = {
                transparent = false, -- lualine center bar transparency
            },

            -- Custom Highlights --
            colors = {}, -- Override default colors
            highlights = {}, -- Override highlight groups

            -- Plugins Config --
            diagnostics = {
                darker = true, -- darker colors for diagnostic
                undercurl = true,   -- use undercurl instead of underline for diagnostics
                background = true,    -- use background color for virtual text
            },
        }
    },
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        config = true,
        opts = {
            options = {
                -- Compiled file's destination location
                compile_path = vim.fn.stdpath('cache') .. '/github-theme',
                compile_file_suffix = '_compiled', -- Compiled file suffix
                hide_end_of_buffer = true, -- Hide the '~' character at the end of the buffer for a cleaner look
                hide_nc_statusline = true, -- Override the underline style for non-active statuslines
                transparent = true,       -- Disable setting bg (make neovim's background transparent)
                terminal_colors = true,    -- Set terminal colors (vim.g.terminal_color_*) used in `:terminal`
                dim_inactive = false,      -- Non focused panes set to alternative background
                module_default = true,     -- Default enable value for modules
                styles = {                 -- Style to be applied to different syntax groups
                    comments = 'NONE',       -- Value is any valid attr-list value `:help attr-list`
                    functions = 'NONE',
                    keywords = 'NONE',
                    variables = 'NONE',
                    conditionals = 'NONE',
                    constants = 'NONE',
                    numbers = 'NONE',
                    operators = 'NONE',
                    strings = 'NONE',
                    types = 'NONE',
                },
                inverse = {                -- Inverse highlight for different types
                    match_paren = false,
                    visual = false,
                    search = false,
                },
                darken = {                 -- Darken floating windows and sidebar-like windows
                    floats = true,
                    sidebars = {
                        enable = true,
                        list = {},             -- Apply dark background to specific windows
                    },
                },
                modules = {                -- List of various plugins and additional options
                    -- ...
                },
            },
            palettes = {},
            specs = {},
            groups = {},
        }



    }
}

