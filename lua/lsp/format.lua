-- While null-ls can do a lot more than just formatting, I am leaving the rest to LspSaga
-- See extra.lua
Ice.plugins["null-ls"] = {
    "nvimtools/none-ls.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvimtools/none-ls-extras.nvim" },
    event = "User IceLoad",
    opts = {
        debug = false,
    },
    config = function(_, opts)
        local null_ls = require "null-ls"
        local builtins = require("null-ls.builtins._meta.formatting")

        local sources = {}
        for _, config in pairs(Ice.lsp) do
            local formatter = config.formatter
            if formatter then
                local base
                if builtins[formatter] ~= nil then
                    base = "null-ls.builtins.formatting."
                else
                    base = "none-ls.formatting."
                end
                local source = require(base .. formatter)
                if source then
                    sources[#sources + 1] = source
                end
            end
        end

        null_ls.setup(vim.tbl_deep_extend("keep", opts, { sources = sources }))
    end,
    keys = {
        {
            "<leader>lf",
            function()
                local active_client = vim.lsp.get_clients { bufnr = 0, name = "null-ls" }

                local format_option = { async = true }
                if #active_client > 0 then
                    format_option.name = "null-ls"
                end
                vim.lsp.buf.format(format_option)
            end,
            mode = { "n", "v" },
            desc = "format code",
        },
    },
}
