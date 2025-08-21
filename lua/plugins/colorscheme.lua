-- Predefined colorschemes
Ice.colorschemes = {
    ["cyberdream-dark"] = {
        name = "cyberdream",
        background = "dark",
        setup = {
            variant = "dark",
            -- transparent = true,
        },
    },
    ["cyberdream-light"] = {
        name = "cyberdream",
        background = "light",
        setup = {
            variant = "light",
            -- transparent = true,
        },
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
        background = "dark",
    },
    ["kanagawa-dragon"] = {
        name = "kanagawa-dragon",
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
