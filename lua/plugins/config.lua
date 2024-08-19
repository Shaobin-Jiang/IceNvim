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

-- Add IceLoad event
-- If user starts neovim but does not edit a file, i.e., entering Dashboard directly, the IceLoad event is hooked to the
-- next BufRead event. Otherwise, the event is triggered right after the VeryLazy event.
vim.api.nvim_create_autocmd("User", {
    pattern = "VeryLazy",
    callback = function()
        local function _trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "IceLoad" })
        end

        if vim.bo.filetype == "dashboard" then
            vim.api.nvim_create_autocmd("BufEnter", {
                pattern = "*/*",
                once = true,
                callback = _trigger,
            })
        else
            _trigger()
        end
    end,
})

config.bufferline = {
    "akinsho/bufferline.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
    event = "User IceLoad",
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
            local buf_is_modified = vim.api.nvim_get_option_value("modified", { buf = bufnr })

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

        require("nvim-web-devicons").set_icon {
            typ = {
                icon = "󰰥",
                color = "#239dad",
                name = "typst",
            },
        }
    end,
    keys = {
        { "<leader>bc", "<Cmd>BufferLinePickClose<CR>", desc = "pick close", silent = true, noremap = true },
        -- <esc> is added in case current buffer is the last
        {
            "<leader>bd",
            "<Cmd>BufferLineClose 0<CR><ESC>",
            desc = "close current buffer",
            silent = true,
            noremap = true,
        },
        { "<leader>bh", "<Cmd>BufferLineCyclePrev<CR>", desc = "prev buffer", silent = true, noremap = true },
        { "<leader>bl", "<Cmd>BufferLineCycleNext<CR>", desc = "next buffer", silent = true, noremap = true },
        { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "close others", silent = true, noremap = true },
        { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "pick buffer", silent = true, noremap = true },
    },
}

config.colorizer = {
    "NvChad/nvim-colorizer.lua",
    main = "colorizer",
    event = "User IceLoad",
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

        local comment_below = function()
            require("Comment.api").insert.linewise.below()
        end

        local comment_above = function()
            require("Comment.api").insert.linewise.above()
        end

        local comment_eol = function()
            require("Comment.api").locked "insert.linewise.eol"()
        end

        return {
            { "<leader>c", "<Plug>(comment_toggle_linewise)", desc = "comment toggle linewise" },
            { "<leader>ca", "<Plug>(comment_toggle_blockwise)", desc = "comment toggle blockwise" },
            { "<leader>cc", toggle_current_line, expr = true, desc = "comment toggle current line" },
            { "<leader>cb", toggle_current_block, expr = true, desc = "comment toggle current block" },
            { "<leader>cc", "<Plug>(comment_toggle_linewise_visual)", mode = "x", desc = "comment toggle linewise" },
            { "<leader>cb", "<Plug>(comment_toggle_blockwise_visual)", mode = "x", desc = "comment toggle blockwise" },
            { "<leader>co", comment_below, desc = "comment insert below" },
            { "<leader>cO", comment_above, desc = "comment insert above" },
            { "<leader>cA", comment_eol, desc = "comment insert end of line" },
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

config.gitsigns = {
    "lewis6991/gitsigns.nvim",
    event = "User IceLoad",
    main = "gitsigns",
    opts = {},
    keys = {
        { "<leader>gn", "<Cmd>Gitsigns next_hunk<CR>", desc = "next hunk", silent = true, noremap = true },
        { "<leader>gp", "<Cmd>Gitsigns prev_hunk<CR>", desc = "prev hunk", silent = true, noremap = true },
        { "<leader>gP", "<Cmd>Gitsigns preview_hunk<CR>", desc = "preview hunk", silent = true, noremap = true },
        { "<leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", desc = "stage hunk", silent = true, noremap = true },
        { "<leader>gu", "<Cmd>Gitsigns undo_stage_hunk<CR>", desc = "undo stage", silent = true, noremap = true },
        { "<leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", desc = "reset hunk", silent = true, noremap = true },
        { "<leader>gB", "<Cmd>Gitsigns stage_buffer<CR>", desc = "stage buffer", silent = true, noremap = true },
        { "<leader>gb", "<Cmd>Gitsigns blame<CR>", desc = "git blame", silent = true, noremap = true },
        { "<leader>gl", "<Cmd>Gitsigns blame_line<CR>", desc = "git blame line", silent = true, noremap = true },
    },
}

config["grug-far"] = {
    "MagicDuck/grug-far.nvim",
    opts = {
        disableBufferLineNumbers = true,
        startInInsertMode = true,
        windowCreationCommand = "tabnew %",
    },
    keys = {
        { "<leader>ug", "<Cmd>GrugFar<CR>", desc = "find and replace", silent = true, noremap = true },
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
        { "<leader>hp", "<Cmd>HopWord<CR>", desc = "hop word", silent = true, noremap = true },
    },
}

config["indent-blankline"] = {
    "lukas-reineke/indent-blankline.nvim",
    event = "User IceLoad",
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
    event = "User IceLoad",
    main = "lualine",
    opts = {
        options = {
            theme = "auto",
            component_separators = { left = "", right = "" },
            section_separators = { left = "", right = "" },
            disabled_filetypes = { "undotree", "diff" },
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

config.neogit = {
    "NeogitOrg/neogit",
    dependencies = "nvim-lua/plenary.nvim",
    main = "neogit",
    opts = {
        disable_hint = true,
        status = {
            recent_commit_count = 30,
        },
        commit_editor = {
            kind = "auto",
            show_staged_diff = false,
        },
    },
    keys = {
        { "<leader>gt", "<Cmd>Neogit<CR>", desc = "neogit", silent = true, noremap = true },
    },
    config = function(_, opts)
        require("neogit").setup(opts)
        Ice.ft.NeogitCommitMessage = function()
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end
    end,
}

config.neoscroll = {
    "karb94/neoscroll.nvim",
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
    lazy = true,
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
        ---@diagnostic disable-next-line: undefined-field
        require("notify").setup(opts)
        vim.notify = require "notify"
    end,
}

config["nvim-scrollview"] = {
    "dstein64/nvim-scrollview",
    event = "User IceLoad",
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
        local autogroup = vim.api.nvim_create_augroup("transparent", { clear = true })
        vim.api.nvim_create_autocmd("ColorScheme", {
            group = autogroup,
            callback = function()
                local normal_hl = vim.api.nvim_get_hl(0, { name = "Normal" })
                local foreground = string.format("#%06x", normal_hl.fg)
                local background = string.format("#%06x", normal_hl.bg)
                vim.api.nvim_command("highlight default IceNormal guifg=" .. foreground .. " guibg=" .. background)

                require("transparent").clear()
            end,
        })
        -- Enable transparent by default
        local transparent_cache = vim.fn.stdpath "data" .. "/transparent_cache"
        if not require("core.utils").file_exists(transparent_cache) then
            local f = io.open(transparent_cache, "w")
            f:write "true"
            f:close()
        end

        require("transparent").setup(opts)

        local old_get_hl = vim.api.nvim_get_hl
        vim.api.nvim_get_hl = function(ns_id, opt)
            if opt.name == "Normal" then
                local attempt = old_get_hl(0, { name = "IceNormal" })
                if next(attempt) ~= nil then
                    opt.name = "IceNormal"
                end
            end
            return old_get_hl(ns_id, opt)
        end
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
                        if node.name ~= ".." and node.fs_stat.type == "file" then
                            -- Taken partially from:
                            -- https://support.microsoft.com/en-us/windows/common-file-name-extensions-in-windows-da4a4430-8e76-89c5-59f7-1cdbbc75cb01
                            --
                            -- Not all are included for speed's sake
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
        update_focused_file = {
            enable = true,
        },
        filters = {
            dotfiles = false,
            custom = { "node_modules", ".git/" },
            exclude = { ".gitignore" },
        },
        respect_buf_cwd = true,
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
        { "<leader>uf", "<Cmd>NvimTreeToggle<CR>", desc = "toggle nvim tree", silent = true, noremap = true },
    },
}

config["nvim-treesitter"] = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    -- Do not lazy load if file does not exist
    --
    -- Why this is needed:
    --
    -- Because nvim-treesitter needs to be loaded early, which is why using "VeryLazy" would not load it in time if we
    -- open a file directly upon startup. BufRead, on the other hand, loads nvim-treesitter in time for a file but does
    -- not load it in dashboard, hence doing well with startup time.
    --
    -- However, BufRead is not fired for non-existent files. So, if we use `nvim <new-file>`, nvim-treesitter would not
    -- be loaded for that new file. In this case, the only solution I could see is to prevent lazy loading of the plugin
    -- altogether.
    lazy = (function()
        local file_name = vim.fn.expand "%:p"
        return file_name == "" or require("core.utils").file_exists(file_name)
    end)(),
    event = "BufRead",
    main = "nvim-treesitter",
    opts = {
        ensure_installed = {
            "c",
            "c_sharp",
            "cpp",
            "css",
            "go",
            "html",
            "javascript",
            "json",
            "lua",
            "markdown",
            "markdown_inline",
            "python",
            "query",
            "rust",
            "typescript",
            "typst",
            "tsx",
            "vim",
            "vimdoc",
        },
        highlight = {
            enable = true,
            additional_vim_regex_highlighting = false,
            disable = function(_, buf)
                local max_filesize = 100 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
                if ok and stats and stats.size > max_filesize then
                    return true
                end
            end,
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
    "kylechui/nvim-surround",
    version = "*",
    opts = {},
    event = "User IceLoad",
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
        { "<leader>tf", "<Cmd>Telescope find_files<CR>", desc = "find file", silent = true, noremap = true },
        { "<leader>t<C-f>", "<Cmd>Telescope live_grep<CR>", desc = "live grep", silent = true, noremap = true },
        { "<leader>te", "<Cmd>Telescope env<CR>", desc = "environment variables", silent = true, noremap = true },
    },
}

config["todo-comments"] = {
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
    },
    event = "User IceLoad",
    main = "todo-comments",
    opts = {},
    keys = {
        { "<leader>ut", "<Cmd>TodoTelescope<CR>", desc = "todo list", silent = true, noremap = true },
    },
}

config.undotree = {
    "mbbill/undotree",
    config = function()
        vim.g.undotree_WindowLayout = 2
        vim.g.undotree_TreeNodeShape = "-"
    end,
    keys = {
        { "<leader>uu", "<Cmd>UndotreeToggle<CR>", desc = "undo tree toggle", silent = true, noremap = true },
    },
}

config["which-key"] = {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        icons = {
            mappings = false,
        },
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
        spec = {
            { "<leader>b", group = "+buffer" },
            { "<leader>c", group = "+comment" },
            { "<leader>g", group = "+git" },
            { "<leader>h", group = "+hop" },
            { "<leader>l", group = "+lsp" },
            { "<leader>t", group = "+telescope" },
            { "<leader>u", group = "+utils" },
        },
        win = {
            border = "none",
            padding = { 1, 0, 1, 0 },
            wo = {
                winblend = 0,
            },
            zindex = 1000,
        },
    },
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
        vim.api.nvim_command "highlight link ZenBg IceNormal"
        require("zen-mode").setup(opts)
    end,
    keys = {
        { "<leader>uz", "<Cmd>ZenMode<CR>", desc = "toggle zen mode", silent = true, noremap = true },
    },
}

-- Colorschemes
config["ayu"] = {
    "Luxed/ayu-vim",
    lazy = true,
}

config["github"] = {
    "projekt0n/github-nvim-theme",
    lazy = true,
}

config["gruvbox"] = {
    "ellisonleao/gruvbox.nvim",
    lazy = true,
}

config["kanagawa"] = {
    "rebelot/kanagawa.nvim",
    lazy = true,
}

config["nightfox"] = {
    "EdenEast/nightfox.nvim",
    lazy = true,
}

config["tokyonight"] = {
    "folke/tokyonight.nvim",
    lazy = true,
}

Ice.plugins = config
Ice.keymap.prefix = {
    { "<leader>b", group = "+buffer" },
    { "<leader>c", group = "+comment" },
    { "<leader>g", group = "+git" },
    { "<leader>h", group = "+hop" },
    { "<leader>l", group = "+lsp" },
    { "<leader>t", group = "+telescope" },
    { "<leader>u", group = "+utils" },
}
