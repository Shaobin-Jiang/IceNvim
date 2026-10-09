local specs = {}
Ice.__COLORSCHME_PLUGINS = {}

---@type table<string, any>
local pack_changed_autocmd = {}

local function get_spec_name(path)
    local parts = vim.fn.split(path, "/")
    return parts[#parts]
end

-- Add plugin to `vim.pack.add` spec list
--
---@param plugin table IceNvim-format plugin spec
---@param is_dependency boolean? whether this is a dependency plugin; only applies when explicitly set to `true`
---@param name string? optional pretty name for the plugin
local function packadd(plugin, is_dependency, name)
    local enabled = plugin.enabled
    if (type(enabled) == "boolean" and enabled == false) or (type(enabled) == "function" and enabled() == false) then
        return
    end

    -- INFO: breaking change: fields like `branch` should all be renamed to `version`
    local src = plugin[1]
    if not vim.startswith(src, "http") then
        src = "https://github.com/" .. src
    end
    local spec = { src = src, version = plugin.version, data = {} }
    if is_dependency == true then
        spec.data.is_dependency = true
    end
    if name == nil or #name == 0 then
        name = "__" .. plugin[1] -- not explicitly added to `Ice.plugins`; use "__" as a precaution
        Ice.plugins[name] = plugin
    end
    spec.data.pretty_name = name
    specs[#specs + 1] = spec

    if plugin.build ~= nil then
        if type(plugin.build) == "function" or type(plugin.build) == "string" then
            pack_changed_autocmd[get_spec_name(plugin[1])] = true
        end
    end

    -- Handle dependencies
    if type(plugin.dependencies) == "table" then
        for _, dependency in ipairs(plugin.dependencies) do
            if type(dependency) == "string" then
                dependency = { dependency }
            end

            if type(dependency) == "table" then
                packadd(dependency, true)
            end
        end
    end
end

local function packadd_all_dependencies(source)
    if type(source.dependencies) == "table" then
        for _, dependency in ipairs(source.dependencies) do
            if type(dependency) == "table" then
                dependency = dependency[1]
            end
            vim.cmd.packadd(get_spec_name(dependency))
        end
    end
end

for name, config in pairs(Ice.plugins) do
    packadd(config, false, name)
end

local augroup = vim.api.nvim_create_augroup("IcePack", { clear = true })

-- Must be placed before `vim.pack.add`
vim.api.nvim_create_autocmd("PackChanged", {
    group = augroup,
    callback = function(ev)
        local name = ev.data.spec.name
        if not (ev.data.kind == "update" or ev.data.kind == "install") or pack_changed_autocmd[name] == nil then
            return
        end

        local plugin = Ice.plugins[ev.data.spec.data.pretty_name]
        local callback
        if type(plugin.build) == "string" then
            if vim.startswith(plugin.build, ":") then
                callback = function()
                    vim.cmd(plugin.build)
                end
            else
                callback = function()
                    -- FIX: windows version
                    vim.system({ "bash", "-c", plugin.build }, { cwd = ev.data.path, text = true })
                end
            end
        else
            callback = plugin.build
        end

        packadd_all_dependencies(plugin)
        if not ev.data.active then
            vim.cmd.packadd(name)
        end

        -- Postpone building to after all plugins are installed
        vim.api.nvim_create_autocmd("User", {
            group = augroup,
            once = true,
            pattern = "IcePackDone",
            callback = function()
                vim.notify("Running build script for " .. name)
                if type(callback) == "function" then
                    callback()
                end
            end,
        })
    end,
})

-- Event / Ft and the correponding list of plugin names
---@type table<vim.api.keyset.events, string[]>
local event_load = {}
---@type table<string, string[]>
local ft_load = {}

---@type table<string, function>
local load_functions = {}

vim.pack.add(specs, {
    confirm = false,
    -- Installs the plugins but does not load anything
    -- Setting `load` to `false` is not enough because it still adds it to the runtimepath
    load = function(plug_data)
        local path = plug_data.path
        local spec = plug_data.spec
        local name = spec.name or ""

        local data = spec.data
        -- Data from `Ice.plugins`; not using the `data` field of `vim.pack.add` because it needs to be a dictionary or
        -- neovim will start making strange complaints (probably because conversion to vimscript is involved)
        local source = Ice.plugins[data.pretty_name]

        if type(source.init) == "function" then
            source.init()
        end

        -- Record colorscheme plugins
        local possible_colors_dir = vim.fs.joinpath(path, "colors")
        if vim.uv.fs_stat(possible_colors_dir) then
            local dir = vim.uv.fs_scandir(possible_colors_dir)
            if dir ~= nil then
                while true do
                    local item, item_type = vim.uv.fs_scandir_next(dir)
                    if
                        item_type == "file"
                        and item ~= nil
                        and (string.match(item, "%.vim$") or string.match(item, "%.lua$"))
                    then
                        local colorscheme = vim.split(item, "%.")[1]
                        Ice.__COLORSCHME_PLUGINS[colorscheme] = name
                    else
                        if item == nil then
                            break
                        end
                    end
                end
            end
        end

        -- Lazy load all dependencies
        if data.is_dependency == true then
            return
        end

        local load_function = function()
            -- MUST go before `packadd`-ing the main plugin or plugins such as blink.cmp will raise errors
            packadd_all_dependencies(source)

            vim.cmd.packadd(name)

            local opts = {}
            if type(source.opts) == "table" then
                opts = source.opts
            end

            -- INFO: breaking change: `config` receives just one argument
            if type(source.config) == "function" then
                source.config(opts)
            else
                -- Heuristic-based main module identification
                local main = source.main
                if main == nil then
                    local options = vim.list.unique {
                        -- should go first; mainly because nvim-tree.lua has a `nvim-tree.lua` file and a `nvim-tree`
                        -- directory simultaneously
                        (string.gsub(name, "%.lua$", "")),
                        name,
                        (string.gsub(name, "%.nvim$", "")),
                        (string.gsub(name, "%-nvim$", "")),
                        (string.gsub(name, "^nvim%-", "")),
                    }

                    for _, option in ipairs(options) do
                        if vim.uv.fs_stat(vim.fs.joinpath(path, "lua", option)) then
                            main = option
                            break
                        end
                    end
                end

                if main ~= nil then
                    require(main).setup(opts)
                end
            end

            vim.api.nvim_exec_autocmds("User", { pattern = "IceAfter " .. data.pretty_name })
        end

        -- Do not lazy load if:
        -- - `lazy` is set to `false`
        -- - `lazy` is neither `true` or `false`, and none of `cmd` / `event` / `ft` / `keys` are set
        if
            (type(source.lazy) == "boolean" and source.lazy == false)
            or (type(source.lazy) == "function" and source.lazy() == false)
            or (
                source.lazy ~= true
                and source.cmd == nil
                and source.event == nil
                and source.ft == nil
                and source.keys == nil
            )
        then
            load_function()
            return
        end

        if source.event ~= nil then
            ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
            local events = source.event
            if type(source.event) == "string" then
                events = { source.event }
            end
            for _, event in ipairs(events) do
                if event_load[event] == nil then
                    event_load[event] = {}
                end
                event_load[event][#event_load[event] + 1] = name
            end
        end

        if source.ft ~= nil then
            ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
            local fts = source.ft
            if type(source.ft) == "string" then
                fts = { source.ft }
            end
            for _, ft in ipairs(fts) do
                if ft_load[ft] == nil then
                    ft_load[ft] = {}
                end
                ft_load[ft][#ft_load[ft] + 1] = name
            end
        end

        if type(source.keys) == "table" then
            local keymap_group = {}
            for _, keymap in ipairs(source.keys) do
                local lhs = keymap[1]
                local rhs = keymap[2]
                local mode = keymap.mode or "n"
                local opts = {}
                for k, v in pairs(keymap) do
                    if type(k) == "number" or k == "mode" or k == "ft" then
                        continue
                    end
                    opts[k] = v
                end
                if keymap.ft ~= nil then
                    keymap_group[#keymap_group + 1] = function()
                        vim.api.nvim_create_autocmd("FileType", {
                            pattern = keymap.ft,
                            callback = function()
                                vim.keymap.set(
                                    mode,
                                    lhs,
                                    rhs,
                                    vim.tbl_extend("force", { buffer = vim.fn.bufnr() }, opts)
                                )
                            end,
                        })
                    end
                else
                    keymap_group[#keymap_group + 1] = function()
                        vim.keymap.set(mode, lhs, rhs, opts)
                    end
                end
                vim.keymap.set(mode, lhs, function()
                    local ft = vim.bo.filetype
                    if
                        keymap.ft == nil
                        or ft == keymap.ft
                        or (type(keymap.ft) == "table" and vim.list_contains(keymap.ft, ft))
                    then
                        load_function()
                        vim.api.nvim_exec_autocmds("FileType", { pattern = ft })
                        local keys = vim.api.nvim_replace_termcodes(lhs, true, true, true)
                        vim.api.nvim_feedkeys(keys, "m", false)
                    end
                end, opts)
            end

            local _old_load_function = load_function
            load_function = function()
                _old_load_function()
                for _, cb in ipairs(keymap_group) do
                    cb()
                end
            end
        end

        if source.cmd ~= nil then
            ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
            local cmds = source.cmd
            if type(source.cmd) == "string" then
                cmds = { source.cmd }
            end

            for _, cmd in ipairs(cmds) do
                -- Based on lazy.nvim
                vim.api.nvim_create_user_command(cmd, function(event)
                    local command = {
                        cmd = cmd,
                        bang = event.bang or nil,
                        mods = event.smods,
                        args = event.fargs,
                        count = event.count >= 0 and event.range == 0 and event.count or nil,
                    }

                    if event.range == 1 then
                        command.range = { event.line1 }
                    elseif event.range == 2 then
                        command.range = { event.line1, event.line2 }
                    end

                    load_function()

                    local info = vim.api.nvim_get_commands({})[cmd] or vim.api.nvim_buf_get_commands(0, {})[cmd]
                    if not info then
                        return
                    end

                    command.nargs = info.nargs
                    if event.args and event.args ~= "" and info.nargs and info.nargs:find "[1?]" then
                        command.args = { event.args }
                    end
                    vim.cmd(command)
                end, {
                    bang = true,
                    range = true,
                    nargs = "*",
                    complete = function(_, line)
                        load_function()
                        return vim.fn.getcompletion(line, "cmdline")
                    end,
                })

                local _old_load_function = load_function
                load_function = function()
                    vim.api.nvim_del_user_command(cmd)
                    _old_load_function()
                end
            end
        end

        load_functions[name] = load_function
    end,
})
vim.api.nvim_exec_autocmds("User", { pattern = "IcePackDone" })

for event, plugins in pairs(event_load) do
    local opts = {
        once = true,
        group = augroup,
        callback = function()
            for _, name in ipairs(plugins) do
                if type(load_functions[name]) == "function" then
                    load_functions[name]()
                    load_functions[name] = nil
                end
            end
        end,
    }

    ---@diagnostic disable: assign-type-mismatch, param-type-mismatch
    if event == "VeryLazy" or vim.startswith(event, "Ice") then
        opts.pattern = event
        event = "User"
    else
        local pos = string.find(event, " ")
        if pos ~= nil then
            opts.pattern = string.sub(event, pos + 1)
            event = string.sub(event, 1, pos - 1)
        end
    end
    vim.api.nvim_create_autocmd(event, opts)
end

for ft, plugins in pairs(ft_load) do
    local opts = {
        once = true,
        group = augroup,
        pattern = ft,
        callback = function()
            for _, name in ipairs(plugins) do
                if type(load_functions[name]) == "function" then
                    load_functions[name]()
                    load_functions[name] = nil
                end
            end
        end,
    }
    vim.api.nvim_create_autocmd("FileType", opts)
end

-- Create VeryLazy event
vim.api.nvim_create_autocmd("VimEnter", {
    group = augroup,
    once = true,
    callback = function()
        local second, microsecond = vim.uv.gettimeofday()
        if second ~= nil then
            Ice.__startup_time = (second * 1e9 + microsecond * 1000 - vim.v.starttime) / 1e6
        end
        vim.schedule(function()
            vim.api.nvim_exec_autocmds("User", { pattern = "VeryLazy" })
        end)
    end,
})

-- Create IceLoad event
vim.api.nvim_create_autocmd("User", {
    pattern = "IceAfter colorscheme",
    callback = function()
        local function should_trigger()
            return vim.bo.filetype ~= "dashboard" and vim.api.nvim_buf_get_name(0) ~= ""
        end

        local function trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "IceLoad" })
        end

        if should_trigger() then
            trigger()
            return
        end

        local ice_load = 0
        ice_load = vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if should_trigger() then
                    trigger()
                    vim.api.nvim_del_autocmd(ice_load)
                end
            end,
        })
    end,
})
