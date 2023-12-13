require "core.init"
require "plugins.init"
require "lsp.init"

-- Define colorscheme
local colorscheme = vim.g.user_colorscheme
require("core.utils").colorscheme(colorscheme)

-- Define keymap
require("core.utils").map_group(require("settings").keymap)
