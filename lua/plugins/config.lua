-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}
local symbols = Ice.symbols
local config_root = string.gsub(vim.fn.stdpath "config", "\\", "/")
local priority = {
    LOW = 100,
    MEDIUM = 200,
    HIGH = 615,
}

config.bufferline = {
    "akinsho/bufferline.nvim",
    lazy = false,
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    -- Set high priority to ensure this is loaded before nvim-transparent
    priority = priority.HIGH,
    opts = {
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
    },
    config = function(_, opts)
        require("bufferline").setup(opts)

        -- disable transparency for bufferline
        vim.g.transparent_exclude_groups = vim.list_extend(
            vim.g.transparent_exclude_groups or {},
            vim.tbl_map(function(v)
                return v.hl_group
            end, vim.tbl_values(
                require("bufferline.config").highlights
            ))
        )
    end,
    keys = {
        {
            "<leader>bc",
            ":BufferLinePickClose<CR>",
            desc = "pick close",
            silent = true,
            noremap = true,
            nowait = true,
        },
        -- <esc> is added in case current buffer is the last
        {
            "<leader>bd",
            ":bdelete!<CR><Esc>",
            desc = "close current buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>bh",
            ":BufferLineCyclePrev<CR>",
            desc = "prev buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>bl",
            ":BufferLineCycleNext<CR>",
            desc = "next buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>bo",
            ":BufferLineCloseOthers<CR>",
            desc = "close others",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>bp",
            ":BufferLinePick<CR>",
            desc = "pick buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.colorizer = {
    "NvChad/nvim-colorizer.lua",
    main = "colorizer",
    event = "BufEnter",
    opts = {
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
    },
}

config.comment = {
    "numToStr/Comment.nvim",
    main = "Comment",
    opts = {
        toggler = { line = "gcc", block = "gbc" },
        opleader = { line = "gc", block = "gb" },
        extra = { above = "gcO", below = "gco", eol = "gcA" },
        mappings = { basic = true, extra = true, extended = false },
    },
}

config.dashboard = {
    "glepnir/dashboard-nvim",
    lazy = false,
    opts = {
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
    },
    config = function(_, opts)
        require("dashboard").setup(opts)
    end,
}

config["flutter-tools"] = {
    "akinsho/flutter-tools.nvim",
    ft = "dart",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim",
    },
    main = "flutter-tools",
    opts = {
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
                require("plugins.lsp").keyAttach(bufnr)
            end,
        },
    },
}

config.gitsigns = {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    main = "gitsigns",
    opts = {},
    keys = {
        {
            "<leader>ghn",
            ":Gitsigns next_hunk<CR>",
            desc = "next hunk",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>ghp",
            ":Gitsigns prev_hunk<CR>",
            desc = "prev hunk",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>gph",
            ":Gitsigns preview_hunk<CR>",
            desc = "preview hunk",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>gsh",
            ":Gitsigns stage_hunk<CR>",
            desc = "stage hunk",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>guh",
            ":Gitsigns undo_stage_hunk<CR>",
            desc = "undo stage",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>grh",
            ":Gitsigns reset_hunk<CR>",
            desc = "reset hunk",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>gsb",
            ":Gitsigns stage_buffer<CR>",
            desc = "stage buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.hop = {
    "phaazon/hop.nvim",
    main = "hop",
    opts = {
        -- This is actually equal to:
        --   require("hop.hint").HintPosition.END
        hint_position = 3,
        keys = "fjghdksltyrueiwoqpvbcnxmza",
    },
    keys = {
        {
            "<leader>hp",
            ":HopWord<CR>",
            desc = "hop word",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config["indent-blankline"] = {
    "lukas-reineke/indent-blankline.nvim",
    event = "BufEnter",
    main = "ibl",
    opts = {
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
    },
}

local colorscheme = Ice.colorscheme
local theme
if not colorscheme then
    theme = "auto"
else
    theme = colorscheme.lualine_theme
end
config.lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "arkav/lualine-lsp-progress",
    },
    main = "lualine",
    opts = {
        options = {
            theme = theme,
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
    },
}

config["markdown-preview"] = {
    "iamcco/markdown-preview.nvim",
    ft = "markdown",
    config = function()
        vim.g.mkdp_filetypes = { "markdown" }
        vim.g.mkdp_auto_close = 0
    end,
    keys = {
        {
            "<leader>mdp",
            function()
                if vim.bo.filetype == "markdown" then
                    vim.cmd "MarkdownPreviewToggle"
                end
            end,
            desc = "markdown preview",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.neogit = {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    main = "neogit",
    opts = {
        status = {
            recent_commit_count = 30,
        },
    },
    keys = {
        {
            "<leader>ng",
            ":Neogit<CR>",
            desc = "neogit",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.neorg = {
    "nvim-neorg/neorg",
    -- Do not set ft = "norg", as we might want to access to neorg functions
    -- prior to entering a norg file
    event = "VeryLazy",
    main = "neorg",
    opts = {
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
    },
    config = function(_, opts)
        require("neorg").setup(opts)

        require("nvim-web-devicons").set_icon {
            norg = {
                icon = require("nvim-web-devicons").get_icon "file.org",
            },
        }
    end,
}

config.neoscroll = {
    "karb94/neoscroll.nvim",
    event = "BufEnter",
    main = "neoscroll",
    opts = {
        mappings = { "<C-u>", "<C-d>" },
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "sine",
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
    },
}

config.nui = {
    "MunifTanjim/nui.nvim",
}

config["nvim-autopairs"] = {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    main = "nvim-autopairs",
    opts = {},
}

config["nvim-notify"] = {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    opts = {
        timeout = 3000,
        background_colour = "#000000",
        stages = "static",
    },
    config = function(_, opts)
        require("notify").setup(opts)
        vim.notify = require "notify"
    end,
}

config["nvim-scrollview"] = {
    "dstein64/nvim-scrollview",
    event = "BufEnter",
    main = "scrollview",
    opts = {
        excluded_filetypes = { "nvimtree" },
        current_only = true,
        winblend = 75,
        base = "right",
        column = 1,
    },
}

config["nvim-transparent"] = {
    "xiyaowong/nvim-transparent",
    opts = {
        extra_groups = {
            "NvimTreeNormal",
            "NvimTreeNormalNC",
        },
    },
    config = function(_, opts)
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

        require("transparent").setup(opts)
    end,
}

config["nvim-tree"] = {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    opts = {
        on_attach = function(bufnr)
            local api = require "nvim-tree.api"
            local opt = {
                buffer = bufnr,
                noremap = true,
                silent = true,
                nowait = true,
            }

            api.config.mappings.default_on_attach(bufnr)

            require("core.utils").group_map({
                edit = { "n", "<CR>", api.node.open.edit },
                vertical_split = { "n", "v", api.node.open.vertical },
                horizontal_split = { "n", "h", api.node.open.horizontal },
                toggle_hidden_file = { "n", ".", api.tree.toggle_hidden_filter },
                reload = { "n", "<F5>", api.tree.reload },
                create = { "n", "a", api.fs.create },
                remove = { "n", "d", api.fs.remove },
                rename = { "n", "r", api.fs.rename },
                cut = { "n", "x", api.fs.cut },
                copy = { "n", "y", api.fs.copy.node },
                paste = { "n", "p", api.fs.paste },
                system_run = { "n", "s", api.node.run.system },
            }, opt)
        end,
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
    },
    config = function(_, opts)
        require("nvim-tree").setup(opts)

        -- automatically close
        vim.cmd "autocmd BufEnter * ++nested if winnr('$') == 1 && bufname() == 'NvimTree_' . tabpagenr() | quit | endif"
    end,
    keys = {
        {
            "<C-b>",
            ":NvimTreeToggle<CR>",
            desc = "toggle nvim tree",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config["nvim-treesitter"] = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    pin = true,
    main = "nvim-treesitter",
    opts = {
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
    },
    config = function(_, opts)
        require("nvim-treesitter.install").prefer_git = true
        require("nvim-treesitter.configs").setup(opts)

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
    end,
}

config.project = {
    "ahmedkhalf/project.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    opts = {
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
    },
    config = function(_, opts)
        require("project_nvim").setup(opts)
        local status, telescope = pcall(require, "telescope")
        if status then
            telescope.load_extension "projects"
        end
    end,
    keys = {
        {
            "<leader>pro",
            ":Telescope projects<CR>",
            desc = "view projects",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config["rust-tools"] = {
    "simrat39/rust-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "rust",
    main = "rust-tools",
    opts = {
        server = {
            on_attach = function(_, bufnr)
                require("plugins.lsp").keyAttach(bufnr)
            end,
        },
    },
}

config.surround = {
    "tpope/vim-surround",
}

config["symbols-outline"] = {
    "simrat39/symbols-outline.nvim",
    main = "symbols-outline",
    opts = {
        show_symbol_details = true,
        winblend = 20,
        keymaps = {
            close = { "<Esc>" },
            goto_location = "<Cr>",
            focus_location = "o",
            hover_symbol = "<C-space>",
            toggle_preview = "K",
            rename_symbol = "<leader>rn",
            code_actions = "<leader>ca",
            fold = "<leader>fd",
            unfold = "ufd",
            fold_all = "fda",
            unfold_all = "ufa",
            fold_reset = "R",
        },
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
    },
    keys = {
        {
            "<leader>otl",
            function()
                -- If flutter-tools is active, use FlutterOutlineToggle
                ---@diagnostic disable-next-line: param-type-mismatch
                local status, _ = pcall(vim.cmd, "FlutterOutlineToggle")
                if not status then
                    vim.cmd "SymbolsOutline"
                end
            end,
            desc = "toggle outline",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "LinArcX/telescope-env.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    opts = {
        defaults = {
            initial_mode = "insert",
            mappings = {
                i = {
                    ["<C-j>"] = "move_selection_next",
                    ["<C-k>"] = "move_selection_previous",
                    ["<C-n>"] = "cycle_history_next",
                    ["<C-p>"] = "cycle_history_prev",
                    ["<C-c>"] = "close",
                    ["<C-u>"] = "preview_scrolling_up",
                    ["<C-d>"] = "preview_scrolling_down",
                },
            },
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
    },
    config = function(_, opts)
        local telescope = require "telescope"
        telescope.setup(opts)
        pcall(telescope.load_extension, "fzf")
        pcall(telescope.load_extension, "env")
    end,
    keys = {
        {
            "<C-p>",
            ":Telescope find_files<CR>",
            desc = "find file",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader><C-f>",
            ":Telescope live_grep<CR>",
            desc = "live grep",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<C-f>",
            ":Telescope current_buffer_fuzzy_find<CR>",
            desc = "find in current buffer",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>env",
            ":Telescope env<CR>",
            desc = "n",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config["todo-comments"] = {
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
    },
    event = "BufEnter",
    main = "todo-comments",
    opts = {},
    keys = {
        {
            "<leader>nt",
            function()
                require("todo-comments").jump_next()
            end,
            desc = "next todo",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "<leader>pt",
            function()
                require("todo-comments").jump_prev()
            end,
            desc = "prev todo",
            silent = true,
            noremap = true,
            nowait = true,
        },
        {
            "todo",
            ":TodoTelescope<CR>",
            desc = "todo list",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.trouble = {
    "folke/trouble.nvim",
    keys = {
        {
            "<leader>tt",
            ":TroubleToggle<CR>",
            desc = "trouble toggle",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config.undotree = {
    "mbbill/undotree",
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_TreeNodeShape = "-"
    end,
    keys = {
        {
            "<leader>udt",
            ":UndotreeToggle<CR>",
            desc = "undo tree toggle",
            silent = true,
            noremap = true,
            nowait = true,
        },
    },
}

config["which-key"] = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    main = "which-key",
    opts = {
        plugins = {
            marks = true,
            registers = true,
            spelling = {
                enabled = false,
            },
            presets = {
                operators = false,
                motions = true,
                text_objects = true,
                windows = true,
                nav = true,
                z = true,
                g = true,
            },
        },
        window = {
            border = "none",
            position = "bottom",
            -- Leave 1 line at top / bottom for bufferline / lualine
            margin = { 1, 0, 1, 0 },
            padding = { 1, 0, 1, 0 },
            winblend = 0,
            zindex = 1000,
        },
    },
}

-- Colorschemes
config["ayu"] = {
    "Luxed/ayu-vim",
    priority = priority.HIGH,
}

config["github"] = {
    "projekt0n/github-nvim-theme",
    priority = priority.HIGH,
}

config["gruvbox"] = {
    "ellisonleao/gruvbox.nvim",
    priority = priority.HIGH,
}

config["nightfox"] = {
    "EdenEast/nightfox.nvim",
    priority = priority.HIGH,
}

config["tokyonight"] = {
    "folke/tokyonight.nvim",
    priority = priority.HIGH,
}

-- Lsp
config.mason = {
    "williamboman/mason.nvim",
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    },
    lazy = false,
    config = function()
        require("mason").setup {
            ui = {
                icons = {
                    package_installed = symbols.Affirmative,
                    package_pending = symbols.Pending,
                    package_uninstalled = symbols.Negative,
                },
            },
        }

        require("mason-lspconfig").setup {
            ensure_installed = require("settings").lsp.ensure_installed,
        }

        local lspconfig = require "lspconfig"

        for name, lsp in pairs(require("settings").lsp.servers) do
            if lspconfig[name] ~= nil then
                if type(lsp) == "table" then
                    lspconfig[name].setup(lsp)
                else
                    local predefined_config =
                        require("plugins.lsp").server[name]
                    if predefined_config ~= nil then
                        lspconfig[name].setup(predefined_config)
                    else
                        lspconfig[name].setup(
                            require("plugins.lsp").server.default
                        )
                    end
                end
            end
        end

        -- UI
        vim.diagnostic.config {
            virtual_text = true,
            signs = true,
            update_in_insert = true,
        }
        local signs = {
            Error = symbols.Error,
            Warn = symbols.Warn,
            Hint = symbols.Hint,
            Info = symbols.Info,
        }
        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
        end
    end,
}

config["nvim-cmp"] = {
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
        "tami5/lspsaga.nvim",
    },
    event = "InsertEnter",
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
            -- TODO: make this configurable
            mapping = require("plugins.lsp").keymap.cmp(cmp),
            formatting = {
                format = lspkind.cmp_format {
                    mode = "symbol",
                    maxwidth = 50,
                },
            },
        }

        cmp.setup.filetype("norg", {
            sources = cmp.config.sources({
                { name = "neorg" },
            }, {
                { name = "buffer" },
                { name = "path" },
            }),
        })

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
        cmp.event:on(
            "confirm_done",
            cmp_autopairs.on_confirm_done { map_char = { tex = "" } }
        )
    end,
}

config["null-ls"] = {
    "jose-elias-alvarez/null-ls.nvim",
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    config = function()
        local null_ls = require "null-ls"

        local formatting = null_ls.builtins.formatting

        null_ls.setup {
            debug = false,
            sources = {
                formatting.shfmt,
                formatting.stylua,
                formatting.csharpier,
                formatting.prettier.with {
                    filetypes = {
                        "javascript",
                        "javascriptreact",
                        "typescript",
                        "typescriptreact",
                        "vue",
                        "css",
                        "scss",
                        "less",
                        "html",
                        "json",
                        "yaml",
                        "graphql",
                    },
                    extra_filetypes = { "njk" },
                    prefer_local = "node_modules/.bin",
                },
                formatting.autopep8,
            },
            diagnostics_format = "[#{s}] #{m}",
        }
    end,
}

return config
