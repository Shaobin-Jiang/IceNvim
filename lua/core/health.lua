local M = {}

-- Checks whether the cmd is executable and determines how to behave if it is not
--
---@param cmd string the command to check
---@param behavior function | nil what to do if cmd is not executable; throws an error message by default
local function check(cmd, behavior)
    if vim.fn.executable(cmd) == 1 then
        vim.health.ok(cmd .. " is installed.")
    else
        if not behavior then
            vim.health.error(cmd .. " is missing.")
        else
            behavior()
        end
    end
end

M.check = function()
    vim.health.start "IceNvim Prerequisites"
    vim.health.info "IceNvim does not check this for you, but at least one [nerd font] should be installed."

    for _, cmd in ipairs { "curl", "wget", "fd", "rg", "gcc", "cmake", "node", "npm", "yarn", "python3", "pip3" } do
        check(cmd)
    end

    if vim.fn.executable "gzip" == 1 or vim.fn.executable "7z" == 1 then
        vim.health.ok "One of gzip / 7zip is installed."
    else
        vim.health.error "You must install one of gzip or 7zip."
    end

    check("rust-analyzer", function()
        vim.health.warn "For best experience with rust development, you should install rust-analyzer."
    end)

    if require("core.utils").is_linux then
        vim.health.start "IceNvim Prerequisites for Linux"
        vim.health.info "IceNvim does not check this for you, but you need a [python virtualenv]."

        for _, cmd in ipairs { "unzip", "xclip", "zip" } do
            check(cmd)
        end
    end

    if require("core.utils").is_windows or require("core.utils").is_wsl then
        vim.health.start "IceNvim Optional Dependencies for Windows and WSL"

        check(vim.fn.stdpath "config" .. "/bin/im-select.exe", function()
            vim.health.warn "You need im-select.exe to enable automatic IME switching for Chinese. Consider downloading it at https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe"
        end)

        check(vim.fn.stdpath "config" .. "/bin/uclip.exe", function()
            vim.health.warn "You need uclip.exe for correct unicode copy / paste. Consider downloading it at https://github.com/suzusime/uclip/releases/download/v0.1.0/uclip.exe"
        end)
    end

    if require("core.utils").is_mac then
        vim.health.start "IceNvim Optional Dependencies for MacOS"

        check("im-select", function()
            vim.health.warn "You need im-select to enable automatic IME switching for Chinese. Please refer to the wiki for instruction on how to install it."
        end)
    end
end

return M
