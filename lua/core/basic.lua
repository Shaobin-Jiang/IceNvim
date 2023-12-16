local g = vim.g
local opt = vim.opt

g.encoding = "UTF-8"
opt.fileencoding = "utf-8"

local win_height = vim.fn.winheight(0)
opt.scrolloff = math.floor((win_height - 1) / 2)
opt.sidescrolloff = math.floor((win_height - 1) / 2)

opt.number = true
opt.relativenumber = true

opt.cursorline = true

opt.signcolumn = "yes"

opt.colorcolumn = "80"

opt.tabstop = 4
opt.softtabstop = 4
opt.shiftround = true
opt.expandtab = true

opt.shiftwidth = 4

opt.autoindent = true
opt.smartindent = true

-- Case insensitive searching when no upper case character is present
opt.ignorecase = true
opt.smartcase = true

-- Disable the ugly highlight during searches
opt.hlsearch = false

-- Search when typing
opt.incsearch = true

opt.cmdheight = 2

-- Auto load the file when modified externally
opt.autoread = true

opt.wrap = false

-- Use left / right arrow to move to the previous / next line when at the start
-- or end of a line.
-- See doc (:help 'whichwrap')
opt.whichwrap = "<,>,[,]"

-- Allow hiding modified buffer
opt.hidden = true

-- Add mouse support for all modes
opt.mouse = "a"

opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Smaller updatetime
opt.updatetime = 300

-- Time to wait for a sequence of key combination
opt.timeoutlen = 500

-- Split window from below and right
opt.splitbelow = true
opt.splitright = true

-- Enable auto complete menu and forbid automatically selecting the first option
g.completeopt = "menu,menuone,noinsert,noselect"
opt.wildmenu = true

opt.termguicolors = true

-- Avoid "hit-enter" prompts
-- Don't pass messages to |ins-completin menu|
opt.shortmess = vim.o.shortmess .. "c"

-- Maximum of 16 lines of prompt
opt.pumheight = 16

-- Always show tab line
opt.showtabline = 2

opt.showmode = false
-- opt.laststatus = 3

opt.nrformats = "bin,hex,alpha"

vim.cmd [[
    autocmd TermOpen * setlocal nonumber norelativenumber
]]
