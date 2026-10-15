local function config_window(win, buf)
    vim.keymap.set("n", "q", "<C-w>c", { buffer = buf })
    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
    vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
    vim.api.nvim_set_option_value("cursorline", false, { win = win })
    vim.api.nvim_set_option_value("colorcolumn", "", { win = win })
    vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })
end

vim.api.nvim_create_user_command("IceAbout", function()
    local buf = vim.api.nvim_create_buf(false, true)

    local win_width = vim.fn.winwidth(0)
    local win_height = vim.fn.winheight(0)
    local width = 80
    local height = math.floor(win_height * 0.3)
    local left = math.floor((win_width - width) / 2)
    local top = math.floor((win_height - height) / 2)

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "",
        "A beautiful, powerful and highly customizable neovim config.",
        "",
        "Author: Shaobin Jiang",
        "",
        "Url: https://github.com/Shaobin-Jiang/IceNvim",
        "",
        string.format("Copyright © 2022-%s Shaobin Jiang", os.date "%Y"),
    })

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        width = width,
        height = height,
        row = top,
        col = left,
        border = "rounded",
        title = "About IceNvim",
        title_pos = "center",
        footer = "Press q to close window",
        footer_pos = "center",
    })

    config_window(win, buf)
end, { nargs = 0 })

vim.api.nvim_create_user_command("IceHealth", "checkhealth core", { nargs = 0 })

-- Allow a command to be repeated based on v:count1
vim.api.nvim_create_user_command("IceRepeat", function(args)
    for _ = 1, vim.v.count1 do
        vim.cmd(args.args)
    end
end, { nargs = "+", complete = "command" })

-- Use tokei to count code lines in pwd
vim.api.nvim_create_user_command("IceTokei", function()
    if vim.fn.executable "tokei" == 0 then
        vim.notify("Tokei is not installed!", vim.log.levels.WARN)
        return
    end

    local pwd = require("core.utils").get_root()

    require("core.utils").system({ "tokei" }, { cwd = pwd, text = true }, function(out)
        if out.code ~= 0 then
            vim.notify("Tokei encountered an unexpected error: " .. out.stderr, vim.log.levels.WARN)
            return
        end

        local content = vim.split(out.stdout, "\n")
        local buf = vim.api.nvim_create_buf(false, true)

        local win_width = vim.fn.winwidth(0)
        local win_height = vim.fn.winheight(0)
        local width = 80
        local min_height = math.floor(win_height * 0.3)
        local max_height = math.floor(win_height * 0.8)
        local line_num = #content
        local height = math.min(math.max(line_num, min_height), max_height)
        local left = math.floor((win_width - width) / 2)
        local top = math.floor((win_height - height) / 2)

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

        local win = vim.api.nvim_open_win(buf, true, {
            relative = "win",
            width = width,
            height = height,
            row = top,
            col = left,
            border = "rounded",
            title = "Tokei " .. pwd,
            title_pos = "center",
            footer = "Press q to close window",
            footer_pos = "center",
        })

        config_window(win, buf)
    end)
end, { nargs = 0 })

-- View the output of a command in an external buffer
vim.api.nvim_create_user_command("IceView", function(args)
    local path = vim.fs.joinpath(vim.fn.stdpath "data", "ice-view.txt")
    if args.args == "" then
        vim.cmd("edit " .. path)
    else
        vim.cmd(string.format(
            [[
                redir! > %s
                silent %s
                redir END
                edit %s
            ]],
            path,
            args.args,
            path
        ))
    end
end, { nargs = "*", complete = "command" })

-- Yank the output of a command
vim.api.nvim_create_user_command("IceYank", function(args)
    vim.cmd(string.format(
        [[
            redir @+>
            silent %s
            redir END
            lua vim.notify("Content yanked to system clipboard")
        ]],
        args.args
    ))
end, { nargs = "+", complete = "command" })

-- Replacement for the old `LspInfo` command that is dropped in 0.12
vim.api.nvim_create_user_command("LspInfo", function()
    vim.cmd "checkhealth vim.lsp"
end, { nargs = 0 })
