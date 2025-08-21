-- Predefined colorschemes
Ice.colorschemes = {
    ["cyberdream-dark"] = {
        name = "cyberdream",
        background = "dark",
        transparent = true,
        setup = {
            variant = "dark",
        },
    },
    ["cyberdream-light"] = {
        name = "cyberdream",
        background = "light",
        setup = {
            variant = "light",
        },
    },
    ["gruvbox-dark"] = {
        name = "gruvbox",
        transparent = true,
        setup = {
            italic = {
                strings = true,
                operators = false,
                comments = true,
            },
            contrast = "hard",
        },
        background = "dark",
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
    },
    ["kanagawa-wave"] = {
        name = "kanagawa-wave",
        transparent = true,
        background = "dark",
    },
    ["kanagawa-dragon"] = {
        name = "kanagawa-dragon",
        transparent = true,
        background = "dark",
    },
    ["kanagawa-lotus"] = {
        name = "kanagawa-lotus",
        background = "light",
    },
    miasma = {
        name = "miasma",
        background = "dark",
    },
    ["monet-dark"] = {
        name = "monet",
        transparent = true,
        setup = function()
            local palette = require "monet.palette"
            setmetatable(palette, { __index = palette.defaults })
        end,
        background = "dark",
    },
    ["monet-light"] = {
        name = "monet",
        setup = function()
            local palette = require "monet.palette"
            setmetatable(palette, { __index = palette.light_mode })
        end,
        background = "light",
    },
    nightfox = {
        name = "nightfox",
        transparent = true,
        background = "dark",
    },
    ["nightfox-carbon"] = {
        name = "carbonfox",
        transparent = true,
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
        transparent = true,
        background = "dark",
    },
    ["nightfox-nord"] = {
        name = "nordfox",
        transparent = true,
        background = "dark",
    },
    ["nightfox-tera"] = {
        name = "terafox",
        transparent = true,
        background = "dark",
    },
    tokyonight = {
        name = "tokyonight",
        background = "dark",
        setup = {
            style = "moon",
            styles = {
                comments = { italic = true },
                keywords = { italic = false },
            },
        },
    },
}
