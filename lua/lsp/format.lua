-- While null-ls can do a lot more than just formatting, I am leaving the rest to LspSaga
-- See extra.lua
Ice.plugins["null-ls"] = {
    "nvimtools/none-ls.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = "User IceLoad",
    opts = {
        debug = false,
    },
    config = function(_, opts)
        local null_ls = require "null-ls"
        local formatting = null_ls.builtins.formatting

        local sources = {}
        for _, config in pairs(Ice.lsp) do
            if config.formatter then
                local source = formatting[config.formatter]
                sources[#sources + 1] = source
            end
        end

        null_ls.setup(vim.tbl_deep_extend("keep", opts, { sources = sources }))
    end,
}
