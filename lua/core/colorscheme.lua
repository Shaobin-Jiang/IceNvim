-- Predefined colorschemes
return {
    ["gruvbox-dark"] = {
        name = "gruvbox",
        setup = {
            italic = {
                strings = true,
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
                strings = true,
                operators = false,
                comments = true,
            },
            contrast = "hard",
        },
        background = "light",
        lualine_theme = "gruvbox",
    },
    nightfox = {
        name = "nightfox",
        background = "dark",
        lualine_theme = "nightfox",
    },
    ["nightfox-carbon"] = {
        name = "carbonfox",
        background = "dark",
        lualine_theme = "carbonfox",
    },
    ["nightfox-day"] = {
        name = "dayfox",
        background = "light",
        lualine_theme = "dayfox",
    },
    ["nightfox-dawn"] = {
        name = "dawnfox",
        background = "light",
        lualine_theme = "dawnfox",
    },
    ["nightfox-dusk"] = {
        name = "duskfox",
        background = "dark",
        lualine_theme = "duskfox",
    },
    ["nightfox-nord"] = {
        name = "nordfox",
        background = "dark",
        lualine_theme = "nordfox",
    },
    ["nightfox-tera"] = {
        name = "terafox",
        background = "dark",
        lualine_theme = "terafox",
    },
    nord = {
        name = "nord",
        setup = function()
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
