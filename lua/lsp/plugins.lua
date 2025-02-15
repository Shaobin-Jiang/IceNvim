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
        lsp = {
            on_attach = function(_, bufnr)
                require("lsp.utils").lsp_attach_keymap(bufnr)
            end,
        },
    },
    enabled = function()
        return Ice.lsp.flutter.enabled == true
    end,
}

Ice.plugins.rustaceanvim = {
    "mrcjkb/rustaceanvim",
    ft = "rust",
    opts = {},
    config = function()
        vim.g.rustaceanvim = {
            server = {
                on_attach = function(_, bufnr)
                    require("lsp.utils").lsp_attach_keymap(bufnr)
                end,
            },
        }
    end,
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
    "williamboman/mason.nvim",
    dependencies = {
        "neovim/nvim-lspconfig",
        "williamboman/mason-lspconfig.nvim",
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
        local mason_lspconfig_mapping = require("mason-lspconfig.mappings.server").package_to_lspconfig

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

                local user_on_attach = function() end
                if type(setup.on_attach) == "function" then
                    user_on_attach = setup.on_attach
                end

                local on_attach = function(client, bufnr)
                    -- Only stop using lsp as format source if a formatter is set
                    if config.formatter ~= nil then
                        client.server_capabilities.documentFormattingProvider = false
                        client.server_capabilities.documentRangeFormattingProvider = false
                    end

                    require("lsp.utils").lsp_attach_keymap(bufnr)

                    user_on_attach(client, bufnr)
                end

                setup = vim.tbl_deep_extend("force", setup, {
                    capabilities = require("blink.cmp").get_lsp_capabilities(),
                    on_attach = on_attach,
                })

                lspconfig[lsp].setup(setup)
            end
            ::continue::
        end

        vim.diagnostic.config {
            update_in_insert = true,
            severity_sort = true, -- necessary for lspsaga's show_line_diagnostics to work
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

        vim.api.nvim_command "LspStart"
    end,
}
