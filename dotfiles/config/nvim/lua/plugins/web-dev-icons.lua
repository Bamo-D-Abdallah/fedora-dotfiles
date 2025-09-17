return {
    'nvim-tree/nvim-web-devicons',
    config = function()
        require('nvim-web-devicons').set_icon {
            js = {
                icon = "",  -- nf-dev-javascript_badge
                color = "#f7df1e",
                name = "Javascript"
            },
            ts = {
                icon = "󰛦",  -- nf-md-language_typescript (needs recent Nerd Font)
                color = "#3178c6",
                name = "Typescript"
            }
        }

    end
}
