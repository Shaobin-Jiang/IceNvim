Ice.keymap.lsp = {}

Ice.keymap.lsp.mapLsp = {
    rename = { "n", "<leader>lr", "<Cmd>Lspsaga rename<CR>" },
    code_action = { "n", "<leader>lc", "<Cmd>Lspsaga code_action<CR>" },
    go_to_definition = { "n", "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>" },
    hover_doc = {
        "n",
        "<leader>lh",
        function()
            vim.cmd "Lspsaga hover_doc"

            -- PERF: maybe we can do better at this? For now I have now figured out how to make this work without the
            -- delay, though.
            vim.defer_fn(function()
                local winid = require("lspsaga.hover").winid
                if winid then
                    vim.api.nvim_set_current_win(winid)
                end
            end, 100)
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
