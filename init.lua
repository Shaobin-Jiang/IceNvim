Ice = {}

require "core.init"
require "plugins.init"

-- Define colorscheme
local colorscheme = Ice.colorscheme
require("plugins.utils").colorscheme(colorscheme)

-- Define keymap
local keymap = Ice.keymap.general
require("core.utils").group_map(keymap)

-- Load plugins
local config = {}
for _, plugin in pairs(Ice.plugins) do
    config[#config + 1] = plugin
end
require("lazy").setup(config)

require("core.utils").group_map(require "plugins.keymap")
