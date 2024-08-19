Ice.plugins.lspsaga = {
    "nvimdev/lspsaga.nvim",
    event = { "InsertEnter", "User IceLoad" },
    opts = {
        finder = {
            keys = {
                toggle_or_open = "<CR>",
            },
        },
        symbol_in_winbar = {
            enable = false,
        },
    },
}

Ice.plugins.trouble = {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
        {
            "<leader>lt",
            "<Cmd>Trouble diagnostics toggle focus=true<CR>",
            desc = "trouble toggle",
            silent = true,
            noremap = true,
        },
    },
}
