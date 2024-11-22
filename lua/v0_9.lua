local M = {
    -- Executed after the core / plugins configuration
    after = function() end,
}

-- do not use vim.version.cmp as it seems buggy
local version = vim.version()
if version.major * 100 + version.minor < 10 then
    vim.uv = vim.loop

    M.after = function()
        Ice.plugins["indent-blankline"].version = "3.5"
        Ice.plugins.neogit.tag = "v0.0.1"
    end
end

return M
