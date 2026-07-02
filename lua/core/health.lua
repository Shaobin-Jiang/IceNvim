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

    for _, cmd in ipairs {
        "curl",
        "wget",
        "fd",
        "rg",
        "gcc",
        "cmake",
        "node",
        "npm",
        "yarn",
        "python3",
        "pip3",
        "tree-sitter",
    } do
        check(cmd)
    end

    if vim.fn.executable "gzip" == 1 or vim.fn.executable "7z" == 1 then
        vim.health.ok "One of gzip / 7zip is installed."
    else
        vim.health.error "You must install one of gzip or 7zip."
    end

    check("tokei", function()
        vim.health.warn "To enable code counting, you mightwant to install tokei."
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

        if require("core.utils").is_windows then
            check("cl", function()
                vim.health.error "You need msvc for treesitter to work properly. Specifically, you need cl.exe to be in your PATH."
            end)
        end

        check(vim.fs.joinpath(vim.fn.stdpath "config", "bin/im-select.exe"), function()
            vim.health.warn "You need im-select.exe to enable automatic IME switching for Chinese. Consider downloading it at https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe"
        end)

        check(vim.fs.joinpath(vim.fn.stdpath "config", "bin/uclip.exe"), function()
            vim.health.warn "You need uclip.exe for correct unicode copy / paste. Consider downloading it at https://github.com/suzusime/uclip/releases/download/v0.1.0/uclip.exe"
        end)
    end

    if require("core.utils").is_mac then
        vim.health.start "IceNvim Optional Dependencies for MacOS"

        check("macism", function()
            vim.health.warn "You need macism to enable automatic IME switching for Chinese. Please refer to the wiki for instruction on how to install it."
        end)
    end

    vim.health.start "IceNvim Lsp Support"

    if Ice.lsp.rust.enabled == true then
        vim.health.info "Rust"
        check("rust-analyzer", function()
            vim.health.error "You have rust support enabled, which requires rust-analyzer."
        end)
        vim.health.info "----------------------------------------"
    end

    if Ice.lsp.emmylua_ls.enabled == true then
        vim.health.info "Emmylua"
        check("emmylua_ls", function()
            vim.health.error "You have emmylua_ls support enabled, which requires emmylua_ls."
        end)

        local has_luv, _ = pcall(require, "luv")
        if not has_luv then
            vim.health.warn "For best experience with emmylua, you should add luv to your runtimepath."
        end

        if Ice.lsp["lua-language-server"].enabled == true then
            vim.health.warn "You have lua-language-server and emmylua_ls both enabled."
        end
    end

    vim.health.start "IceNvim Icons"

    vim.health.info "Take a look at whether the icons below render properly."
    vim.health.info "If they do not display properly, you probably need to have a NERD FONT installed."
    
    local item_width = 20
    local item_name_width = 15
    local win_width = vim.fn.winwidth(0)
    local columns = math.floor(win_width / item_width) - 1

    local items_in_row = 0
    local line = ""
    local item_number = 0
    for name, icon in require("core.utils").ordered_pair(Ice.symbols) do
        item_number = item_number + 1
        line = string.format(
            "%s%s%s%s%s",
            line,
            name,
            string.rep(" ", item_name_width - #name),
            icon,
            string.rep(" ", item_width - item_name_width - vim.fn.strdisplaywidth(icon))
        )

        items_in_row = items_in_row + 1

        if items_in_row == columns then
            vim.health.info(line)
            items_in_row = 0
            line = ""
        end
    end
end

return M
