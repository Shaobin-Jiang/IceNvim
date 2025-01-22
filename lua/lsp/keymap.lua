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
            win.new_float = function(self, float_opt, enter, force)
                local window = old_new_float(self, float_opt, enter, force)
                local _, winid = window:wininfo()
                vim.api.nvim_set_current_win(winid)

                win.new_float = old_new_float
                return window
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
    toggle_completion = "<A-c>",
    prev_item = "<C-k>",
    next_item = "<C-j>",
    confirm = "<Tab>",
    doc_up = "<C-u>",
    doc_down = "<C-d>",
}
