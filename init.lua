Ice = {}

require "core.init"
require "plugins.init"

-- Define colorscheme
local colorscheme = vim.g.user_colorscheme
require("core.utils").colorscheme(colorscheme)

-- Define keymap
local keymap = require("settings").keymap
for desc, map in pairs(keymap) do
    local default_opt = { noremap = true, silent = true, nowait = true }
    local formatted_desc = string.gsub(desc, "_", " ")
    default_opt.desc = formatted_desc
    local m = vim.tbl_deep_extend("force", {nil, nil, nil, default_opt}, map)
    vim.keymap.set(m[1], m[2], m[3], m[4])
end
