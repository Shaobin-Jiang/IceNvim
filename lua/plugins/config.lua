-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local _config = {}

local function init(plugin, config)
    local status, p = pcall(require, plugin)
    if not status then
        vim.notify("Plugin not found: " .. plugin)
        return nil
    else
        p.setup(config)
        return p
    end
end

_config.bufferline = function()
    local symbols = require("settings").symbols
    init("bufferline", {
        options = {
            close_command = "bdelete! %d",
            right_mouse_command = "bdelete! %d",
            separator_style = "thin",
            offsets = {
                {
                    filetype = "NvimTree",
                    text = "File Explorer",
                    highlight = "Directory",
                    text_align = "left",
                },
            },
            diagnostics = "nvim_lsp",
            diagnostics_indicator = function(_, _, diagnostics_dict, _)
                local s = " "
                for e, n in pairs(diagnostics_dict) do
                    local sym = e == "error" and symbols.Error
                        or (e == "warning" and symbols.Warn or symbols.Info)
                    s = s .. n .. sym
                end
                return s
            end,
        },
    })

    -- disable transparency for bufferline
    vim.g.transparent_exclude_groups = vim.list_extend(
        vim.g.transparent_exclude_groups or {},
        vim.tbl_map(function(v)
            return v.hl_group
        end, vim.tbl_values(require("bufferline.config").highlights))
    )
end

_config.colorizer = function()
    init("colorizer", {
        filetypes = {
            "*",
            css = {
                names = true,
            },
        },
        user_default_options = {
            css = true,
            css_fn = true,
            names = false,
            always_update = true,
        },
    })
end

_config.comment = function()
    init("Comment", require("settings").plugin.keymap._comment)
end

_config.dashboard = function()
    local config_root = string.gsub(vim.fn.stdpath "config", "\\", "/")

    init("dashboard", {
        theme = "doom",
        config = {
            header = {
                " ",
                "███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗",
                "████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║",
                "██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║",
                "██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝",
                " ",
                string.format(
                    "                      %s                       ",
                    require("core.utils").version
                ),
                " ",
            },
            center = {
                {
                    icon = "  ",
                    desc = "Lazy Profile",
                    action = "Lazy profile",
                },
                {
                    icon = "  ",
                    desc = "Edit preferences   ",
                    action = string.format(
                        "edit %s/lua/user-config.lua",
                        config_root
                    ),
                },
            },
            footer = { "Work hard, and enjoy coding with vim." },
        },
    })
end

_config["flutter-tools"] = function()
    init("flutter-tools", {
        ui = {
            border = "rounded",
            notification_style = "nvim-notify",
        },
        decorations = {
            statusline = {
                app_version = true,
                device = true,
            },
        },
        lsp = {
            on_attach = function(_, bufnr)
                require("lsp.utils").keyAttach(bufnr)
            end,
        },
    })
end

_config.gitsigns = function()
    init("gitsigns", {})
end

_config.hop = function()
    init("hop", {
        hint_position = require("hop.hint").HintPosition.END,
        keys = "fjghdksltyrueiwoqpvbcnxmza",
    })
end

_config["indent-blankline"] = function()
    init("ibl", {
        exclude = {
            filetypes = {
                "dashboard",
                "terminal",
                "help",
                "log",
                "markdown",
                "TelescopePrompt",
                "lsp-installer",
                "lspinfo",
            },
        },
    })
end

_config.lualine = function()
    local symbols = require("settings").symbols
    init("lualine", {
        options = {
            theme = vim.g.user_colorscheme.lualine_theme,
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "undotree", "diff", "Outline" },
        },
        extensions = { "nvim-tree" },
        sections = {
            lualine_b = {
                "branch",
                "diff",
            },
            lualine_c = {
                "filename",
                {
                    "lsp_progress",
                    spinner_symbols = {
                        symbols.Dice1,
                        symbols.Dice2,
                        symbols.Dice3,
                        symbols.Dice4,
                        symbols.Dice5,
                        symbols.Dice6,
                    },
                },
            },
            lualine_x = {
                "filesize",
                {
                    "fileformat",
                    symbols = {
                        unix = symbols.Unix,
                        dos = symbols.Dos,
                        mac = symbols.Mac,
                    },
                },
                "encoding",
                "filetype",
            },
        },
    })
end

_config["markdown-preview"] = function()
    vim.g.mkdp_filetypes = { "markdown" }
    vim.g.mkdp_auto_close = 0
end

_config.neogit = function()
    init("neogit", {
        status = {
            recent_commit_count = 30,
        }
    })
end

_config.neorg = function()
    require("nvim-web-devicons").set_icon {
        norg = {
            icon = require("nvim-web-devicons").get_icon "file.org",
        },
    }

    init("neorg", {
        load = {
            ["core.defaults"] = {},
            ["core.completion"] = {
                config = {
                    engine = "nvim-cmp",
                },
            },
            ["core.concealer"] = {},
            ["core.dirman"] = {
                config = {
                    workspaces = {
                        notes = "~/notes",
                    },
                },
            },
            ["core.summary"] = {},
        },
    })
end

_config.neoscroll = function()
    init("neoscroll", {
        mappings = { "<C-u>", "<C-d>" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "sine",
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
    })
end

_config["nvim-autopairs"] = function()
    init("nvim-autopairs", {
        check_ts = true,
        ts_config = {
            lua = { "string" },
            javascript = { "template_string" },
            java = false,
        },
    })
end

_config["nvim-cmp"] = function()
    local cmp_autopairs = require "nvim-autopairs.completion.cmp"
    ---@diagnostic disable-next-line: different-requires
    local cmp = require "cmp"
    cmp.event:on(
        "confirm_done",
        cmp_autopairs.on_confirm_done { map_char = { tex = "" } }
    )
end

_config["nvim-notify"] = function()
    init("notify", {
        timeout = 3000,
        background_colour = "#000000",
        stages = "static",
    })
end

_config["nvim-scrollview"] = function()
    init("scrollview", {
        excluded_filetypes = { "nvimtree" },
        current_only = true,
        winblend = 75,
        base = "right",
        column = 1,
    })
end

_config["nvim-transparent"] = function()
    -- Enable transparent by default
    local transparent_cache = vim.fn.stdpath "data" .. "/transparent_cache"
    local f = io.open(transparent_cache, "r")
    if f ~= nil then
        f:close()
    else
        f = io.open(transparent_cache, "w")
        f:write "true"
        f:close()
    end

    init("transparent", {
        extra_groups = {
            "NvimTreeNormal",
            "NvimTreeNormalNC",
        },
    })
end

_config["nvim-tree"] = function()
    init("nvim-tree", {
        on_attach = require("settings").plugin.keymap._nvimTreeOnAttach,
        git = {
            enable = false,
        },
        update_cwd = true,
        update_focused_file = {
            enable = true,
            update_cwd = true,
        },
        filters = {
            dotfiles = false,
            custom = { "node_modules", ".git/" },
            exclude = { ".gitignore" },
        },
        view = {
            width = 30,
            side = "left",
            number = false,
            relativenumber = false,
            signcolumn = "yes",
        },
        actions = {
            open_file = {
                resize_window = true,
                quit_on_open = true,
            },
        },
    })
    vim.cmd "autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif" -- automatically close
end

_config["nvim-treesitter"] = function()
    require("nvim-treesitter.install").prefer_git = true
    init("nvim-treesitter.configs", {
        ensure_installed = {
            "c",
            "c_sharp",
            "cpp",
            "css",
            "fortran",
            "html",
            "javascript",
            "json",
            "lua",
            "python",
            "rust",
            "typescript",
            "tsx",
            "vim",
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
        },
        incremental_selection = {
            enable = true,
            keymaps = {
                init_selection = "<CR>",
                node_incremental = "<CR>",
                node_decremental = "<BS>",
                scope_incremental = "<TAB>",
            },
        },
        indent = {
            enable = true,
            -- conflicts with flutter-tools.nvim, causing performance issues
            disable = { "dart" },
        },
    })

    vim.opt.foldmethod = "expr"
    vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

    -- Unfold all upon opening a file, see:
    -- https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
    vim.opt.foldlevel = 99

    local rainbow_delimiters = require "rainbow-delimiters"

    vim.g.rainbow_delimiters = {
        strategy = {
            [""] = rainbow_delimiters.strategy["global"],
            vim = rainbow_delimiters.strategy["local"],
        },
        query = {
            [""] = "rainbow-delimiters",
            lua = "rainbow-blocks",
        },
        highlight = {
            "RainbowDelimiterRed",
            "RainbowDelimiterYellow",
            "RainbowDelimiterBlue",
            "RainbowDelimiterOrange",
            "RainbowDelimiterGreen",
            "RainbowDelimiterViolet",
            "RainbowDelimiterCyan",
        },
    }
end

_config.project = function()
    init("project_nvim", {
        patterns = {
            ".git",
            ".gitignore",
            "_darcs",
            ".hg",
            ".bzr",
            ".svn",
            "Makefile",
            "package.json",
            "deno.json",
            "deno.jsonc",
        },
    })

    local status, telescope = pcall(require, "telescope")
    if status then
        telescope.load_extension "projects"
    end
end

_config["rust-tools"] = function()
    init("rust-tools", {
        server = {
            capabilities = require("lsp.utils").capabilities,
            on_attach = function(_, bufnr)
                require("lsp.utils").keyAttach(bufnr)
            end,
        },
    })
end

_config["symbols-outline"] = function()
    local symbols = require("settings").symbols
    init("symbols-outline", {
        show_symbol_details = true,
        winblend = 20,
        keymaps = require("settings").plugin.keymap._outline,
        wrap = true,
        symbols = {
            File = { icon = symbols.File, hl = "@text.uri" },
            Module = { icon = symbols.Module, hl = "@namespace" },
            Namespace = { icon = symbols.Namespace, hl = "@namespace" },
            Package = { icon = symbols.Package, hl = "@namespace" },
            Class = { icon = symbols.Class, hl = "@type" },
            Method = { icon = symbols.Method, hl = "@method" },
            Property = { icon = symbols.Property, hl = "@method" },
            Field = { icon = symbols.Field, hl = "@field" },
            Constructor = { icon = symbols.Constructor, hl = "@constructor" },
            Enum = { icon = symbols.Enum, hl = "@type" },
            Interface = { icon = symbols.Interface, hl = "@type" },
            Function = { icon = symbols.Function, hl = "@function" },
            Variable = { icon = symbols.Variable, hl = "@constant" },
            Constant = { icon = symbols.Constant, hl = "@constant" },
            String = { icon = symbols.String, hl = "@string" },
            Number = { icon = symbols.Number, hl = "@number" },
            Boolean = { icon = symbols.Boolean, hl = "@boolean" },
            Array = { icon = symbols.Array, hl = "@constant" },
            Object = { icon = symbols.Object, hl = "@type" },
            Key = { icon = symbols.Key, hl = "@type" },
            Null = { icon = symbols.Null, hl = "@type" },
            EnumMember = { icon = symbols.EnumMember, hl = "@field" },
            Struct = { icon = symbols.Struct, hl = "@type" },
            Event = { icon = symbols.Event, hl = "@type" },
            Operator = { icon = symbols.Operator, hl = "@operator" },
            TypeParameter = { icon = symbols.TypeParameter, hl = "@parameter" },
            Component = { icon = symbols.Component, hl = "@function" },
            Fragment = { icon = symbols.Fragment, hl = "@constant" },
        },
    })
end

_config.telescope = function()
    local telescope = init("telescope", {
        defaults = {
            initial_mode = "insert",
            mappings = require("settings").plugin.keymap._telescopeList,
        },
        pickers = {
            find_files = {
                winblend = 20,
            },
        },
        extensions = {
            fzf = {
                fuzzy = true,
                override_generic_sorter = true,
                override_file_sorter = true,
                case_mode = "smart_case",
            },
        },
    })
    pcall(telescope.load_extension, "fzf")
    pcall(telescope.load_extension, "env")
end

_config["todo-comments"] = function()
    init("todo-comments", {})
end

_config.undotree = function()
    vim.g.undotree_WindowLayout = 2
    vim.g.undotree_TreeNodeShape = "-"
end

return _config
