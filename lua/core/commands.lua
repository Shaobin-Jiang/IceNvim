vim.api.nvim_create_user_command("IceAbout", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.keymap.set("n", "q", "<C-w>c", { buffer = buf })

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

    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end, { nargs = 0 })

vim.api.nvim_create_user_command("IceCheckIcons", function()
    local buf = vim.api.nvim_create_buf(false, true)
    vim.keymap.set("n", "q", "<C-w>c", { buffer = buf })

    local item_width = 24
    local item_name_width = 18
    local win_width = vim.fn.winwidth(0)
    local win_height = vim.fn.winheight(0)
    local columns = math.floor(win_width / item_width) - 1

    local content = {}
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
            content[#content + 1] = line
            items_in_row = 0
            line = ""
        end
    end

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)

    local width = columns * item_width
    local height = math.ceil(item_number / columns)
    local left = math.floor((win_width - width) / 2)
    local top = math.floor((win_height - height) / 2)

    local win = vim.api.nvim_open_win(buf, true, {
        relative = "win",
        width = width,
        height = height,
        row = top,
        col = left,
        border = "rounded",
        title = "Check Nerd Font Icons",
        title_pos = "center",
        footer = "Press q to close window",
        footer_pos = "center",
    })

    vim.api.nvim_set_option_value("number", false, { win = win })
    vim.api.nvim_set_option_value("relativenumber", false, { win = win })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end, { nargs = 0 })

vim.api.nvim_create_user_command("IceUpdate", "lua require('core.utils').update()", { nargs = 0 })

vim.api.nvim_create_user_command("IceHealth", "checkhealth core", { nargs = 0 })

-- Allow a command to be repeated based on v:count1
vim.api.nvim_create_user_command("IceRepeat", function(args)
    for _ = 1, vim.v.count1 do
        vim.cmd(args.args)
    end
end, { nargs = "+", complete = "command" })

-- View the output of a command in an external buffer
vim.api.nvim_create_user_command("IceView", function(args)
    local path = vim.fn.stdpath "data" .. "/ice-view.txt"
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
