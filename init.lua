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
require("core.utils").group_map(Ice.keymap)

for filetype, config in pairs(Ice.ft) do
    require("core.utils").ft(filetype, config)
end

-- Only load plugins and colorscheme when --noplugin arg is not present
if not require("core.utils").noplugin then
    -- Load plugins
    require("lazy").setup(vim.tbl_values(Ice.plugins), Ice.lazy)

    vim.api.nvim_create_autocmd("User", {
        once = true,
        pattern = "IceAfter transparent",
        callback = function()
            local rtp_plugin_path = vim.opt.packpath:get()[1] .. "/plugin"
            local dir = vim.uv.fs_scandir(rtp_plugin_path)
            if dir ~= nil then
                while true do
                    local plugin = vim.uv.fs_scandir_next(dir)
                    if plugin == nil then
                        break
                    else
                        vim.cmd(string.format("source %s/%s", rtp_plugin_path, plugin))
                    end
                end
            end

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
        end,
    })
end

-- Prepend this to runtimepath last as it would be overridden by lazy otherwise
vim.opt.rtp:prepend(custom_path)
