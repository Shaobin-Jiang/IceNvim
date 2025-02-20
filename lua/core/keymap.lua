vim.g.mapleader = " "
vim.g.maplocalleader = ","

-- Generates a comment function that can be used in a keymap
--
-- Uses the buffer's local commentstring to add a comment; the "%s" in the commentstring is removed
-- Upon the addition of a comment, the user ends up in insert mode, with the cursor at the exact same position as the %s
-- Adding a comment at the end of a line will have a blank before it only if the line is non-blank.
--
---@param pos string Can be one of "above" / "below" / "end"; indicates where the comment is to be inserted
local function comment(pos)
    return function()
        local row = vim.api.nvim_win_get_cursor(0)[1]
        local total_lines = vim.api.nvim_buf_line_count(0)
        local commentstring = vim.bo.commentstring
        local cmt = string.gsub(commentstring, "%%s", "")
        local index = string.find(commentstring, "%%s")

        local target_line
        if pos == "below" then
            -- Uses the same indentation as the next line if we are adding a comment below
            -- We have to consider whether the current line is the last one in the buffer
            if row == total_lines then
                target_line = vim.api.nvim_buf_get_lines(0, row - 1, row, true)[1]
            else
                target_line = vim.api.nvim_buf_get_lines(0, row, row + 1, true)[1]
            end
        else
            target_line = vim.api.nvim_get_current_line()
        end

        if pos == "end" then
            -- Only insert a blank space before the comment if the current line is non-blank
            if string.find(target_line, "%S") then
                cmt = " " .. cmt
                index = index + 1
            end
            vim.api.nvim_buf_set_lines(0, row - 1, row, false, { target_line .. cmt })
            vim.api.nvim_win_set_cursor(0, { row, #target_line + index - 2 })
        else
            -- Get the index of the first non blank character
            local line_start = string.find(target_line, "%S") or (#target_line + 1)
            local blank = string.sub(target_line, 1, line_start - 1)

            if pos == "above" then
                vim.api.nvim_buf_set_lines(0, row - 1, row - 1, true, { blank .. cmt })
                vim.api.nvim_win_set_cursor(0, { row, #blank + index - 2 })
            end

            if pos == "below" then
                vim.api.nvim_buf_set_lines(0, row, row, true, { blank .. cmt })
                vim.api.nvim_win_set_cursor(0, { row + 1, #blank + index - 2 })
            end
        end

        vim.api.nvim_feedkeys("a", "n", false)
    end
end

-- If the line is not empty, apply gcc. Otherwise, add a comment to it
-- This is necessary as the default gcc does not work on blank lines
local function comment_line()
    local line = vim.api.nvim_get_current_line()

    local row = vim.api.nvim_win_get_cursor(0)[1]
    local commentstring = vim.bo.commentstring
    local cmt = string.gsub(commentstring, "%%s", "")
    local index = string.find(commentstring, "%%s")

    if not string.find(line, "%S") then
        vim.api.nvim_buf_set_lines(0, row - 1, row, false, { line .. cmt })
        vim.api.nvim_win_set_cursor(0, { row, #line + index - 1 })
    else
        -- WARN: I have no clue as to why neovim is not including this in its official documentations
        -- It is possible that the api will be renamed in future releases
        require("vim._comment").toggle_lines(row, row, { row, 0 })
    end
end

-- <count>J joins <count> + 1 lines
local function join_lines()
    local v_count = vim.v.count1 + 1
    local mode = vim.api.nvim_get_mode().mode
    local keys
    if mode == "n" then
        keys = v_count .. "J"
    else
        keys = "J"
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
end

-- Open the current html file with the default browser.
local function open_html_file()
    if vim.bo.filetype == "html" then
        local utils = require "core.utils"
        local command
        if utils.is_linux or utils.is_wsl then
            command = "xdg-open"
        elseif utils.is_windows then
            command = "explorer"
        else
            command = "open"
        end
        if require("core.utils").is_windows then
            local old_shellslash = vim.opt.shellslash
            vim.opt.shellslash = false
            vim.cmd(string.format('silent exec "!%s %%:p"', command))
            vim.opt.shellslash = old_shellslash
        else
            vim.cmd(string.format('silent exec "!%s %%:p"', command))
        end
    end
end

-- Save when the buffer is modified
local function save_file()
    local buffer_is_modified = vim.api.nvim_get_option_value("modified", { buf = 0 })
    if buffer_is_modified then
        vim.cmd "write"
    else
        print "Buffer not modified. No writing is done."
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
end

-- When evoked under normal / insert / visual mode, call vim's `undo` command and then go to normal mode.
local function undo()
    local mode = vim.api.nvim_get_mode().mode

    -- Only undo in normal / insert / visual mode
    if mode == "n" or mode == "i" or mode == "v" then
        vim.cmd "undo"
        -- Back to normal mode
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "n", false)
    end
end

-- Determine in advance what shell to use for the <C-t> keymap
local terminal_command
if not require("core.utils").is_windows then
    terminal_command = "<Cmd>split | terminal<CR>" -- let $SHELL decide the default shell
else
    local executables = { "pwsh", "powershell", "bash", "cmd" }
    for _, executable in require("core.utils").ordered_pair(executables) do
        if vim.fn.executable(executable) == 1 then
            terminal_command = "<Cmd>split term://" .. executable .. "<CR>"
            break
        end
    end
end

Ice.keymap = {}
Ice.keymap.general = {
    -- See `:h quote_`
    black_hole_register = { { "n", "v" }, "\\", '"_' },
    clear_cmd_line = { { "n", "i", "v", "t" }, "<C-g>", "<Cmd>mode<CR>" },
    cmd_forward = { "c", "<C-f>", "<Right>", { silent = false } },
    cmd_backward = { "c", "<C-b>", "<Left>", { silent = false } },
    cmd_home = { "c", "<C-a>", "<Home>", { silent = false } },
    cmd_end = { "c", "<C-e>", "<End>", { silent = false } },
    cmd_word_forward = { "c", "<A-f>", "<S-Right>", { silent = false } },
    cmd_word_backward = { "c", "<A-b>", "<S-Left>", { silent = false } },

    comment_line = { "n", "gcc", comment_line },
    comment_above = { "n", "gcO", comment "above" },
    comment_below = { "n", "gco", comment "below" },
    comment_end = { "n", "gcA", comment "end" },

    disable_right_mouse = { { "n", "i", "v", "t" }, "<RightMouse>", "<LeftMouse>" },

    join_lines = { { "n", "v" }, "J", join_lines },

    -- Move the cursor through wrapped lines with j and k
    -- https://github.com/NvChad/NvChad/blob/b9963e29b21a672325af5b51f1d32a9191abcdaa/lua/core/mappings.lua#L40C5-L41C99
    move_down = { "n", "j", 'v:count || mode(1)[0:1] == "no" ? "j" : "gj"', { expr = true } },
    move_up = { "n", "k", 'v:count || mode(1)[0:1] == "no" ? "k" : "gk"', { expr = true } },

    new_line_below_normal = { "n", "<A-o>", "o<Esc>" },
    new_line_above_normal = { "n", "<A-O>", "O<Esc>" },

    open_html_file = { "n", "<A-b>", open_html_file },
    open_terminal = { "n", "<C-t>", terminal_command },
    normal_mode_in_terminal = { "t", "<Esc>", "<C-\\><C-n>" },
    save_file = { { "n", "i", "v" }, "<C-s>", save_file },
    undo = { { "n", "i", "v", "t", "c" }, "<C-z>", undo },
    visual_line = { "n", "V", "0v$" },
}
