Ice = {}

require "core.init"
require "plugins.init"

-- Load user configuration files
local config_root = string.gsub(vim.fn.stdpath "config", "\\", "/")
if not vim.api.nvim_get_runtime_file("lua/custom/", false)[1] then
    os.execute("mkdir \"" .. config_root .. "/lua/custom\"")
end

local custom_path = config_root .. "/lua/custom/init.lua"
local custom_init_file = io.open(custom_path, "r")
if custom_init_file ~= nil then
    custom_init_file:close()
    require "custom.init"
end

-- Define keymap
local keymap = Ice.keymap.general
require("core.utils").group_map(keymap)

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
    -- Load plugins
    local config = {}
    for _, plugin in pairs(Ice.plugins) do
        config[#config + 1] = plugin
    end
    require("lazy").setup(config)

    require("core.utils").group_map(Ice.keymap.plugins)

    -- Define colorscheme
    if not Ice.colorscheme then
        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
        local colorscheme_cache_file = io.open(colorscheme_cache, "r")
        if colorscheme_cache_file ~= nil then
            local colorscheme = colorscheme_cache_file:read "*a"
            colorscheme_cache_file:close()
            Ice.colorscheme = Ice.colorschemes[colorscheme]
        else
            Ice.colorscheme = Ice.colorschemes["tokyonight"]
        end
    end

    require("plugins.utils").colorscheme(Ice.colorscheme)
end
