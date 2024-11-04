local symbols = Ice.symbols

Ice.plugins["nvim-cmp"] = {
    "hrsh7th/nvim-cmp",
    dependencies = {
        "L3MON4D3/LuaSnip",
        "saadparwaiz1/cmp_luasnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind-nvim",
    },
    event = { "InsertEnter", "CmdlineEnter", "User IceLoad" },
    config = function()
        local lspkind = require "lspkind"
        lspkind.init {
            mode = "symbol",
            preset = "codicons",
            symbol_map = {
                Text = symbols.Text,
                Method = symbols.Method,
                Function = symbols.Function,
                Constructor = symbols.Constructor,
                Field = symbols.Field,
                Variable = symbols.Variable,
                Class = symbols.Class,
                Interface = symbols.Interface,
                Module = symbols.Module,
                Property = symbols.Property,
                Unit = symbols.Unit,
                Value = symbols.Value,
                Enum = symbols.Enum,
                Keyword = symbols.Keyword,
                Snippet = symbols.Snippet,
                Color = symbols.Color,
                File = symbols.File,
                Reference = symbols.Reference,
                Folder = symbols.Folder,
                EnumMember = symbols.EnumMember,
                Constant = symbols.Constant,
                Struct = symbols.Struct,
                Event = symbols.Event,
                Operator = symbols.Operator,
                TypeParameter = symbols.TypeParameter,
            },
        }

        local cmp = require "cmp"

        local cmp_func = {
            toggle_completion = cmp.mapping {
                i = function()
                    if cmp.visible() then
                        cmp.abort()
                    else
                        cmp.complete()
                    end
                end,
                c = function()
                    if cmp.visible() then
                        cmp.close()
                    else
                        cmp.complete()
                    end
                end,
            },
            prev_item = cmp.mapping(cmp.mapping.select_prev_item(), { "i", "c" }),
            next_item = cmp.mapping(cmp.mapping.select_next_item(), { "i", "c" }),
            confirm = cmp.mapping(
                cmp.mapping.confirm {
                    select = true,
                    behavior = cmp.ConfirmBehavior.Insert,
                },
                { "i", "c" }
            ),
            doc_up = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i" }),
            doc_down = cmp.mapping(cmp.mapping.scroll_docs(4), { "i" }),
        }

        local cmp_keymap = {}
        for command, key in pairs(Ice.keymap.lsp.cmp) do
            local func = cmp_func[command]
            if func then
                cmp_keymap[key] = func
            end
        end

        cmp.setup {
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
            sources = cmp.config.sources({
                { name = "nvim_lsp" },
                { name = "luasnip" },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
            mapping = cmp_keymap,
            formatting = {
                format = lspkind.cmp_format {
                    mode = "symbol",
                    maxwidth = 50,
                },
            },
        }

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp_keymap,
            sources = {
                { name = "buffer" },
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp_keymap,
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })

        vim.api.nvim_create_autocmd("CmdwinEnter", {
            pattern = { ":", "/", "?" },
            callback = function(args)
                local match = args.match

                if match == ":" then
                    cmp.setup.buffer {
                        mapping = cmp_keymap,
                        sources = cmp.config.sources({
                            { name = "path" },
                        }, {
                            { name = "cmdline" },
                        }),
                    }
                end

                if match == "/" or "match" == "?" then
                    cmp.setup.buffer {
                        mapping = cmp_keymap,
                        sources = {
                            { name = "buffer" },
                        },
                    }
                end
            end,
        })

        local cmp_autopairs = require "nvim-autopairs.completion.cmp"
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

        require("luasnip.loaders.from_vscode").lazy_load { paths = vim.fn.stdpath "data" .. "/lazy/friendly-snippets" }
    end,
}
