-- Predefined colorschemes
return {
    ["ayu-light"] = {
        name = "ayu",
        setup = function()
            vim.g.ayucolor = "light"
        end,
        background = "light",
        lualine_theme = "ayu_light",
    },
    ["ayu-mirage"] = {
        name = "ayu",
        setup = function()
            vim.g.ayucolor = "mirage"
        end,
        background = "dark",
        lualine_theme = "ayu_mirage",
    },
    ["ayu-dark"] = {
        name = "ayu",
        setup = function()
            vim.g.ayucolor = "dark"
        end,
        background = "dark",
        lualine_theme = "ayu_dark",
    },
    ["github-dark"] = {
        name = "github_dark",
        background = "dark",
    },
    ["github-light"] = {
        name = "github_light",
        background = "light",
    },
    ["github-dark-dimmed"] = {
        name = "github_dark_dimmed",
        background = "dark",
    },
    ["github-dark-high-contrast"] = {
        name = "github_dark_high_contrast",
        background = "dark",
    },
    ["github-light-high-contrast"] = {
        name = "github_light_high_contrast",
        background = "light",
    },
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
    },
    ["nightfox-carbon"] = {
        name = "carbonfox",
        background = "dark",
    },
    ["nightfox-day"] = {
        name = "dayfox",
        background = "light",
    },
    ["nightfox-dawn"] = {
        name = "dawnfox",
        background = "light",
    },
    ["nightfox-dusk"] = {
        name = "duskfox",
        background = "dark",
    },
    ["nightfox-nord"] = {
        name = "nordfox",
        background = "dark",
        lualine_theme = "nord",
    },
    ["nightfox-tera"] = {
        name = "terafox",
        background = "dark",
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
    },
}
