local utils = {}

utils.create_cmp_keymap = function()
    local cmp = require "cmp"
    local cmp_func = {
        toggle_completion = cmp.mapping {
            i = function()
                if cmp.visible() then
                    cmp.abort()
                else
                    cmp.complete()
                end
            end,
            c = function()
                if cmp.visible() then
                    cmp.close()
                else
                    cmp.complete()
                end
            end,
        },
        prev_item = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
        next_item = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
        confirm = cmp.mapping(
            cmp.mapping.confirm {
                select = true,
                behavior = cmp.ConfirmBehavior.Insert,
            },
            { "i", "c" }
        ),
        doc_up = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i" }),
        doc_down = cmp.mapping(cmp.mapping.scroll_docs(4), { "i" }),
    }

    local cmp_keymap = {}
    for command, key in pairs(Ice.keymap.lsp.cmp) do
        local func = cmp_func[command]
        if func then
            cmp_keymap[key] = func
        end
    end

    return cmp_keymap
end

utils.lsp_attach_keymap = function(bufnr)
    require("core.utils").group_map(Ice.keymap.lsp.mapLsp, { silent = true, buffer = bufnr })
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
