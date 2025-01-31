Ice.plugins["blink-cmp"] = {
    "saghen/blink.cmp",
    dependencies = {
        "rafamadriz/friendly-snippets",
        "onsails/lspkind-nvim",
    },
    event = { "InsertEnter", "CmdlineEnter", "User IceLoad" },
    version = "*",
    opts = {
        appearance = {
            kind_icons = Ice.symbols,
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
        keymap = {
            preset = "none",
            ["<Tab>"] = {
                function(cmp)
                    if cmp.snippet_active() then
                        return cmp.accept()
                    else
                        return cmp.select_and_accept()
                    end
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
            per_filetype = {
                org = { "orgmode", "path", "snippets", "buffer" },
            },
            default = function()
                local cmdwin_type = vim.fn.getcmdwintype()
                if cmdwin_type == "/" or cmdwin_type == "?" then
                    return { "buffer" }
                end
                if cmdwin_type == ":" or cmdwin_type == "@" then
                    return { "cmdline" }
                end
                return { "lsp", "path", "snippets", "buffer", "fittencode" }
            end,
            cmdline = function()
                local cmd_type = vim.fn.getcmdtype()
                if cmd_type == "/" or cmd_type == "?" then
                    return { "buffer" }
                end
                if cmd_type == ":" or cmd_type == "@" then
                    return { "cmdline" }
                end
                return {}
            end,
            providers = {
                snippets = {
                    opts = {
                        search_paths = { vim.fn.stdpath "config" .. "/lua/custom" },
                    },
                },
                fittencode = {
                    name = "fittencode",
                    module = "fittencode.sources.blink",
                    fallbacks = { "buffer" },
                },
                orgmode = {
                    name = "Orgmode",
                    module = "orgmode.org.autocompletion.blink",
                    fallbacks = { "buffer" },
                },
            },
        },
    },
}
