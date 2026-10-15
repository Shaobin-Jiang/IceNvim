local function profile()
    local buf = vim.api.nvim_create_buf(false, true)
    local ns_id = vim.api.nvim_create_namespace "ice-profile"

    local function create_window()
        local win_width = vim.fn.winwidth(0)
        local win_height = vim.fn.winheight(0)
        local width = 90
        local height = math.floor(win_height * 0.75)
        local left = math.floor((win_width - width) / 2)
        local top = 8

        local win = vim.api.nvim_open_win(buf, true, {
            relative = "win",
            width = width,
            height = height,
            row = top,
            col = left,
            border = "rounded",
            title = "IceNvim Startup Profile",
            title_pos = "center",
            footer = "Press q to close window",
            footer_pos = "center",
        })

        vim.keymap.set("n", "q", "<C-w>c", { buffer = buf })
        vim.api.nvim_set_option_value("number", false, { win = win })
        vim.api.nvim_set_option_value("relativenumber", false, { win = win })
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })
        vim.api.nvim_set_option_value("signcolumn", "no", { win = win })
        vim.api.nvim_set_option_value("cursorline", false, { win = win })
        vim.api.nvim_set_option_value("colorcolumn", "", { win = win })
        vim.api.nvim_set_option_value("fillchars", "eob: ", { win = win })

        vim.api.nvim_create_autocmd("WinClosed", {
            once = true,
            pattern = tostring(win),
            callback = function()
                vim.cmd("bdelete " .. buf)
            end,
        })
    end

    local function modify_buf()
        local total_plugins = 0
        local loaded_plugins = {}
        local not_loaded_plugins = {}
        local disabled_plugins = {}
        for plugin, state in pairs(Ice.__PROFILE.plugins) do
            total_plugins += 1
            if state == "disabled" then
                disabled_plugins[#disabled_plugins + 1] = plugin
            elseif state == "loaded" then
                loaded_plugins[#loaded_plugins + 1] = plugin
            else
                not_loaded_plugins[#not_loaded_plugins + 1] = plugin
            end
        end
        table.sort(loaded_plugins)
        table.sort(not_loaded_plugins)
        table.sort(disabled_plugins)
        if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_buf_is_loaded(buf) then
            return
        end

        ---@type table
        local content = {
            {
                "Startup Time: ",
                {
                    tostring(math.floor(Ice.__PROFILE.startup_time / 1e4 + 0.5) / 100) .. " ms",
                    hl = "RainbowDelimiterViolet",
                },
            },
            { "Total plugins ", { "(" .. tostring(total_plugins) .. ")", hl = "RainbowDelimiterCyan" } },
            "",
            { "Plugins loaded ", { "(" .. tostring(#loaded_plugins) .. ")", hl = "RainbowDelimiterCyan" } },
        }

        for _, plugin in ipairs(loaded_plugins) do
            local trigger_display
            ---@type table?
            local trigger = Ice.__PROFILE.plugins_trigger[plugin]
            if trigger ~= nil then
                if trigger.type == "init" then
                    trigger_display = { "  init", hl = "RainbowDelimiterCyan" }
                elseif trigger.type == "dependency" then
                    trigger_display = { "  " .. trigger.value, hl = "RainbowDelimiterYellow" }
                elseif trigger.type == "event" then
                    trigger_display = { "  " .. trigger.value, hl = "RainbowDelimiterGreen" }
                elseif trigger.type == "ft" then
                    trigger_display = { "  " .. trigger.value, hl = "RainbowDelimiterBlue" }
                elseif trigger.type == "keys" then
                    trigger_display = { " 󰌌 " .. trigger.value, hl = "RainbowDelimiterViolet" }
                elseif trigger.type == "cmd" then
                    trigger_display = { " 󰘳 " .. trigger.value, hl = "RainbowDelimiterOrange" }
                elseif trigger.type == "colorscheme" then
                    trigger_display = { "  colorscheme", hl = "RainbowDelimiterRed" }
                end
            end
            local plugin_state
            if Ice.__PROFILE.plugins_state[plugin] ~= nil then
                local stale_days = Ice.__PROFILE.plugins_state[plugin]
                local hl = "RainbowDelimiterCyan"
                if stale_days > 30 and stale_days <= 365 then
                    hl = "RainbowDelimiterYellow"
                elseif stale_days > 365 then
                    hl = "RainbowDelimiterRed"
                end
                plugin_state = { "    last updated " .. stale_days .. " days ago", hl = hl }
            end
            local line = { { "   ", hl = "RainbowDelimiterBlue" }, plugin, trigger_display }
            local filler_length = 60 - vim.fn.strdisplaywidth(line[1][1]) - vim.fn.strdisplaywidth(line[2])
            if trigger_display ~= nil then
                filler_length -= vim.fn.strdisplaywidth(trigger_display[1])
            end
            line[#line + 1] = string.rep(" ", filler_length)
            line[#line + 1] = plugin_state
            content[#content + 1] = line
        end
        content[#content + 1] = ""

        content[#content + 1] =
            { "Plugins not loaded ", { "(" .. tostring(#not_loaded_plugins) .. ")", hl = "RainbowDelimiterCyan" } }
        for _, plugin in ipairs(not_loaded_plugins) do
            local plugin_state
            if Ice.__PROFILE.plugins_state[plugin] ~= nil then
                local stale_days = Ice.__PROFILE.plugins_state[plugin]
                local hl = "RainbowDelimiterCyan"
                if stale_days > 30 and stale_days <= 365 then
                    hl = "RainbowDelimiterYellow"
                elseif stale_days > 365 then
                    hl = "RainbowDelimiterRed"
                end
                plugin_state = { "    last updated " .. stale_days .. " days ago", hl = hl }
            end

            local line = { { "   ", hl = "RainbowDelimiterBlue" }, plugin }
            local filler_length = 60 - vim.fn.strdisplaywidth(line[1][1]) - vim.fn.strdisplaywidth(line[2])
            line[#line + 1] = string.rep(" ", filler_length)
            line[#line + 1] = plugin_state
            content[#content + 1] = line
        end
        content[#content + 1] = ""

        content[#content + 1] =
            { "Disabled plugins ", { "(" .. tostring(#disabled_plugins) .. ")", hl = "RainbowDelimiterCyan" } }
        for _, plugin in ipairs(disabled_plugins) do
            content[#content + 1] = { { "   ", hl = "RainbowDelimiterRed" }, plugin }
        end

        local _content = {}
        local hl = {}
        for row, line in ipairs(content) do
            if type(line) == "string" then
                _content[#_content + 1] = line
            elseif type(line) == "table" then
                local _line = ""
                for _, part in ipairs(line) do
                    if type(part) == "string" then
                        _line = _line .. part
                    elseif type(part) == "table" then
                        hl[#hl + 1] = { line = row - 1, from = #_line, to = #_line + #part[1], hl = part.hl }
                        _line = _line .. part[1]
                    end
                end
                _content[#_content + 1] = _line
            end
        end

        vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, _content)
        vim.api.nvim_buf_clear_namespace(buf, ns_id, 0, -1)
        for _, part in ipairs(hl) do
            vim.hl.range(buf, ns_id, part.hl, { part.line, part.from }, { part.line, part.to }, {})
        end
        vim.api.nvim_set_option_value("modifiable", false, { buf = buf })

        vim.defer_fn(modify_buf, 40)
    end

    Ice.__PROFILE.plugins_state = {}
    local plugins_path = vim.fs.joinpath(vim.fn.stdpath "data", "site", "pack", "core", "opt")
    local dir = vim.uv.fs_scandir(plugins_path)

    local plugin_count = 0

    if dir ~= nil then
        local co = coroutine.create(function()
            local checked_plugin_count = 1
            while plugin_count > checked_plugin_count do
                coroutine.yield()
                checked_plugin_count = checked_plugin_count + 1
            end

            -- Calling the api related to buffer / window directly in a coroutine seems to cause problems
            -- We have to wrap it with a `vim.schedule` call
            vim.schedule(function()
                create_window()
                modify_buf()
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
                    { cwd = vim.fs.joinpath(plugins_path, item) },
                    function(obj)
                        local date = string.gsub(obj.stdout, "\n", "") -- e.g., "2000-06-15"
                        local year = string.sub(date, 1, 4)
                        local month = string.sub(date, 6, 7)
                        local day = string.sub(date, 9, 10)
                        local last_update_timestamp = os.time { year = year, month = month, day = day }
                        local current_timestamp = os.time()
                        local stale_days = math.floor((current_timestamp - last_update_timestamp) / 86400)
                        Ice.__PROFILE.plugins_state[item] = stale_days
                        coroutine.resume(co)
                    end
                )
            end
        end
    end
end

vim.api.nvim_create_user_command("IceProfile", profile, { nargs = 0 })
vim.api.nvim_create_user_command("IceUpdate", function()
    local plugins = {}
    for plugin, state in pairs(Ice.__PROFILE.plugins) do
        if state ~= "disabled" then
            plugins[#plugins + 1] = plugin
        end
    end
    vim.pack.update(plugins, { force = true })
    vim.system({ "git", "pull" }, { cwd = vim.fn.stdpath "config", text = true }, function(out)
        if out.code == 0 then
            vim.notify "IceNvim up to date"
        else
            vim.notify("IceNvim update failed: " .. out.stderr, vim.log.levels.WARN)
        end
    end)
end, { nargs = 0 })
