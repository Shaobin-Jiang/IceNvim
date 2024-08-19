local utils = {}

utils.lsp_attach_keymap = function(bufnr)
    require("core.utils").group_map(Ice.keymap.lsp.mapLsp, { noremap = true, silent = true, buffer = bufnr })
end

-- Checks whether a lsp client is active
---@param lsp string
---@return boolean
utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_clients { name = lsp }
    return #active_client > 0
end

return utils
