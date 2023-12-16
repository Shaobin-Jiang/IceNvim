---@diagnostic disable: need-check-nil
local utils = {}

utils.about = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then
        error "nui.nvim required"
    end

    local text = require "nui.text"
    local line = require "nui.line"
    local width = 80

    local p = popup {
        enter = true,
        focusable = true,
        border = {
            style = "single",
            text = {
                top = "About IceNvim",
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
            width = tostring(width),
            height = "30%",
        },
    }

    p:mount()

    local function render(content, row)
        local l = line()
        l:append(content)
        l:render(p.bufnr, -1, row)
    end

    render("", 1)
    render("A beautiful, powerful and highly customizable neovim config.", 2)
    render("", 3)
    render("Author: Shaobin Jiang", 4)
    render("", 5)
    render("Url: https://github.com/Shaobin-Jiang/IceNvim", 6)
    render("", 7)
    render(string.format("Copyright © 2022-%s Shaobin Jiang", os.date "%Y"), 8)

    p:map("n", "q", function()
        p:unmount()
    end, { noremap = true, silent = true })

    vim.api.nvim_buf_set_option(p.bufnr, "modifiable", false)
    vim.api.nvim_buf_set_option(p.bufnr, "readonly", true)
end

-- Use nui popup to check whether nerd font icons look normal
utils.check_icons = function()
    local status, popup = pcall(require, "nui.popup")
    if not status then
        error "The icon-check functionality requires nui.nvim."
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
                top = "Check Nerd Font Icons",
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
    for name, icon in require("core.utils").ordered_pair(Ice.symbols) do
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

-- Set up colorscheme and Ice.colorscheme, but does not take care of lualine
-- The colorscheme is a table with:
--   - name: to be called with the `colorscheme` command
--   - setup: optional; can either be:
--     - a function called alongside `colorscheme`
--     - a table for plugin setup
--   - background: "light" / "dark"
--   - lualine_theme: optional
---@param colorscheme table
utils.colorscheme = function(colorscheme)
    Ice.colorscheme = colorscheme
    if type(colorscheme.setup) == "table" then
        require(colorscheme.name).setup(colorscheme.setup)
    elseif type(colorscheme.setup) == "function" then
        colorscheme.setup()
    end
    vim.cmd("colorscheme " .. colorscheme.name)
    vim.o.background = colorscheme.background

    vim.api.nvim_set_hl(0, "Visual", { reverse = true })
end

-- Switch colorscheme
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

        local colorschemes = Ice.colorschemes
        local results = {}
        for name, _ in require("core.utils").ordered_pair(colorschemes) do
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

                        if config.background == "light" then
                            ---@diagnostic disable-next-line: param-type-mismatch
                            pcall(vim.cmd, "TransparentDisable")
                        else
                            ---@diagnostic disable-next-line: param-type-mismatch
                            pcall(vim.cmd, "TransparentEnable")
                        end

                        utils.colorscheme(config)

                        local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
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

-- Quickly look through configuration files using telescope
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
        local files = require("plenary.scandir").scan_dir(config_root, { hidden = true })
        local sep = require("plenary.path").path.sep
        local picker_sep = "/" -- sep that is displayed in the picker
        local results = {}

        local make_entry = require("telescope.make_entry").gen_from_file

        for _, item in pairs(files) do
            item = string.gsub(item, config_root, "")
            item = string.gsub(item, sep, picker_sep)
            item = string.sub(item, 2)
            if not (string.find(item, "bin/") or string.find(item, ".git/") or string.find(item, "screenshots/")) then
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

-- Checks whether a lsp client is active
---@param lsp string
---@return boolean
utils.lsp_is_active = function(lsp)
    local active_client = vim.lsp.get_active_clients { name = lsp }
    return #active_client > 0
end

return utils
