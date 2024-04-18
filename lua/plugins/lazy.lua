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

Ice.lazy = {
    performance = {
        rtp = {
            disabled_plugins = {
                "editorconfig",
                "gzip",
                "matchit",
                "matchparen",
                "netrwPlugin",
                "shada",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    ui = {
        backdrop = 60,
    },
}

-- Removes the hedious gray backdrop of lazy popup by overriding `nvim_set_hl`
local old_set_hl = vim.api.nvim_set_hl
vim.api.nvim_set_hl = function(ns_id, name, opt)
    if name == "LazyBackdrop" then
        -- This ought to be linked to LazyNormal, but since that highlight group may not be defined and will later be
        -- linked to NormalFloat, it makes no difference if we simply link LazyBackdrop to NormalFloat directly.
        opt = { link = "NormalFloat" }
    end
    old_set_hl(ns_id, name, opt)
end
