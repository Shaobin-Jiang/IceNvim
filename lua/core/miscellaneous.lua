local utils = require "core.utils"

-- Yanking on windows / wsl
if utils.is_windows() or utils.is_wsl() then
    local root
    if utils.is_windows() then
        root = "C:"
    else
        root = "/mnt/c"
    end

    vim.cmd(string.format(
        [[
        augroup fix_yank
            autocmd!
            autocmd TextYankPost * if v:event.operator ==# 'y' | call system('%s/Windows/System32/clip.exe', @0) | endif
        augroup END
        ]],
        root
    ))
elseif utils.is_linux() then
    vim.cmd "set clipboard+=unnamedplus"
end

-- IME switching on windows / wsl
if utils.is_windows() or utils.is_wsl() then
    local config_path = string.gsub(vim.fn.stdpath "config", "\\", "/")
    local im_select_path = config_path .. "/bin/im-select.exe"

    local f = io.open(im_select_path, "r")
    if f ~= nil then
        io.close(f)

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
