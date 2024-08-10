Ice.ft = {
    cs = function()
        vim.wo.colorcolumn = "100"
    end,
    css = function()
        vim.bo.comments = "s1:/*,ex:*/"
    end,
    dart = function()
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
    end,
    html = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true

        if vim.bo.filetype == "html" then
            vim.wo.colorcolumn = "120"
        end
    end,
    javascript = function()
        vim.wo.colorcolumn = "120"
    end,
    markdown = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true
    end,
    python = function()
        vim.bo.formatoptions = "tcqjor"
    end,
    typescript = function()
        vim.wo.colorcolumn = "120"
    end,
    typst = function()
        vim.wo.wrap = true
        vim.wo.linebreak = true
        vim.wo.breakindent = true
        vim.bo.shiftwidth = 2
        vim.bo.softtabstop = 2
        vim.bo.tabstop = 2
    end,
    -- Convenience method for setting FileType callback
    -- Extends default callback if already set
    ---@param self table
    ---@param ft string
    ---@param callback function
    set = function(self, ft, callback)
        local default_callback = self[ft]
        if default_callback ~= nil then
            self[ft] = function ()
                default_callback()
                callback()
            end
        else
            self[ft] = callback
        end
    end,
}
