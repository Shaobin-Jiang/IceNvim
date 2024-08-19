local lsp = {}

lsp = {
    clangd = {
        enabled = false,
    },
    ["css-lsp"] = {
        formatter = "prettier",
        setup = {
            settings = {
                css = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                less = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
                scss = {
                    validate = true,
                    lint = {
                        unknownAtRules = "ignore",
                    },
                },
            },
        },
        enabled = false,
    },
    ["emmet-ls"] = {
        setup = {
            filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
        },
        enabled = false,
    },
    flutter = {
        managed_by_plugin = true,
        enabled = false,
    },
    gopls = {
        formatter = "gofumpt",
        setup = {
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                    },
                },
            },
        },
        enabled = false,
    },
    ["html-lsp"] = {
        formatter = "prettier",
        enabled = false,
    },
    ["json-lsp"] = {
        formatter = "prettier",
        enabled = false,
    },
    ["lua-language-server"] = {
        formatter = "stylua",
        setup = {
            settings = {
                Lua = {
                    runtime = {
                        version = "LuaJIT",
                        path = (function()
                            local runtime_path = vim.split(package.path, ";")
                            table.insert(runtime_path, "lua/?.lua")
                            table.insert(runtime_path, "lua/?/init.lua")
                            return runtime_path
                        end)(),
                    },
                    diagnostics = {
                        globals = { "vim" },
                    },
                    workspace = {
                        library = {
                            vim.env.VIMRUNTIME,
                            "${3rd}/luv/library",
                        },
                        checkThirdParty = false,
                    },
                    telemetry = {
                        enable = false,
                    },
                },
            },
        },
        enabled = false,
    },
    omnisharp = {
        formatter = "csharpier",
        setup = {
            cmd = {
                "dotnet",
                vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/Omnisharp.dll",
            },
            on_attach = function(client, bufnr)
                client.server_capabilities.semanticTokensProvider = nil
            end,
        },
        enabled = false,
    },
    pyright = {
        formatter = "black",
        enabled = false,
    },
    rust = {
        managed_by_plugin = true,
        enabled = false,
    },
    ["typescript-language-server"] = {
        formatter = "prettier",
        setup = {
            single_file_support = true,
            flags = lsp.flags,
            on_attach = function(client, bufnr)
                if #vim.lsp.get_clients { name = "denols" } > 0 then
                    client.stop()
                end
            end,
        },
        enabled = false,
    },
    ["typst-lsp"] = {
        formatter = "typstfmt",
        enabled = false,
    },
}

Ice.lsp = lsp
