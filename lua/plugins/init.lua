local plugins = {}

local plugin_config = require("settings").plugin
local config = plugin_config.config
local keymap = plugin_config.keymap
local lazy_config = plugin_config.lazy
local pretty_name = plugin_config.list

local function load(name)
    local plugin_full_name = pretty_name[name]

    if not plugin_full_name then
        vim.notify("[In lua/plugins/init.lua] Plugin not found: " .. name)
        return
    elseif plugin_full_name == "" then
        return
    else
        local plugin

        if lazy_config[name] then
            plugin = lazy_config[name]
        else
            plugin = {}
        end

        table.insert(plugin, 1, plugin_full_name)

        local config_func = function(LazyPlugin, opts)
            if config[name] then
                config[name](LazyPlugin, opts)
            end

            if keymap[name] then
                require("core.utils").map_group(keymap[name])
            end
        end

        plugin.config = config_func
        table.insert(plugins, plugin)
    end
end

for key, _ in pairs(pretty_name) do
    load(key)
end

require("lazy").setup(plugins)
