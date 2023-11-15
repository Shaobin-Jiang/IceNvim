-- Use utf-8 encoding
vim.g.encoding = "UTF-8"
vim.o.fileencoding = "utf-8"

local win_height = vim.fn.winheight(0)
vim.o.scrolloff = math.floor((win_height - 1) / 2)
vim.o.sidescrolloff = math.floor((win_height - 1) / 2)

-- Relative line number
vim.wo.number = true
vim.wo.relativenumber = true

-- Highlight current line
vim.wo.cursorline = true

-- Show sign column
vim.wo.signcolumn = "yes"

-- Line prompting for lines that are too long
vim.wo.colorcolumn = "80"

-- Tab = 4 spaces
vim.o.tabstop = 4
vim.bo.tabstop = 4
vim.o.softtabstop = 4
vim.o.shiftround = true

-- Auto indent = 4 spaces
vim.o.shiftwidth = 4
vim.bo.shiftwidth = 4

-- Replace tab-created white space with real spaces
vim.o.expandtab = true
vim.bo.expandtab = true

-- Smart indents; new line aligns with the current
vim.o.autoindent = true
vim.bo.autoindent = true
vim.o.smartindent = true

-- Case insensitive searching when no upper case character is present
vim.o.ignorecase = true
vim.o.smartcase = true

-- Disable the ugly highlight during searches
vim.o.hlsearch = false

-- Search when typing
vim.o.incsearch = true

-- Set command line height to 2 for adequate space
vim.o.cmdheight = 2

-- Auto load the file when modified externally
vim.o.autoread = true
vim.bo.autoread = true

-- Disable wrap by default
vim.o.wrap = false

-- Use left / right arrow to move to the previous / next line when at the beginning / end of a line
-- Using h / l normally would not do the same thing (i.e., would remain in the current line)
-- It is also highly unrecommended to configure h / l to do such things, see doc (:help 'whichwrap')
vim.o.whichwrap = "<,>,[,]"

-- Allow hiding modified buffer
vim.o.hidden = true

-- Add mouse support for all modes
vim.o.mouse = "a"

-- Disable creation of backup files
vim.o.backup = false
vim.o.writebackup = false
vim.o.swapfile = false

-- Smaller updatetime
vim.o.updatetime = 300

-- Time to wait for a sequence of key combination
vim.o.timeoutlen = 500

-- Split window from below and right
vim.o.splitbelow = true
vim.o.splitright = true

-- Enable auto complete menu, and forbid automatically selecting the first option
vim.g.completeopt = "menu,menuone,noinsert,noselect"

-- Styling
vim.o.termguicolors = true
vim.opt.termguicolors = true

-- Show wild menu, which display completion options for vim commands
vim.o.wildmenu = true

-- Avoid "hit-enter" prompts
-- Don't pass messages to |ins-completin menu|
vim.o.shortmess = vim.o.shortmess .. "c"

-- Maximum of 16 lines of prompt
vim.o.pumheight = 16

-- Always show tab line
vim.o.showtabline = 2

-- Disable displaying of vim mode, because we have plugins doing this
vim.o.showmode = false

vim.go.nrformats = "bin,hex,alpha"

-- Hide line number in terminal
vim.cmd [[
    autocmd TermOpen * setlocal nonumber norelativenumber
]]
