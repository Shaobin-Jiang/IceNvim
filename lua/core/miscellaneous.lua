local utils = require "core.utils"

local config_path = string.gsub(vim.fn.stdpath "config", "\\", "/")

-- Yanking on windows / wsl
local clip_path = config_path .. "/bin/uclip.exe"
local uclip_exe = io.open(clip_path, "r")
if uclip_exe ~= nil then
    io.close(uclip_exe)
else
    local root
    if utils.is_windows() then
        root = "C:"
    else
        root = "/mnt/c"
    end
    clip_path = root .. "/Windows/System32/clip.exe"
end

if utils.is_windows() or utils.is_wsl() then
    vim.cmd(string.format(
        [[
        augroup fix_yank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' | call system('%s', @0) | endif
        augroup END
        ]],
        clip_path
    ))
elseif utils.is_linux() then
    vim.cmd "set clipboard+=unnamedplus"
end

-- IME switching on windows / wsl
if utils.is_windows() or utils.is_wsl() then
    local im_select_path = config_path .. "/bin/im-select.exe"

    local im_select_exe = io.open(im_select_path, "r")
    if im_select_exe ~= nil then
        io.close(im_select_exe)

        local ime_autogroup = vim.api.nvim_create_augroup("ImeAutoGroup", { clear = true })

        local function autocmd(event, code)
            vim.api.nvim_create_autocmd(event, {
                group = ime_autogroup,
                callback = function()
                    vim.cmd(":silent :!" .. im_select_path .. " " .. code)
                end,
            })
        end

        autocmd("InsertLeave", 1033)
        autocmd("InsertEnter", 2052)
        autocmd("VimLeavePre", 2052)
    end
elseif utils.is_linux() then
    vim.cmd [[
        let fcitx5state=system("fcitx5-remote")
        autocmd InsertLeave * :silent let fcitx5state=system("fcitx5-remote")[0] | silent !fcitx5-remote -c
        autocmd InsertEnter * :silent if fcitx5state == 2 | call system("fcitx5-remote -o") | endif
    ]]
end

-- Automatic switch to root directory
vim.api.nvim_create_autocmd("BufEnter", {
    group = vim.api.nvim_create_augroup("AutoChdir", { clear = true }),
    callback = function()
        if not (Ice.auto_chdir or Ice.auto_chdir == nil) then
            return
        end

        local default_exclude_filetype = { "NvimTree", "help" }

        local exclude_filetype = Ice.chdir_exclude_filetype
        if exclude_filetype == nil or type(exclude_filetype) ~= "table" then
            exclude_filetype = default_exclude_filetype
        end

        if table.find(exclude_filetype, vim.bo.filetype) then
            return
        end

        vim.api.nvim_set_current_dir(require("core.utils").get_root())
    end,
})
