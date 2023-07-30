local keymap = {}

keymap.mapLsp = {
    { "<leader>rn", ":Lspsaga rename<CR>", mode = "n" },
    { "<leader>ca", ":Lspsaga code_action<CR>", mode = "n" },
    { "gd", ":lua vim.lsp.buf.definition()<CR>", mode = "n" },
    { "gh", ":Lspsaga hover_doc<CR>", mode = "n" },
    { "gr", ":Lspsaga lsp_finder<CR>", mode = "n" },
    { "gi", ":lua vim.lsp.buf.implementation()<CR>", mode = "n" },
    { "gP", ":Lspsaga show_line_diagnostics<CR>", mode = "n" },
    { "gn", ":Lspsaga diagnostic_jump_next<CR>", mode = "n" },
    { "gp", ":Lspsaga diagnostic_jump_prev<CR>", mode = "n" },
    { "gy", ":Lspsaga yank_line_diagnostics<CR>", mode = "n" },
    {
        "<leader>fm",
        function()
            local active_client = vim.lsp.get_active_clients { name = "denols" }
            if #active_client > 0 then
                vim.cmd "!deno fmt %"
                vim.cmd ""
            else
                vim.lsp.buf.format { async = true }
            end
        end,
        mode = "n",
    },
}

keymap.cmp = function(cmp)
    return {
        -- Show completion
        ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        -- Cancel
        ["<A-,>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        },
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<Tab>"] = cmp.mapping.confirm {
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
        },
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    }
end

return keymap
