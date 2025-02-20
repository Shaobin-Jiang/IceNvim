local v = vim.version()
local version = string.format("%d.%d.%d", v.major, v.minor, v.patch)

local argv = vim.api.nvim_get_vvar "argv"
local noplugin = false
for i = 3, #argv, 1 do
    if argv[i] == "--noplugin" then
        noplugin = true
        break
    end
end

local utils = {
    is_linux = vim.uv.os_uname().sysname == "Linux",
    is_mac = vim.uv.os_uname().sysname == "Darwin",
    is_windows = vim.uv.os_uname().sysname == "Windows_NT",
    is_wsl = string.find(vim.uv.os_uname().release, "WSL") ~= nil,
    noplugin = noplugin,
    version = version,
}

local ft_group = vim.api.nvim_create_augroup("IceFt", { clear = true })

-- Checks if a file exists
---@param file string
---@return boolean
utils.file_exists = function(file)
    local fid = io.open(file, "r")
    if fid ~= nil then
        io.close(fid)
        return true
    else
        return false
    end
end

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

-- Get the parent directory of target. If target is nil, the parent directory of the current file will be looked for,
-- suffixed with a "/" (which is because this function is intended to be used together with fs_scandir, where errors
-- would occur sometimes should a path without an ending "/" be passed to it, such as "C:" instead of "C:/").
--
-- If the target has no parent directory, such as "/" on Linux or "C:" on Windows, nil will be returned.
---@param target string?
---@return string?
utils.get_parent = function(target)
    if target == nil then
        local parent = vim.fn.expand("%:p:h", true)

        if utils.is_windows then
            parent = string.gsub(parent, "\\", "/")
        end

        return parent
    end

    if utils.is_windows then
        target = string.gsub(target, "\\", "/")
    end

    -- removes trailing slash
    if string.sub(target, #target, #target) == "/" then
        target = string.sub(target, 1, #target - 1)
    end

    if string.find(target, "/") == nil then
        return nil
    end

    return string.sub(target, 1, string.findlast(target, "/"))
end

utils.get_root = function()
    local uv = vim.uv

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

    local parent = utils.get_parent()
    local root = parent
    local has_found_root = false

    while not (has_found_root or parent == nil) do
        local dir = uv.fs_scandir(parent)

        if dir == nil then
            break
        end

        local file = ""

        while file ~= nil do
            file = uv.fs_scandir_next(dir)
            if table.find(pattern, file) then
                root = parent
                has_found_root = true
                break
            end
        end

        parent = utils.get_parent(parent)
    end

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

-- Looks for the last match of `pattern`
-- WARN: this function does poorly with unicode characters!
---@param s string | number
---@param pattern string | number
---@param last integer?
---@param plain boolean?
---@return integer | nil, integer | nil, ... | any
string.findlast = function(s, pattern, last, plain)
    local reverse = string.reverse(s)

    if last == nil then
        last = #s
    end

    local start, finish = string.find(reverse, string.reverse(pattern), #s + 1 - last, plain)
    if start == nil then
        return nil
    else
        return #s + 1 - finish, #s + 1 - start
    end
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
