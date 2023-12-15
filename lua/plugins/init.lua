require "default"
local config = {}
for _, plugin in pairs(require "plugins.config") do
    config[#config + 1] = plugin
end
require("lazy").setup(config)
require("core.utils").group_map(require "plugins.keymap")
