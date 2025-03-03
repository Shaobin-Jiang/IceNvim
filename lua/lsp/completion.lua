Ice.plugins["blink-cmp"] = {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets" },
    event = { "InsertEnter", "CmdlineEnter", "User IceLoad" },
    version = "*",
    opts = {
        appearance = {
            kind_icons = Ice.symbols,
        },
        cmdline = {
            completion = {
                menu = {
                    auto_show = true,
                }
            },
            keymap = {
                preset = "none",
                ["<Tab>"] = {"accept"},
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
            }
        },
        completion = {
            accept = {
                auto_brackets = { enabled = true },
            },
            documentation = {
                auto_show = true,
                auto_show_delay_ms = 200,
            },
            ghost_text = {
                enabled = true,
                show_without_selection = true,
            },
            list = {
                selection = {
                    preselect = false,
                    auto_insert = true,
                },
            },
            menu = {
                draw = {
                    columns = {
                        { "label", "label_description", gap = 1 },
                        { "kind_icon" },
                    },
                    treesitter = { "lsp" },
                },
            },
        },
        enabled = function()
            local filetype_is_allowed = not vim.tbl_contains({ "grug-far", "TelescopePrompt" }, vim.bo.filetype)

            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
            local filesize_is_allowed = true
            if ok and stats then
                ---@diagnostic disable-next-line: need-check-nil
                filesize_is_allowed = stats.size < 100 * 1024
            end
            return filetype_is_allowed and filesize_is_allowed
        end,
        keymap = {
            preset = "none",
            ["<Tab>"] = {
                function(cmp)
                    if not cmp.is_menu_visible() then
                        return
                    end

                    local completion_list = require "blink.cmp.completion.list"
                    local selected_id = completion_list.selected_item_idx or 1
                    local item = completion_list.items[selected_id]
                    local source = item.source_name
                    return cmp.select_and_accept {
                        callback = function()
                            if source == "fittencode" then
                                -- Do not just feed a <CR> or keys of such sort
                                -- Should the previous line be a comment, the new line might be a comment as well
                                local line_number = 1
                                local insert_text = item.insertText
                                for _ in string.gmatch(insert_text, "\n") do
                                    line_number = line_number + 1
                                end
                                local row = vim.api.nvim_win_get_cursor(0)[1] + line_number - 1
                                local line = vim.api.nvim_get_current_line()
                                local line_start = string.find(line, "%S") or 1
                                local blank = string.sub(line, 1, line_start - 1)
                                vim.api.nvim_buf_set_lines(0, row, row, true, { blank })
                                vim.api.nvim_win_set_cursor(0, { row + 1, #blank + 1 })

                                -- It seems that I have to defer the next call to fittencode
                                -- Otherwise the completion menu would not show up
                                vim.defer_fn(function()
                                    require("blink.cmp").show { providers = { "fittencode" } }
                                end, 20)
                            end
                        end,
                    }
                end,
                "snippet_forward",
                "fallback",
            },
            ["<S-Tab>"] = { "snippet_backward", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<A-c>"] = {
                -- DO NOT add "fallback" here!!!
                -- It would cause the letter "c" to be inserted as well
                function(cmp)
                    if cmp.is_menu_visible() then
                        cmp.cancel()
                    else
                        cmp.show()
                    end
                end,
            },
            ["<C-d>"] = { "scroll_documentation_down", "fallback" },
            ["<C-u>"] = { "scroll_documentation_up", "fallback" },
        },
        sources = {
            default = function()
                local cmdwin_type = vim.fn.getcmdwintype()
                if cmdwin_type == "/" or cmdwin_type == "?" then
                    return { "buffer" }
                end
                if cmdwin_type == ":" or cmdwin_type == "@" then
                    return { "cmdline" }
                end

                local source = { "lsp", "path", "snippets", "buffer" }
                if Ice.__FITTENCODE_SOURCE_ADDED then
                    source[#source + 1] = "fittencode"
                end
                if vim.bo.filetype == "org" and Ice.__ORGMODE_SOURCE_ADDED then
                    source[#source + 1] = "orgmode"
                end
                return source
            end,
            providers = {
                snippets = {
                    opts = {
                        search_paths = { vim.fn.stdpath "config" .. "/lua/custom/snippets" },
                    },
                },
            },
        },
    },
}
