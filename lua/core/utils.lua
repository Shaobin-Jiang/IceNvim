-- Do not use vim.version as it loads the vim.version module
-- Using vim.fn.api_info().version is no good either as api_info also consumes much time
local version = vim.fn.matchstr(vim.fn.execute "version", "NVIM v\\zs[^\\n]*")

local argv = vim.api.nvim_get_vvar "argv"
local noplugin = vim.list_contains(argv, "--noplugin") or vim.list_contains(argv, "--noplugins")

local utils = {
    is_linux = vim.uv.os_uname().sysname == "Linux",
    is_mac = vim.uv.os_uname().sysname == "Darwin",
    is_windows = vim.uv.os_uname().sysname == "Windows_NT",
    is_wsl = string.find(vim.uv.os_uname().release, "WSL") ~= nil,
    noplugin = noplugin,
    version = version,
}

local ft_group = vim.api.nvim_create_augroup("IceFt", { clear = true })

-- Add callback to filetype
---@param filetype string
---@param config function
utils.ft = function(filetype, config)
    vim.api.nvim_create_autocmd("FileType", {
        pattern = filetype,
        group = ft_group,
        callback = config,
    })
end

-- Gets the root dir of the current buffer
utils.get_root = function()
    local default_pattern = {
        ".git",
        "package.json",
        ".prettierrc",
        "tsconfig.json",
        "pubspec.yaml",
        ".gitignore",
        "stylua.toml",
        "README.md",
    }

    local pattern = Ice.chdir_root_pattern
    if pattern == nil or type(pattern) ~= "table" then
        pattern = default_pattern
    end

    local filename = vim.fn.resolve(vim.fn.expand("%:p", true))
    local root = vim.fs.root(filename, pattern) or vim.fs.dirname(filename)

    return root
end

-- Maps a group of keymaps with the same opt; if no opt is provided, the default opt is used.
-- The keymaps should be in the format like below:
--     desc = { mode, lhs, rhs, [opt] }
-- For example:
--     black_hole_register = { { "n", "v" }, "\\", '"_' },
-- The desc part will automatically merged into the keymap's opt, unless one is already provided there, with the slight
-- modification of replacing "_" with a blank space.
---@param group table list of keymaps
---@param opt table | nil default opt
utils.group_map = function(group, opt)
    if not opt then
        opt = {}
    end

    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")
        local default_option = vim.tbl_extend("force", { desc = desc, nowait = true, silent = true }, opt)
        local map = vim.tbl_deep_extend("force", { nil, nil, nil, default_option }, keymap)
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end

-- Allow ordered iteration through a table
---@param t table
---@return function
utils.ordered_pair = function(t)
    local a = {}

    for n in pairs(t) do
        a[#a + 1] = n
    end

    table.sort(a)

    local i = 0

    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

-- Updates IceNvim
utils.update = function()
    vim.system({ "git", "pull" }, { cwd = vim.fn.stdpath "config", text = true }, function(out)
        if out.code == 0 then
            vim.notify "IceNvim up to date"
        else
            vim.notify("IceNvim update failed: " .. out.stderr, vim.log.levels.WARN)
        end
    end)
end

-- Finds the first occurence of the target in table and returns the key / index.
-- If the target is not in the table, nil is returned.
---@param t table
---@param target ... | any
---@return ... | any
table.find = function(t, target)
    for key, value in pairs(t) do
        if value == target then
            return key
        end
    end

    return nil
end

return utils
