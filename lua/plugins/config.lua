-- Configuration for each individual plugin
---@diagnostic disable: need-check-nil
local config = {}
local symbols = Ice.symbols
local config_root = string.gsub(vim.fn.stdpath "config" --[[@as string]], "\\", "/")

-- Add IceLoad event
vim.api.nvim_create_autocmd("User", {
    pattern = "IceAfter colorscheme",
    callback = function()
        local function should_trigger()
            return vim.bo.filetype ~= "dashboard" and vim.api.nvim_buf_get_name(0) ~= ""
        end

        local function trigger()
            vim.api.nvim_exec_autocmds("User", { pattern = "IceLoad" })
        end

        if should_trigger() then
            trigger()
            return
        end

        local ice_load
        ice_load = vim.api.nvim_create_autocmd("BufEnter", {
            callback = function()
                if should_trigger() then
                    trigger()
                    vim.api.nvim_del_autocmd(ice_load)
                end
            end,
        })
    end,
})

local function avante(win)
    return function()
        local candidate = require("avante").current.sidebar.containers[win]
        if win then
            local win_id = candidate.winid
            vim.api.nvim_set_current_win(win_id)
        end
    end
end

config.avante = {
    "yetone/avante.nvim",
    enabled = false,
    build = function()
        if require("core.utils").is_windows then
            return "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false"
        else
            return "make"
        end
    end,
    event = "User IceLoad",
    version = false,
    opts = {
        provider = "copilot",
        providers = {
            copilot = {
                model = "claude-sonnet-4",
                extra_request_body = {
                    temperature = 0.75,
                    max_tokens = 20480,
                },
            },
        },
        mappings = {
            confirm = {
                focus_window = "<leader>awf",
            },
        },
        windows = {
            width = 40,
            sidebar_header = {
                align = "left",
                rounded = false,
            },
            input = {
                height = 16,
            },
            ask = {
                start_insert = false,
            },
        },
    },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "MunifTanjim/nui.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
        "zbirenbaum/copilot.lua",
        { "MeanderingProgrammer/render-markdown.nvim", opts = { file_types = { "Avante" } }, ft = { "Avante" } },
    },
    keys = {
        { "<leader>awc", avante "selected_code", desc = "focus code", silent = true },
        { "<leader>awi", avante "input", desc = "focus input", silent = true },
        { "<leader>awa", avante "result", desc = "focus result", silent = true },
        { "<leader>aws", avante "selected_files", desc = "focus selected files", silent = true },
        { "<leader>awt", avante "todos", desc = "focus todo", silent = true },
    },
}

config.bufferline = {
    "akinsho/bufferline.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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

        require("nvim-web-devicons").setup {
            override = {
                typ = { icon = "󰰥", color = "#239dad", name = "typst" },
            },
        }
    end,
    keys = {
        { "<leader>bc", "<Cmd>BufferLinePickClose<CR>", desc = "pick close", silent = true },
        { "<leader>bd", "<Cmd>BufferLineClose 0<CR>", desc = "close current buffer", silent = true },
        { "<leader>bh", "<Cmd>BufferLineCyclePrev<CR>", desc = "prev buffer", silent = true },
        { "<leader>bl", "<Cmd>BufferLineCycleNext<CR>", desc = "next buffer", silent = true },
        { "<leader>bo", "<Cmd>BufferLineCloseOthers<CR>", desc = "close others", silent = true },
        { "<leader>bp", "<Cmd>BufferLinePick<CR>", desc = "pick buffer", silent = true },
        { "<leader>bm", "<Cmd>IceRepeat BufferLineMoveNext<CR>", desc = "move right", silent = true },
        { "<leader>bM", "<Cmd>IceRepeat BufferLineMovePrev<CR>", desc = "move left", silent = true },
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
    config = function(_, opts)
        require("colorizer").setup(opts)
        vim.cmd "ColorizerToggle"
    end,
}

config.dashboard = {
    "nvimdev/dashboard-nvim",
    event = "User IceAfter colorscheme",
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
                    action = "IceAbout",
                },
            },
            footer = { "🧊 Hope that you enjoy using IceNvim 😀😀😀" },
        },
    },
    config = function(_, opts)
        require("dashboard").setup(opts)

        if vim.api.nvim_buf_get_name(0) == "" then
            vim.cmd "Dashboard"
        end

        -- Use the highlight command to replace instead of overriding the original highlight group
        -- Much more convenient than using vim.api.nvim_set_hl()
        vim.cmd "highlight DashboardFooter cterm=NONE gui=NONE"
    end,
}

config.fidget = {
    "j-hui/fidget.nvim",
    event = "VeryLazy",
    opts = {
        notification = {
            override_vim_notify = true,
            window = {
                x_padding = 2,
                align = "top",
            },
        },
        integration = {
            ["nvim-tree"] = {
                enable = false,
            },
        },
    },
}

config.gitsigns = {
    "lewis6991/gitsigns.nvim",
    event = "User IceLoad",
    main = "gitsigns",
    opts = {},
    keys = {
        { "<leader>gn", "<Cmd>Gitsigns next_hunk<CR>", desc = "next hunk", silent = true },
        { "<leader>gp", "<Cmd>Gitsigns prev_hunk<CR>", desc = "prev hunk", silent = true },
        { "<leader>gP", "<Cmd>Gitsigns preview_hunk<CR>", desc = "preview hunk", silent = true },
        { "<leader>gs", "<Cmd>Gitsigns stage_hunk<CR>", desc = "stage hunk", silent = true },
        { "<leader>gu", "<Cmd>Gitsigns undo_stage_hunk<CR>", desc = "undo stage", silent = true },
        { "<leader>gr", "<Cmd>Gitsigns reset_hunk<CR>", desc = "reset hunk", silent = true },
        { "<leader>gB", "<Cmd>Gitsigns stage_buffer<CR>", desc = "stage buffer", silent = true },
        { "<leader>gb", "<Cmd>Gitsigns blame<CR>", desc = "git blame", silent = true },
        { "<leader>gl", "<Cmd>Gitsigns blame_line<CR>", desc = "git blame line", silent = true },
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
        { "<leader>ug", "<Cmd>GrugFar<CR>", desc = "find and replace", silent = true },
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
        { "<leader>hp", "<Cmd>HopWord<CR>", desc = "hop word", silent = true },
    },
}

config["indent-blankline"] = {
    "lukas-reineke/indent-blankline.nvim",
    event = "User IceAfter nvim-treesitter",
    main = "ibl",
    opts = {
        exclude = {
            filetypes = { "dashboard", "terminal", "help", "log", "markdown", "TelescopePrompt" },
        },
        indent = {
            highlight = {
                "IblIndent",
                "RainbowDelimiterRed",
                "RainbowDelimiterYellow",
                "RainbowDelimiterBlue",
                "RainbowDelimiterOrange",
                "RainbowDelimiterGreen",
                "RainbowDelimiterViolet",
                "RainbowDelimiterCyan",
            },
        },
    },
}

config.lualine = {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
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
            "<A-b>",
            "<Cmd>MarkdownPreviewToggle<CR>",
            desc = "markdown preview",
            ft = "markdown",
            silent = true,
        },
    },
}

config.neogit = {
    "NeogitOrg/neogit",
    dependencies = { "nvim-lua/plenary.nvim" },
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
        { "<leader>gt", "<Cmd>Neogit<CR>", desc = "neogit", silent = true },
    },
    config = function(_, opts)
        require("neogit").setup(opts)
        Ice.ft.NeogitCommitMessage = function()
            vim.api.nvim_win_set_cursor(0, { 1, 0 })
        end
    end,
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
                vim.cmd("highlight default IceNormal guifg=" .. foreground .. " guibg=" .. background)

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
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
        on_attach = function(bufnr)
            local api = require "nvim-tree.api"
            local opt = { buffer = bufnr, silent = true }

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
                            -- stylua: ignore start
                            local extensions_opened_externally = {
                                "avi", "bmp", "doc", "docx", "exe", "flv", "gif", "jpg", "jpeg", "m4a", "mov", "mp3",
                                "mp4", "mpeg", "mpg", "pdf", "png", "ppt", "pptx", "psd", "pub", "rar", "rtf", "tif",
                                "tiff", "wav", "xls", "xlsx", "zip",
                            }
                            -- stylua: ignore end
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
            custom = { "node_modules", "^.git$" },
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
    keys = {
        { "<leader>uf", "<Cmd>NvimTreeToggle<CR>", desc = "toggle nvim tree", silent = true },
    },
}

config["nvim-treesitter"] = {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    dependencies = { "hiphish/rainbow-delimiters.nvim" },
    event = "User IceAfter colorscheme",
    branch = "main",
    opts = {
        -- Preserved for compatibility concerns
        -- stylua: ignore start
        ensure_installed = {
            "bash", "c", "c_sharp", "cpp", "css", "go", "html", "javascript", "json", "lua", "markdown",
            "markdown_inline", "python", "query", "rust", "toml", "typescript", "typst", "tsx", "vim", "vimdoc",
        },
        -- stylua: ignore end
    },
    config = function(_, opts)
        local nvim_treesitter = require "nvim-treesitter"
        nvim_treesitter.setup()

        local pattern = {}
        for _, parser in ipairs(opts.ensure_installed) do
            local has_parser, _ = pcall(vim.treesitter.language.inspect, parser)

            if not has_parser then
                -- Needs restart to take effect
                nvim_treesitter.install(parser)
            else
                vim.list_extend(pattern, vim.treesitter.language.get_filetypes(parser))
            end
        end

        local group = vim.api.nvim_create_augroup("NvimTreesitterFt", { clear = true })
        vim.api.nvim_create_autocmd("FileType", {
            group = group,
            pattern = pattern,
            callback = function(ev)
                local max_filesize = 100 * 1024
                local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(ev.buf))
                if not (ok and stats and stats.size > max_filesize) then
                    vim.treesitter.start()
                    if vim.bo.filetype ~= "dart" then
                        -- Conflicts with flutter-tools.nvim, causing performance issues
                        vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                    end
                end
            end,
        })

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
        rainbow_delimiters.enable()

        -- In markdown files, the rendered output would only display the correct highlight if the code is set to scheme
        -- However, this would result in incorrect highlight in neovim
        -- Therefore, the scheme language should be linked to query
        vim.treesitter.language.register("query", "scheme")

        vim.api.nvim_exec_autocmds("User", { pattern = "IceAfter nvim-treesitter" })
        vim.api.nvim_exec_autocmds("FileType", { group = "NvimTreesitterFt" })
    end,
}

config.orgmode = {
    "nvim-orgmode/orgmode",
    ft = { "org" },
    -- See https://github.com/nvim-orgmode/orgmode/blob/master/DOCS.md
    opts = {
        org_agenda_files = "~/Documents/orgfiles/**/*",
        org_default_notes_file = "~/Documents/orgfiles/refile.org",
        org_todo_keywords = { "TODO(t)", "URGENT(u)", "PENDING(p)", "|", "DONE(d)" },
        win_split_mode = { "float", 0.6 },
        org_startup_folded = "inherit",
        org_todo_keyword_faces = {
            URGENT = ":foreground white :background red :weight bold",
            PENDING = ":foreground white :background gray",
        },
        org_hide_leading_stars = true,
        org_hide_emphasis_markers = true,
        mappings = {
            org = {
                org_toggle_checkbox = "<leader>oT",
            },
        },
    },
    config = function(_, opts)
        require("blink.cmp").add_source_provider("orgmode", {
            name = "Orgmode",
            module = "orgmode.org.autocompletion.blink",
            fallbacks = { "buffer" },
        })
        Ice.__ORGMODE_SOURCE_ADDED = true
        require("orgmode").setup(opts)
    end,
    keys = {
        { "<leader>lf", "gggqG<C-o><C-o>", mode = "n", desc = "format file", ft = "org", silent = true },
        { "<leader>lf", "gq", mode = "v", desc = "format selected", ft = "org", silent = true },
        { "<leader>oa", "<Cmd>Org agenda<CR>", desc = "orgmode agenda" },
        { "<leader>oc", "<Cmd>Org capture<CR>", desc = "orgmode capture" },
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
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && "
                .. "cmake --build build --config Release && "
                .. "cmake --install build --prefix build",
        },
    },
    -- ensure that other plugins that use telescope can function properly
    cmd = "Telescope",
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
    end,
    keys = {
        { "<leader>tf", "<Cmd>Telescope find_files<CR>", desc = "find file", silent = true },
        { "<leader>t<C-f>", "<Cmd>Telescope live_grep<CR>", desc = "live grep", silent = true },
    },
}

config["todo-comments"] = {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "User IceLoad",
    main = "todo-comments",
    opts = {},
    keys = {
        { "<leader>ut", "<Cmd>TodoTelescope<CR>", desc = "todo list", silent = true },
    },
}

config.ufo = {
    "kevinhwang91/nvim-ufo",
    dependencies = {
        "kevinhwang91/promise-async",
    },
    event = "VeryLazy",
    opts = {
        preview = {
            win_config = {
                border = "rounded",
                winhighlight = "Normal:Folded",
                winblend = 0,
            },
        },
    },
    config = function(_, opts)
        vim.opt.foldenable = true

        require("ufo").setup(opts)
    end,
    keys = {
        {
            "zR",
            function()
                require("ufo").openAllFolds()
            end,
            desc = "Open all folds",
        },
        {
            "zM",
            function()
                require("ufo").closeAllFolds()
            end,
            desc = "Close all folds",
        },
        {
            "zp",
            function()
                require("ufo").peekFoldedLinesUnderCursor()
            end,
            desc = "Preview folded content",
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
        { "<leader>uu", "<Cmd>UndotreeToggle<CR>", desc = "undo tree toggle", silent = true },
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
            { "<leader>a", group = "+avante" },
            { "<leader>b", group = "+buffer" },
            { "<leader>c", group = "+comment" },
            { "<leader>f", group = "+fittencode" },
            { "<leader>g", group = "+git" },
            { "<leader>h", group = "+hop" },
            { "<leader>l", group = "+lsp" },
            { "<leader>o", group = "+orgmode" },
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

-- Colorschemes
config["github"] = { "projekt0n/github-nvim-theme", lazy = true }
config["gruvbox"] = { "ellisonleao/gruvbox.nvim", lazy = true }
config["kanagawa"] = { "rebelot/kanagawa.nvim", lazy = true }
config["miasma"] = { "xero/miasma.nvim", lazy = true }
config["nightfox"] = { "EdenEast/nightfox.nvim", lazy = true }
config["tokyonight"] = { "folke/tokyonight.nvim", lazy = true }

Ice.plugins = config
