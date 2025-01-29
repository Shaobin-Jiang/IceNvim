Ice = {}

require "core.init"
require "plugins.init"

-- Load user configuration files
local config_root = string.gsub(vim.fn.stdpath "config", "\\", "/")
if not vim.api.nvim_get_runtime_file("lua/custom/", false)[1] then
    os.execute('mkdir "' .. config_root .. '/lua/custom"')
end

local custom_path = config_root .. "/lua/custom/"
if require("core.utils").file_exists(custom_path .. "init.lua") then
    require "custom.init"
end

-- Define keymap
local keymap = Ice.keymap.general
require("core.utils").group_map(keymap)

for filetype, config in pairs(Ice.ft) do
    require("core.utils").ft(filetype, config)
end

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
    -- Load plugins
    local config = {}
    for _, plugin in pairs(Ice.plugins) do
        config[#config + 1] = plugin
    end
    require("lazy").setup(config, Ice.lazy)

    require("core.utils").group_map(Ice.keymap.plugins)

    -- Define colorscheme
    if not Ice.colorscheme then
        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
        if require("core.utils").file_exists(colorscheme_cache) then
            local colorscheme_cache_file = io.open(colorscheme_cache, "r")
            ---@diagnostic disable: need-check-nil
            local colorscheme = colorscheme_cache_file:read "*a"
            colorscheme_cache_file:close()
            Ice.colorscheme = colorscheme
        else
            Ice.colorscheme = "tokyonight"
        end
    end

    require("plugins.utils").colorscheme(Ice.colorscheme)
end

-- Prepend this to runtimepath last as it would be overridden by lazy otherwise
if vim.uv.fs_scandir(custom_path) then
    vim.opt.rtp:prepend(custom_path)
end
