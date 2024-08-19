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
            mapping = Ice.keymap.lsp.cmp(cmp),
            formatting = {
                format = lspkind.cmp_format {
                    mode = "symbol",
                    maxwidth = 50,
                },
            },
        }

        cmp.setup.cmdline({ "/", "?" }, {
            mapping = cmp.mapping.preset.cmdline(),
            sources = {
                { name = "buffer" },
            },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                { name = "cmdline" },
            }),
        })

        local cmp_autopairs = require "nvim-autopairs.completion.cmp"
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done { map_char = { tex = "" } })

        require("luasnip.loaders.from_vscode").lazy_load { paths = vim.fn.stdpath "data" .. "/lazy/friendly-snippets" }
    end,
}
