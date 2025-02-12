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
    vim.api.nvim_set_option_value("wrap", false, { win = win })
    vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
end, { nargs = 0 })

vim.api.nvim_create_user_command("IceCheckPlugins", function()
    local plugins_path = vim.fn.stdpath "data" .. "/lazy/"
    local dir = vim.uv.fs_scandir(plugins_path)

    local stale_plugins = {}

    local plugin_count = 0

    if dir ~= nil then
        local co = coroutine.create(function()
            local checked_plugin_count = 1
            while plugin_count > checked_plugin_count do
                coroutine.yield()
                checked_plugin_count = checked_plugin_count + 1
            end

            table.sort(stale_plugins, function(a, b)
                return a[2] > b[2]
            end)

            local really_stale_plugin_count = 0
            local report = vim.tbl_map(function(entry)
                if entry[2] > 365 then
                    really_stale_plugin_count = really_stale_plugin_count + 1
                end
                return string.format("%s: %d days", entry[1], entry[2])
            end, stale_plugins)

            -- Calling the api related to buffer / window directly in a coroutine seems to cause problems
            -- We have to wrap it with a `vim.schedule` call
            vim.schedule(function()
                local report_buf = vim.api.nvim_create_buf(false, true)
                vim.keymap.set("n", "q", "<C-w>c", { buffer = report_buf })

                local win_width = vim.fn.winwidth(0)
                local win_height = vim.fn.winheight(0)
                local report_width = math.floor(win_width * 0.5)
                local report_height = math.min(math.floor(win_height * 0.7), #stale_plugins)
                local row = math.floor((win_height - report_height) / 2)
                local col = math.floor((win_width - report_width) / 2)

                -- If setting end to 0 instead of -1, there would be an empty line at the end
                vim.api.nvim_buf_set_lines(report_buf, 0, -1, false, report)

                local ns_id = vim.api.nvim_create_namespace "out-of-date-plugins"
                for line = 0, really_stale_plugin_count - 1 do
                    vim.api.nvim_buf_add_highlight(report_buf, ns_id, "ErrorMsg", line, 0, -1)
                end
                for line = really_stale_plugin_count, #stale_plugins - 1 do
                    vim.api.nvim_buf_add_highlight(report_buf, ns_id, "WarningMsg", line, 0, -1)
                end

                local win = vim.api.nvim_open_win(report_buf, true, {
                    relative = "win",
                    width = report_width,
                    height = report_height,
                    row = row,
                    col = col,
                    border = "rounded",
                    title = string.format("%d plugins possibly out of date", #stale_plugins),
                    title_pos = "center",
                })

                vim.api.nvim_set_option_value("number", false, { win = win })
                vim.api.nvim_set_option_value("relativenumber", false, { win = win })
                vim.api.nvim_set_option_value("modifiable", false, { buf = report_buf })
            end)
        end)

        while true do
            local item, item_type = vim.uv.fs_scandir_next(dir)

            if not item then
                break
            end

            if item_type == "directory" and item ~= "readme" then
                plugin_count = plugin_count + 1
                vim.system(
                    { "git", "log", "-1", "--format=%cd", "--date=short" },
                    { cwd = plugins_path .. item },
                    function(obj)
                        local date = string.gsub(obj.stdout, "\n", "") -- e.g., "2000-06-15"
                        local year = string.sub(date, 1, 4)
                        local month = string.sub(date, 6, 7)
                        local day = string.sub(date, 9, 10)
                        local last_update_timestamp = os.time { year = year, month = month, day = day }
                        local current_timestamp = os.time()
                        local stale_days = math.floor((current_timestamp - last_update_timestamp) / 86400)
                        if stale_days > 30 then
                            stale_plugins[#stale_plugins + 1] = { item, stale_days }
                        end
                        coroutine.resume(co)
                    end
                )
            end
        end
    end
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
