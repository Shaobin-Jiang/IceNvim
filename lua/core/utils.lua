local version_string = vim.api.nvim_exec("version", true)
local version = string.match(version_string, "NVIM v(%d+.%d+.%d+)")

local function map(mode, lhs, rhs, opt)
    if not opt then
        opt = { noremap = true, silent = true, nowait = true }
    end
    vim.keymap.set(mode, lhs, rhs, opt)
end

local utils = {
    map = map,
    version = version,
}

utils.check_icons = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then
        error "The icon-check functionality requires the nui.nvim plugin."
    end

    local text = require "nui.text"
    local line = require "nui.line"

    local item_width = 24
    local column_number = math.floor(vim.fn.winwidth(0) / item_width) - 1
    local width = tostring(column_number * item_width)
    local win_height = vim.fn.winheight(0)

    local p = popup {
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "Check nerd font icons",
                top_align = "center",
                bottom = "Press q to close window",
                bottom_align = "center",
            },
        },
        buf_options = {
            modifiable = true,
            readonly = false,
        },
        position = "50%",
        size = {
            width = width,
            height = "60%",
        },
    }

    p:mount()

    local count = 0
    local new_line = line()
    local row
    for name, icon in utils.ordered_pair(require("settings").symbols) do
        row = math.floor(count / column_number) + 1
        local index = count % column_number

        if index == 0 then
            if row ~= 1 then
                new_line:render(p.bufnr, -1, row - 1)
            end

            new_line = line()
        end

        local _name = text(name, "Type")
        local _icon = text(icon, "Label")

        new_line:append(_name)
        new_line:append(string.rep(" ", 18 - _name:width()))
        new_line:append(_icon)
        new_line:append(string.rep(" ", item_width - 18 - _icon:width()))

        count = count + 1
    end

    new_line:render(p.bufnr, -1, row)

    p:update_layout {
        size = {
            width = width,
            height = tostring(math.min(row, win_height - 2)),
        },
    }

    p:map("n", "q", function()
        p:unmount()
    end, { noremap = true, silent = true })

    vim.api.nvim_buf_set_option(p.bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(p.bufnr, "readonly", true)
end

utils.colorscheme = function(colorscheme)
    -- Only changes colorscheme without taking care of lualine
    vim.g.user_colorscheme = colorscheme
    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

utils.is_windows = function()
    return vim.loop.os_uname().sysname == "Windows_NT"
end

utils.is_linux = function()
    return vim.loop.os_uname().sysname == "Linux"
end

utils.is_wsl = function()
    local out = string.match(
        vim.api.nvim_exec(
            [[
                    redir => s
                    silent! echo has('wsl')
                    redir END
                ]],
            true
        ),
        "%d"
    )
    return out == "1"
end

utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_active_clients { name = lsp }
    return #active_client > 0
end

-- Maps a group of keymaps with the same opt; if no opt is provided, the default
-- opt is used.
-- The keymaps should be in the format like below:
--     desc = { mode, lhs, rhs, [opt] }
-- For example:
--     black_hole_register = { { "n", "v" }, "\\", '"_' },
-- The desc part will automatically merged into the keymap's opt, unless one is
-- already provided there, with the slight modification of replacing "_" with a
-- blank space.
---@param group table list of keymaps
---@param opt table default opt
utils.group_map = function(group, opt)
    for desc, keymap in pairs(group) do
        desc = string.gsub(desc, "_", " ")
        local default_option = vim.tbl_extend(
            "force",
            { desc = desc, noremap = true, nowait = true, silent = true },
            opt
        )
        local map = vim.tbl_deep_extend(
            "force",
            { nil, nil, nil, default_option },
            keymap
        )
        vim.keymap.set(map[1], map[2], map[3], map[4])
    end
end

utils.map_group = function(group, opt)
    for _, item in pairs(group) do
        local option
        if not opt then
            option = item.opt
        elseif not item.opt then
            option = opt
        else
            option = vim.tbl_extend("force", opt, item.opt)
        end
        map(item.mode, item[1], item[2], option)
    end
end

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

utils.select_colorscheme = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"

    local function picker(opts)
        opts = opts or {}

        local colorschemes = require "core.colorscheme"
        local results = {}
        for name, _ in utils.ordered_pair(colorschemes) do
            results[#results + 1] = name
        end

        pickers
            .new(opts, {
                prompt_title = "Colorschemes",
                finder = finders.new_table {
                    entry_maker = function(entry)
                        return {
                            value = entry,
                            display = entry,
                            ordinal = entry,
                        }
                    end,
                    results = results,
                },
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)

                        local selection = action_state.get_selected_entry()
                        local config = colorschemes[selection.value]
                        utils.colorscheme(config)
                        require("plugins.config").lualine()

                        local colorscheme_cache = vim.fn.stdpath "data"
                            .. "/colorscheme"
                        local f = io.open(colorscheme_cache, "w")
                        f:write(selection.value)
                        f:close()
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

utils.view_configuration = function()
    local status, _ = pcall(require, "telescope")
    if not status then
        return
    end

    local pickers = require "telescope.pickers"
    local finders = require "telescope.finders"
    local conf = require("telescope.config").values
    local actions = require "telescope.actions"
    local action_state = require "telescope.actions.state"
    local previewers = require "telescope.previewers.buffer_previewer"
    local from_entry = require "telescope.from_entry"

    local function picker(opts)
        opts = opts or {}

        local config_root = vim.fn.stdpath "config"
        local files =
            require("plenary.scandir").scan_dir(config_root, { hidden = true })
        local sep = require("plenary.path").path.sep
        local picker_sep = "/" -- sep that is displayed in the picker
        local results = {}

        local make_entry = require("telescope.make_entry").gen_from_file

        for _, item in pairs(files) do
            item = string.gsub(item, config_root, "")
            item = string.gsub(item, sep, picker_sep)
            item = string.sub(item, 2)
            if
                not (
                    string.find(item, "bin/")
                    or string.find(item, ".git/")
                    or string.find(item, "screenshots/")
                )
            then
                results[#results + 1] = item
            end
        end

        pickers
            .new(opts, {
                prompt_title = "Configuration Files",
                finder = finders.new_table {
                    entry_maker = make_entry(opts),
                    results = results,
                },
                previewer = (function(_opts)
                    _opts = _opts or {}
                    return previewers.new_buffer_previewer {
                        title = "Configuration",
                        get_buffer_by_name = function(_, entry)
                            return from_entry.path(entry, false)
                        end,
                        define_preview = function(self, entry)
                            local p = config_root .. "/" .. entry.filename
                            if p == nil or p == "" then
                                return
                            end
                            conf.buffer_previewer_maker(p, self.state.bufnr, {
                                bufname = self.state.bufname,
                                winid = self.state.winid,
                                preview = _opts.preview,
                                file_encoding = _opts.file_encoding,
                            })
                        end,
                    }
                end)(opts),
                sorter = conf.generic_sorter(opts),
                attach_mappings = function(prompt_bufnr, _)
                    actions.select_default:replace(function()
                        actions.close(prompt_bufnr)

                        local selection = action_state.get_selected_entry()[1]
                        selection = string.gsub(selection, picker_sep, sep)
                        local full_path = config_root .. sep .. selection

                        vim.cmd("edit " .. full_path)
                    end)
                    return true
                end,
            })
            :find()
    end

    picker()
end

return utils
