local g = vim.g
local opt = vim.opt

-- This MUST NOT be en_US, but en_US.UTF-8
-- I originally set it to en_US without UTF-8 and `yGp` ceased to work
-- It just threw an 'E353: Nothing in register "' error at me
vim.cmd "language en_US.UTF-8"

vim.cmd "syntax off"
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
opt.shiftwidth = 0
opt.expandtab = true
opt.shiftround = true

-- Case insensitive searching when no upper case character is present
opt.ignorecase = true
opt.smartcase = true

-- Disable the ugly highlight during searches
opt.hlsearch = false

opt.cmdheight = 1
opt.cmdwinheight = 1

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
opt.mousemodel = "extend"

opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Time to wait for a sequence of key combination
opt.timeoutlen = 500

-- Split window from below and right
opt.splitbelow = true
opt.splitright = true

opt.termguicolors = true

-- Do not display the character "W" before search count
opt.shortmess = vim.o.shortmess .. "s"

-- Maximum of 16 lines of prompt
-- This affects both neovim's native completion and that of nvim-cmp
opt.pumheight = 16

-- Always show tab line
-- Otherwise, when bufferline is loaded, it will "flash" a bit initially
opt.showtabline = 2
opt.tabline = "%!''"

opt.showmode = false

opt.nrformats = "bin,hex,alpha"

opt.foldlevel = 99
opt.foldlevelstart = 99
opt.foldenable = false

if require("core.utils").is_windows then
    opt.shellslash = true
end

vim.api.nvim_create_autocmd("TermOpen", {
    callback = function()
        vim.wo.number = false
        vim.wo.relativenumber = false
    end,
})

opt.shadafile = "NONE"
vim.api.nvim_create_autocmd({ "CmdlineEnter", "CmdwinEnter" }, {
    once = true,
    callback = function()
        local shada = vim.fn.stdpath "state" .. "/shada/main.shada"
        vim.o.shadafile = shada
        vim.cmd("rshada! " .. shada)
    end,
})

vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        vim.cmd "startinsert"
        vim.wo.number = false
        vim.wo.relativenumber = false
    end,
})
