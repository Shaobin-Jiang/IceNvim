local utils = {}

utils.lsp_attach_keymap = function(bufnr)
    require("core.utils").group_map(Ice.keymap.lsp.mapLsp, { noremap = true, silent = true, buffer = bufnr })
end

-- Checks whether a lsp client is active in the current buffer
-- If no lsp is specified, the function checks whether any lsp is attached
---@param lsp string | nil
---@return boolean
utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_clients { bufnr = 0, name = lsp }
    return #active_client > 0
end

return utils
