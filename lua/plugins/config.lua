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
            close_command = ":BufferLineClose %d",
            right_mouse_command = ":BufferLineClose %d",
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
                    local sym = e == "error" and symbols.Error or (e == "warning" and symbols.Warn or symbols.Info)
                    s = s .. n .. sym
                end
                return s
            end,
        },
    },
    config = function(_, opts)
        vim.api.nvim_create_user_command("BufferLineClose", function(buffer_line_opts)
            local bufnr = 1 * buffer_line_opts.args
            local buf_is_modified = vim.api.nvim_buf_get_option(bufnr, "modified")

            local bdelete_arg
            if bufnr == 0 then
                bdelete_arg = ""
            else
                bdelete_arg = " " .. bufnr
            end
            local command = "bdelete!" .. bdelete_arg
            if buf_is_modified then
                local option = vim.fn.confirm("File is not saved. Close anyway?", "&Yes\n&No", 2)
                if option == 1 then
                    vim.cmd(command)
                end
            else
                vim.cmd(command)
            end
        end, { nargs = 1 })

        require("bufferline").setup(opts)
    end,
    keys = {
        { "<leader>bc", ":BufferLinePickClose<CR>", desc = "pick close", silent = true, noremap = true },
        -- <esc> is added in case current buffer is the last
        { "<leader>bd", ":BufferLineClose 0<CR><ESC>", desc = "close current buffer", silent = true, noremap = true },
        { "<leader>bh", ":BufferLineCyclePrev<CR>", desc = "prev buffer", silent = true, noremap = true },
        { "<leader>bl", ":BufferLineCycleNext<CR>", desc = "next buffer", silent = true, noremap = true },
        { "<leader>bo", ":BufferLineCloseOthers<CR>", desc = "close others", silent = true, noremap = true },
        { "<leader>bp", ":BufferLinePick<CR>", desc = "pick buffer", silent = true, noremap = true },
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
        mappings = { basic = true, extra = true, extended = false },
    },
    config = function(_, opts)
        require("Comment").setup(opts)

        -- Remove the keymap defined by Comment.nvim
        vim.keymap.del("n", "gcc")
        vim.keymap.del("n", "gbc")
        vim.keymap.del("n", "gc")
        vim.keymap.del("n", "gb")
        vim.keymap.del("x", "gc")
        vim.keymap.del("x", "gb")
        vim.keymap.del("n", "gcO")
        vim.keymap.del("n", "gco")
        vim.keymap.del("n", "gcA")
    end,
    keys = function()
        local vvar = vim.api.nvim_get_vvar
        local api = require "Comment.api"

        local toggle_current_line = function()
            if vvar "count" == 0 then
                return "<Plug>(comment_toggle_linewise_current)"
            else
                return "<Plug>(comment_toggle_linewise_count)"
            end
        end

        local toggle_current_block = function()
            if vvar "count" == 0 then
                return "<Plug>(comment_toggle_blockwise_current)"
            else
                return "<Plug>(comment_toggle_blockwise_count)"
            end
        end

        return {
            { "<leader>c", "<Plug>(comment_toggle_linewise)", desc = "comment toggle linewise" },
            { "<leader>ca", "<Plug>(comment_toggle_blockwise)", desc = "comment toggle blockwise" },
            { "<leader>cc", toggle_current_line, expr = true, desc = "comment toggle current line" },
            { "<leader>cb", toggle_current_block, expr = true, desc = "comment toggle current block" },
            { "<leader>cc", "<Plug>(comment_toggle_linewise_visual)", mode = "x", desc = "comment toggle linewise" },
            { "<leader>cb", "<Plug>(comment_toggle_blockwise_visual)", mode = "x", desc = "comment toggle blockwise" },
            { "<leader>co", api.insert.linewise.below, desc = "comment insert below" },
            { "<leader>cO", api.insert.linewise.above, desc = "comment insert above" },
            { "<leader>cA", api.locked "insert.linewise.eol", desc = "comment insert end of line" },
        }
    end,
}

config.dashboard = {
    "nvimdev/dashboard-nvim",
    lazy = false,
    opts = {
        theme = "doom",
        config = {
            -- https://patorjk.com/software/taag/#p=display&f=ANSI%20Shadow&t=icenvim
            header = {
                " ",
                "██╗ ██████╗███████╗███╗   ██╗██╗   ██╗██╗███╗   ███╗",
                "██║██╔════╝██╔════╝████╗  ██║██║   ██║██║████╗ ████║",
                "██║██║     █████╗  ██╔██╗ ██║██║   ██║██║██╔████╔██║",
                "██║██║     ██╔══╝  ██║╚██╗██║╚██╗ ██╔╝██║██║╚██╔╝██║",
                "██║╚██████╗███████╗██║ ╚████║ ╚████╔╝ ██║██║ ╚═╝ ██║",
                "╚═╝ ╚═════╝╚══════╝╚═╝  ╚═══╝  ╚═══╝  ╚═╝╚═╝     ╚═",
                " ",
                string.format("                      %s                       ", require("core.utils").version),
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
                    action = string.format("edit %s/lua/custom/init.lua", config_root),
                },
                {
                    icon = "  ",
                    desc = "Mason",
                    action = "Mason",
                },
                {
                    icon = "  ",
                    desc = "About IceNvim",
                    action = "lua require('plugins.utils').about()",
                },
            },
            footer = { "🧊 Hope that you enjoy using IceNvim 😀😀😀" },
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
                Ice.lsp.keyAttach(bufnr)
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
        { "<leader>gn", ":Gitsigns next_hunk<CR>", desc = "next hunk", silent = true, noremap = true },
        { "<leader>gp", ":Gitsigns prev_hunk<CR>", desc = "prev hunk", silent = true, noremap = true },
        { "<leader>gP", ":Gitsigns preview_hunk<CR>", desc = "preview hunk", silent = true, noremap = true },
        { "<leader>gs", ":Gitsigns stage_hunk<CR>", desc = "stage hunk", silent = true, noremap = true },
        { "<leader>gu", ":Gitsigns undo_stage_hunk<CR>", desc = "undo stage", silent = true, noremap = true },
        { "<leader>gr", ":Gitsigns reset_hunk<CR>", desc = "reset hunk", silent = true, noremap = true },
        { "<leader>gb", ":Gitsigns stage_buffer<CR>", desc = "stage buffer", silent = true, noremap = true },
    },
}

config.hop = {
    "smoka7/hop.nvim",
    main = "hop",
    opts = {
        -- This is actually equal to:
        --   require("hop.hint").HintPosition.END
        hint_position = 3,
        keys = "fjghdksltyrueiwoqpvbcnxmza",
    },
    keys = {
        { "<leader>hp", ":HopWord<CR>", desc = "hop word", silent = true, noremap = true },
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

config.lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "arkav/lualine-lsp-progress",
    },
    main = "lualine",
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "undotree", "diff", "Outline" },
        },
        extensions = { "nvim-tree" },
        sections = {
            lualine_b = { "branch", "diff" },
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
                    symbols = { unix = symbols.Unix, dos = symbols.Dos, mac = symbols.Mac },
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
    build = "cd app && yarn install",
    keys = {
        {
            "<leader>um",
            function()
                if vim.bo.filetype == "markdown" then
                    vim.cmd "MarkdownPreviewToggle"
                end
            end,
            desc = "markdown preview",
            silent = true,
            noremap = true,
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
        { "<leader>gt", ":Neogit<CR>", desc = "neogit", silent = true, noremap = true },
    },
}

config.neoscroll = {
    "karb94/neoscroll.nvim",
    event = "BufEnter",
    main = "neoscroll",
    opts = {
        mappings = {},
        hide_cursor = true,
        stop_eof = true,
        respect_scrolloff = false,
        cursor_scrolls_alone = true,
        easing_function = "sine",
        pre_hook = nil,
        post_hook = nil,
        performance_mode = false,
    },
    keys = {
        {
            "<C-u>",
            function()
                require("neoscroll").scroll(-vim.wo.scroll, true, 250)
            end,
            desc = "scroll up",
        },
        {
            "<C-d>",
            function()
                require("neoscroll").scroll(vim.wo.scroll, true, 250)
            end,
            desc = "scroll down",
        },
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
            }

            api.config.mappings.default_on_attach(bufnr)

            require("core.utils").group_map({
                edit = {
                    "n",
                    "<CR>",
                    function()
                        local node = api.tree.get_node_under_cursor()
                        if node.fs_stat.type == "file" then
                            -- Taken partially from:
                            -- https://support.microsoft.com/en-us/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01
                            --
                            -- Not all are included for speed's sake and that we do not really need to "open" certain
                            -- file types such as dll.
                            local extensions_opened_externally = {
                                "avi",
                                "bmp",
                                "doc",
                                "docx",
                                "exe",
                                "flv",
                                "gif",
                                "jpg",
                                "jpeg",
                                "m4a",
                                "mov",
                                "mp3",
                                "mp4",
                                "mpeg",
                                "mpg",
                                "pdf",
                                "png",
                                "ppt",
                                "pptx",
                                "psd",
                                "pub",
                                "rar",
                                "rtf",
                                "tif",
                                "tiff",
                                "wav",
                                "xls",
                                "xlsx",
                                "zip",
                            }
                            if table.find(extensions_opened_externally, node.extension) then
                                api.node.run.system()
                                return
                            end
                        end

                        api.node.open.edit()
                    end,
                },
                vertical_split = { "n", "V", api.node.open.vertical },
                horizontal_split = { "n", "H", api.node.open.horizontal },
                toggle_hidden_file = { "n", ".", api.tree.toggle_hidden_filter },
                reload = { "n", "<F5>", api.tree.reload },
                create = { "n", "a", api.fs.create },
                remove = { "n", "d", api.fs.remove },
                rename = { "n", "r", api.fs.rename },
                cut = { "n", "x", api.fs.cut },
                copy = { "n", "y", api.fs.copy.node },
                paste = { "n", "p", api.fs.paste },
                system_run = { "n", "s", api.node.run.system },
                show_info = { "n", "i", api.node.show_info_popup },
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
        { "<leader>uf", ":NvimTreeToggle<CR>", desc = "toggle nvim tree", silent = true, noremap = true },
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
        vim.opt.foldenable = false

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

config["rust-tools"] = {
    "simrat39/rust-tools.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = "rust",
    main = "rust-tools",
    opts = {
        server = {
            on_attach = function(_, bufnr)
                Ice.lsp.keyAttach(bufnr)
            end,
        },
    },
}

config.surround = {
    "tpope/vim-surround",
}

config.telescope = {
    "nvim-telescope/telescope.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "LinArcX/telescope-env.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
                .. "cmake --build build --config Release && "
                .. "cmake --install build --prefix build",
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
        telescope.load_extension "fzf"
        telescope.load_extension "env"
    end,
    keys = {
        { "<leader>tf", ":Telescope find_files<CR>", desc = "find file", silent = true, noremap = true },
        { "<leader>t<C-f>", ":Telescope live_grep<CR>", desc = "live grep", silent = true, noremap = true },
        { "<leader>te", ":Telescope env<CR>", desc = "environment variables", silent = true, noremap = true },
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
        { "<leader>ut", ":TodoTelescope<CR>", desc = "todo list", silent = true, noremap = true },
    },
}

config.trouble = {
    "folke/trouble.nvim",
    keys = {
        { "<leader>lt", ":TroubleToggle<CR>", desc = "trouble toggle", silent = true, noremap = true },
    },
}

config.undotree = {
    "mbbill/undotree",
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_TreeNodeShape = "-"
    end,
    keys = {
        { "<leader>uu", ":UndotreeToggle<CR>", desc = "undo tree toggle", silent = true, noremap = true },
    },
}

config["which-key"] = {
    "folke/which-key.nvim",
    event = "VeryLazy",
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
    config = function(_, opts)
        require("which-key").setup(opts)
        local wk = require "which-key"
        wk.register(Ice.keymap.prefix)
    end,
}

config["zen-mode"] = {
    "folke/zen-mode.nvim",
    -- Set high priority to ensure this is loaded before nvim-transparent
    priority = priority.HIGH,
    opts = {
        window = {
            backdrop = 0.8,
            width = vim.fn.winwidth(0) - 16,
            height = vim.fn.winheight(0) + 1,
        },
        on_open = function()
            vim.opt.cmdheight = 1
        end,
        on_close = function()
            vim.opt.cmdheight = 2
        end,
    },
    config = function(_, opts)
        -- TODO: this highlight is only used because I have not yet found a way of getting the bg of Normal, which is
        -- wiped out when transparency is on. BufferLineTabSelected is amidst the few highlights that is opaque and
        -- shares the same bg as Normal.
        local zen_mode_util = require "zen-mode.util"
        local hl = zen_mode_util.get_hl "BufferLineTabSelected"
        local bg = zen_mode_util.darken(hl.background, opts.window.backdrop)
        vim.cmd(("highlight default ZenBg guibg=%s guifg=%s"):format(bg, bg))
        require("zen-mode").setup(opts)
    end,
    keys = {
        { "<leader>uz", ":ZenMode<CR>", desc = "toggle zen mode", silent = true, noremap = true },
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

config["kanagawa"] = {
    "rebelot/kanagawa.nvim",
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

        local registry = require "mason-registry"
        local function install(package)
            local s, p = pcall(registry.get_package, package)
            if s and not p:is_installed() then
                p:install()
            end
        end

        for _, package in pairs(Ice.lsp.ensure_installed) do
            if type(package) == "table" then
                for _, p in pairs(package) do
                    install(p)
                end
            else
                install(package)
            end
        end

        local lspconfig = require "lspconfig"

        for _, lsp in pairs(Ice.lsp.servers) do
            if lspconfig[lsp] ~= nil then
                local predefined_config = Ice.lsp["server-config"][lsp]
                if not predefined_config then
                    predefined_config = Ice.lsp["server-config"].default
                end
                lspconfig[lsp].setup(predefined_config())
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
    event = "VeryLazy",
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
            mapping = Ice.lsp.keymap.cmp(cmp),
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
    end,
}

config["null-ls"] = {
    "nvimtools/none-ls.nvim",
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
                formatting.black,
            },
            diagnostics_format = "[#{s}] #{m}",
        }
    end,
}

Ice.plugins = config
Ice.keymap.prefix = {
    ["<leader>b"] = { name = "+buffer" },
    ["<leader>c"] = { name = "+comment" },
    ["<leader>g"] = { name = "+git" },
    ["<leader>h"] = { name = "+hop" },
    ["<leader>l"] = { name = "+lsp" },
    ["<leader>t"] = { name = "+telescope" },
    ["<leader>u"] = { name = "+utils" },
}
