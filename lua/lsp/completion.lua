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
                },
            },
            keymap = {
                preset = "none",
                ["<Tab>"] = { "accept" },
                ["<C-k>"] = { "select_prev", "fallback" },
                ["<C-j>"] = { "select_next", "fallback" },
            },
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
            trigger = {
                show_on_backspace_in_keyword = true,
            },
        },
        enabled = function()
            local filetype_is_allowed = not vim.tbl_contains({ "grug-far", "TelescopePrompt" }, vim.bo.filetype)

            local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(0))
            local filesize_is_allowed = true
            if ok and stats then
                ---@diagnostic disable-next-line: need-check-nil
                filesize_is_allowed = stats.size < (Ice.max_file_size or (1024 * 1024))
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

                    return cmp.select_and_accept {}
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
                return source
            end,
            providers = {
                snippets = {
                    opts = {
                        search_paths = { vim.fs.joinpath(vim.fn.stdpath "config", "lua/custom/snippets") },
                    },
                },
            },
        },
    },
}
