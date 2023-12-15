Ice = {}

require "core.init"
require "plugins.init"

-- Define colorscheme
local colorscheme = Ice.colorscheme
require("plugins.utils").colorscheme(colorscheme)

-- Define keymap
local keymap = Ice.keymap.general
require("core.utils").group_map(keymap)
