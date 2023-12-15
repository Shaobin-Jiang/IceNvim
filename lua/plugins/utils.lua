local utils = {}

-- Set up colorscheme and Ice.colorscheme, but does not take care of lualine
utils.colorscheme = function(colorscheme)
    Ice.colorscheme = colorscheme
    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

return utils
