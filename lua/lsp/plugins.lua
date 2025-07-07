local symbols = Ice.symbols

Ice.plugins["flutter-tools"] = {
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
        },
        decorations = {
            statusline = {
                app_version = true,
                device = true,
            },
        },
    },
    enabled = function()
        return Ice.lsp.flutter.enabled == true
    end,
}

Ice.plugins.rustaceanvim = {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    enabled = function()
        return Ice.lsp.rust.enabled == true
    end,
}

Ice.plugins["typst-preview"] = {
    "chomosuke/typst-preview.nvim",
    ft = "typst",
    build = function()
        require("typst-preview").update()
    end,
    opts = {},
    keys = {
        { "<A-b>", "<Cmd>TypstPreviewToggle<CR>", desc = "typst preview toggle", ft = "typst", silent = true },
    },
    enabled = function()
        return Ice.lsp.tinymist.enabled == true
    end,
}

Ice.plugins.mason = {
    "mason-org/mason.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "mason-org/mason-lspconfig.nvim",
    },
    event = "User IceLoad",
    cmd = "Mason",
    opts = {
        ui = {
            icons = {
                package_installed = symbols.Affirmative,
                package_pending = symbols.Pending,
                package_uninstalled = symbols.Negative,
            },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        local registry = require "mason-registry"
        local function install(package)
            local s, p = pcall(registry.get_package, package)
            if s and not p:is_installed() then
                p:install()
            end
        end

        local lspconfig = require "lspconfig"
        local mason_lspconfig_mapping = require("mason-lspconfig").get_mappings().package_to_lspconfig

        local installed_packages = registry.get_installed_package_names()

        for lsp, config in pairs(Ice.lsp) do
            if not config.enabled then
                goto continue
            end

            local formatter = config.formatter
            install(lsp)
            install(formatter)

            if not vim.tbl_contains(installed_packages, lsp) then
                goto continue
            end

            lsp = mason_lspconfig_mapping[lsp]
            if not config.managed_by_plugin and lspconfig[lsp] ~= nil then
                local setup = config.setup
                if type(setup) == "function" then
                    setup = setup()
                elseif setup == nil then
                    setup = {}
                end

                local blink_capabilities = require("blink.cmp").get_lsp_capabilities()
                blink_capabilities.textDocument.foldingRange = {
                    dynamicRegistration = false,
                    lineFoldingOnly = true,
                }
                setup = vim.tbl_deep_extend("force", setup, {
                    capabilities = blink_capabilities,
                })

                vim.lsp.config(lsp, setup)
            end
            ::continue::
        end

        vim.diagnostic.config {
            update_in_insert = true,
            severity_sort = true, -- necessary for lspsaga's show_line_diagnostics to work
            virtual_text = true,
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

        vim.lsp.inlay_hint.enable()

        local function lsp_start()
            -- Do not directly call `LspStart` (although the code below is pretty much word-to-word copied from the command)
            -- The reason is that `LspStart` would raise an error if no matching server is configured. This becomes an issue
            -- when the first file we open does not have a matching server. Therefore, we gotta check whether a server
            -- exists first.
            local servers = {}
            local filetype = vim.bo.filetype
            ---@diagnostic disable-next-line: invisible
            for name, _ in pairs(vim.lsp.config._configs) do
                local filetypes = vim.lsp.config[name].filetypes
                if filetypes and vim.tbl_contains(filetypes, filetype) then
                    table.insert(servers, name)
                end
            end

            if #servers > 0 then
                vim.lsp.enable(servers)
            else
                vim.api.nvim_create_autocmd("FileType", {
                    once = true,
                    callback = lsp_start,
                })
            end
        end

        lsp_start()
    end,
}
