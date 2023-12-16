local lsp = {}

lsp.keyAttach = function(bufnr)
    require("core.utils").group_map(lsp.keymap.mapLsp, { noremap = true, silent = true, buffer = bufnr })
end

lsp.disableFormat = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

lsp.flags = {
    debounce_text_changes = 150,
}

-- Do not configure dartls here when using flutter-tools
lsp.ensure_installed = {
    "clangd",
    "css-lsp",
    "emmet-ls",
    "html-lsp",
    "json-lsp",
    "lua-language-server",
    "omnisharp",
    "pyright",
    "typescript-language-server",
    "autopep8",
    "csharpier",
    "fixjson",
    "prettier",
    "shfmt",
    "stylua",
}

lsp.servers = {
    "clangd",
    "cssls",
    "emmet_ls",
    "html",
    "jsonls",
    "lua_ls",
    "omnisharp",
    "pyright",
    "tsserver",
}

local config = {}

config.default = function()
    return {
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        flags = lsp.flags,
        on_attach = function(client, bufnr)
            lsp.disableFormat(client)
            lsp.keyAttach(bufnr)
        end,
    }
end

config.cssls = function()
    return vim.tbl_extend("force", config.default(), {
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
    })
end

config.emmet_ls = function()
    return {
        filetypes = { "html", "typescriptreact", "javascriptreact", "css", "sass", "scss", "less" },
    }
end

config.lua_ls = function()
    local runtime_path = vim.split(package.path, ";")
    table.insert(runtime_path, "lua/?.lua")
    table.insert(runtime_path, "lua/?/init.lua")
    return vim.tbl_extend("force", config.default(), {
        settings = {
            Lua = {
                runtime = {
                    version = "LuaJIT",
                    path = runtime_path,
                },
                diagnostics = {
                    globals = { "vim" },
                },
                workspace = {
                    library = vim.api.nvim_get_runtime_file("", true),
                    checkThirdParty = false,
                },
                telemetry = {
                    enable = false,
                },
            },
        },
    })
end

config.omnisharp = function()
    return vim.tbl_extend("force", config.default(), {
        cmd = {
            "dotnet",
            vim.fn.stdpath "data" .. "/mason/packages/omnisharp/Omnisharp.dll",
        },
        on_attach = function(client, bufnr)
            client.server_capabilities.semanticTokensProvider = nil
            config.default.on_attach(client, bufnr)
        end,
        enable_editorconfig_support = true,
        enable_ms_build_load_projects_on_demand = false,
        enable_roslyn_analyzers = false,
        organize_imports_on_format = false,
        enable_import_completion = false,
        sdk_include_prereleases = true,
        analyze_open_documents_only = false,
    })
end

config.tsserver = function()
    return {
        single_file_support = true,
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
        flags = lsp.flags,
        on_attach = function(client, bufnr)
            if #vim.lsp.get_active_clients { name = "denols" } > 0 then
                client.stop()
            else
                lsp.disableFormat(client)
                lsp.keyAttach(bufnr)
            end
        end,
    }
end

lsp["server-config"] = config

local keymap = {}

keymap.mapLsp = {
    rename = { "n", "<leader>lr", ":Lspsaga rename<CR>" },
    code_action = { "n", "<leader>lc", ":Lspsaga code_action<CR>" },
    go_to_definition = { "n", "<leader>ld", ":lua vim.lsp.buf.definition()<CR>" },
    doc = { "n", "<leader>lh", ":Lspsaga hover_doc<CR>" },
    references = { "n", "<leader>lR", ":Lspsaga lsp_finder<CR>" },
    go_to_implementation = { "n", "<leader>li", ":lua vim.lsp.buf.implementation()<CR>" },
    show_line_diagnostic = { "n", "<leader>lP", ":Lspsaga show_line_diagnostics<CR>" },
    next_diagnostic = { "n", "<leader>ln", ":Lspsaga diagnostic_jump_next<CR>" },
    prev_diagnostic = { "n", "<leader>lp", ":Lspsaga diagnostic_jump_prev<CR>" },
    copy_diagnostic = { "n", "<leader>ly", ":Lspsaga yank_line_diagnostics<CR>" },
    format_code = {
        "n",
        "<leader>lf",
        function()
            local lsp_is_active = require("plugins.utils").lsp_is_active

            if lsp_is_active "denols" then
                vim.cmd ":w"
                vim.cmd "!deno fmt %"
                vim.cmd ""
                return
            end

            if lsp_is_active "rust_analyzer" then
                vim.cmd ":w"
                vim.cmd "!cargo fmt"
                vim.cmd ""
                return
            end

            vim.lsp.buf.format { async = true }
        end,
    },
}

keymap.cmp = function(cmp)
    return {
        -- Show completion
        ["<A-.>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        -- Cancel
        ["<A-,>"] = cmp.mapping {
            i = cmp.mapping.abort(),
            c = cmp.mapping.close(),
        },
        ["<C-k>"] = cmp.mapping.select_prev_item(),
        ["<C-j>"] = cmp.mapping.select_next_item(),
        ["<Tab>"] = cmp.mapping.confirm {
            select = true,
            behavior = cmp.ConfirmBehavior.Replace,
        },
        ["<C-u>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-d>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
    }
end

lsp.keymap = keymap

Ice.lsp = lsp
