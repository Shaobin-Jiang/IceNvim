Ice.keymap.lsp = {}

Ice.keymap.lsp.mapLsp = {
    rename = { "n", "<leader>lr", "<Cmd>Lspsaga rename<CR>" },
    code_action = { "n", "<leader>lc", "<Cmd>Lspsaga code_action<CR>" },
    go_to_definition = { "n", "<leader>ld", "<Cmd>Lspsaga goto_definition<CR>" },
    doc = { "n", "<leader>lh", "<Cmd>Lspsaga hover_doc<CR>" },
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
