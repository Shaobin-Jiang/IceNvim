local keymap = {}

keymap.mapLsp = {
    rename = { "n", "<leader>rn", ":Lspsaga rename<CR>" },
    code_action = { "n", "<leader>ca", ":Lspsaga code_action<CR>" },
    go_to_definition = { "n", "gd", ":lua vim.lsp.buf.definition()<CR>" },
    doc = { "n", "gh", ":Lspsaga hover_doc<CR>" },
    references = { "n", "gr", ":Lspsaga lsp_finder<CR>" },
    go_to_implementation = { "n", "gi", ":lua vim.lsp.buf.implementation()<CR>" },
    show_line_diagnostic = { "n", "gP", ":Lspsaga show_line_diagnostics<CR>" },
    next_diagnostic = { "n", "gn", ":Lspsaga diagnostic_jump_next<CR>" },
    prev_diagnostic = { "n", "gp", ":Lspsaga diagnostic_jump_prev<CR>" },
    copy_diagnostic = { "n", "gy", ":Lspsaga yank_line_diagnostics<CR>" },
    format_code = {
        "n",
        "<leader>fm",
        function()
            local lsp_is_active = require("core.utils").lsp_is_active

            if lsp_is_active "denols" then
                vim.cmd ":w"
                vim.cmd "!deno fmt %"
                vim.cmd ""
                return
            end

            if lsp_is_active "rust_analyzer" then
                vim.cmd ":w"
                vim.cmd "!cargo fmt"
                vim.cmd ""
                return
            end

            vim.lsp.buf.format { async = true }
        end,
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
