return {
    keyAttach = function(bufnr)
        require("core.utils").group_map(
            require("settings").lsp.keymap.mapLsp,
            { noremap = true, silent = true, buffer = bufnr }
        )
    end,
    disableFormat = function(client)
        if vim.fn.has "nvim-0.8" == 1 then
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
        else
            client.resolved_capabilities.document_formatting = false
            client.resolved_capabilities.document_range_formatting = false
        end
    end,
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    flags = {
        debounce_text_changes = 150,
    },
}
