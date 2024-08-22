Ice.keymap.lsp = {}

Ice.keymap.lsp.mapLsp = {
    rename = { "n", "<leader>lr", "<Cmd>Lspsaga rename<CR>" },
    code_action = { "n", "<leader>lc", "<Cmd>Lspsaga code_action<CR>" },
    go_to_definition = { "n", "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>" },
    hover_doc = {
        "n",
        "<leader>lh",
        function()
            local win = require "lspsaga.window"
            local old_new_float = win.new_float
            win.new_float = function(window, float_opt, enter, force)
                local return_value = old_new_float(window, float_opt, enter, force)
                local old_wininfo = return_value.wininfo

                return_value.wininfo = function(_window)
                    local bufnr, winid = old_wininfo(_window)
                    vim.api.nvim_set_current_win(winid)
                    return_value.wininfo = old_wininfo

                    return bufnr, winid
                end

                win.new_float = old_new_float
                return return_value
            end

            vim.cmd "Lspsaga hover_doc"
        end,
    },
    references = { "n", "<leader>lR", "<Cmd>Lspsaga finder<CR>" },
    go_to_implementation = { "n", "<leader>li", "<Cmd>Lspsaga finder<CR>" },
    show_line_diagnostic = { "n", "<leader>lP", "<Cmd>Lspsaga show_line_diagnostics<CR>" },
    next_diagnostic = { "n", "<leader>ln", "<Cmd>Lspsaga diagnostic_jump_next<CR>" },
    prev_diagnostic = { "n", "<leader>lp", "<Cmd>Lspsaga diagnostic_jump_prev<CR>" },
}

Ice.keymap.lsp.cmp = {
    show_completion = "<A-.>",
    hide_completion = "<A-,>",
    prev_item = "<C-k>",
    next_item = "<C-j>",
    confirm = "<Tab>",
    doc_up = "<C-u>",
    doc_down = "<C-d>",
}
