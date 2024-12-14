-- Set up lazy.nvim
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not require("core.utils").noplugin then
    if not vim.uv.fs_stat(lazypath) then
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
end

Ice.lazy = {
    performance = {
        rtp = {
            disabled_plugins = {
                "editorconfig",
                "gzip",
                "man",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "osc52",
                "rplugin",
                "shada",
                "spellfile",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    ui = {
        backdrop = 100,
    },
}
