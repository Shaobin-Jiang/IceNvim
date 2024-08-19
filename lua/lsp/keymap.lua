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
    format_code = {
        "n",
        "<leader>lf",
        function()
            local lsp_is_active = require("lsp.utils").lsp_is_active

            if lsp_is_active "denols" then
                vim.cmd "<Cmd>w"
                vim.cmd "!deno fmt %"
                vim.cmd ""
                return
            end

            if lsp_is_active "rust_analyzer" then
                vim.cmd "<Cmd>w"
                vim.cmd "!cargo fmt"
                vim.cmd ""
                return
            end

            vim.lsp.buf.format { async = true }
        end,
    },
}

Ice.keymap.lsp.cmp = function(cmp)
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
            behavior = cmp.ConfirmBehavior.Insert,
        },
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    }
end
