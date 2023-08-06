-- Set up lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system {
        "git",
        "clone",
        "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    }
end
vim.opt.rtp:prepend(lazypath)

require "core.init"
require "plugins.init"
require "lsp.init"

-- Define colorscheme
local colorscheme = require("settings").colorscheme
if type(colorscheme.setup) == "table" then
    require(colorscheme.name).setup(colorscheme.setup)
elseif type(colorscheme.setup) == "function" then
    colorscheme.setup()
end
vim.cmd("colorscheme " .. colorscheme.name)
vim.o.background = colorscheme.background

-- Define keymap
require("core.utils").map_group(require("settings").keymap)
