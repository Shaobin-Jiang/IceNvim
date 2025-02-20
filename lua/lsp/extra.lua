Ice.plugins.lspsaga = {
    "nvimdev/lspsaga.nvim",
    cmd = "Lspsaga",
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
    keys = {
        { "<leader>lr", "<Cmd>Lspsaga rename<CR>", desc = "rename", silent = true },
        { "<leader>lc", "<Cmd>Lspsaga code_action<CR>", desc = "code action", silent = true },
        { "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>", desc = "go to definition", silent = true },
        {
            "<leader>lh",
            function()
                local win = require "lspsaga.window"
                local old_new_float = win.new_float
                win.new_float = function(self, float_opt, enter, force)
                    local window = old_new_float(self, float_opt, enter, force)
                    local _, winid = window:wininfo()
                    vim.api.nvim_set_current_win(winid)

                    win.new_float = old_new_float
                    return window
                end

                vim.cmd "Lspsaga hover_doc"
            end,
            desc = "hover doc",
            silent = true,
        },
        { "<leader>lR", "<Cmd>Lspsaga finder<CR>", desc = "references", silent = true },
        { "<leader>li", "<Cmd>Lspsaga finder<CR>", desc = "go_to_implementation", silent = true },
        { "<leader>lP", "<Cmd>Lspsaga show_line_diagnostics<CR>", desc = "show_line_diagnostic", silent = true },
        { "<leader>ln", "<Cmd>Lspsaga diagnostic_jump_next<CR>", desc = "next_diagnostic", silent = true },
        { "<leader>lp", "<Cmd>Lspsaga diagnostic_jump_prev<CR>", desc = "prev_diagnostic", silent = true },
    },
}

Ice.plugins.trouble = {
    "folke/trouble.nvim",
    opts = {},
    cmd = "Trouble",
    keys = {
        { "<leader>lt", "<Cmd>Trouble diagnostics toggle focus=true<CR>", desc = "trouble toggle", silent = true },
    },
}
