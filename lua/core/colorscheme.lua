-- Predefined colorschemes
return {
    ["gruvbox-dark"] = {
        name = "gruvbox",
        setup = {
            italic = {
                strings = false,
                operators = false,
                comments = true,
            },
            contrast = "hard",
        },
        background = "dark",
        lualine_theme = "gruvbox",
    },
    ["gruvbox-light"] = {
        name = "gruvbox",
        setup = {
            italic = {
                strings = false,
                operators = false,
                comments = true,
            },
            contrast = "hard",
        },
        background = "light",
        lualine_theme = "gruvbox",
    },
    nord = {
        name = "nord",
        setup = function ()
            vim.g.nord_contrast = true
            vim.g.nord_borders = true
            vim.g.nord_cursorline_transparent = true
        end,
        background = "dark",
        lualine_theme = "nord",
    },
    tokyonight = {
        name = "tokyonight",
        setup = {
            style = "moon",
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
            },
        },
        background = "dark",
        lualine_theme = "tokyonight",
    },
}
