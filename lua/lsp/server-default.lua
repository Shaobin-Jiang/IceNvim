local server = {}

local common = require "lsp.utils"

server.default = {
    capabilities = common.capabilities,
    flags = common.flags,
    on_attach = function(client, bufnr)
        common.disableFormat(client)
        common.keyAttach(bufnr)
    end,
}

server.cssls = vim.tbl_extend("force", server.default, {
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

server.denols = {
    root_dir = require("lspconfig").util.root_pattern(
        "deno.json",
        "deno.jsonc"
    ),
    capabilities = common.capabilities,
    flags = common.flags,
    on_attach = function(client, bufnr)
        local active_client = vim.lsp.get_active_clients { name = "tsserver" }
        if #active_client > 0 then
            active_client[1].stop()
        end
        common.disableFormat(client)
        common.keyAttach(bufnr)
        vim.keymap.del("n", "<leader>fm", { buffer = bufnr })
        vim.keymap.set(
            "n",
            "<leader>fm",
            "<cmd>w<CR><cmd>!deno fmt %<CR><CR>",
            { noremap = true, silent = true, buffer = bufnr }
        )
    end,
}

server.emmet_ls = {
    filetypes = {
        "html",
        "typescriptreact",
        "javascriptreact",
        "css",
        "sass",
        "scss",
        "less",
    },
}

local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")
server.lua_ls = vim.tbl_extend("force", server.default, {
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

server.omnisharp = vim.tbl_extend("force", server.default, {
    cmd = {
        "dotnet",
        vim.fn.stdpath "data" .. "/mason/packages/omnisharp/Omnisharp.dll",
    },
    on_attach = function(client, bufnr)
        server.default.on_attach(client, bufnr)
        client.server_capabilities.semanticTokensProvider = nil
    end,
    enable_editorconfig_support = true,
    enable_ms_build_load_projects_on_demand = false,
    enable_roslyn_analyzers = false,
    organize_imports_on_format = false,
    enable_import_completion = false,
    sdk_include_prereleases = true,
    analyze_open_documents_only = false,
})

server.tsserver = {
    single_file_support = true,
    capabilities = common.capabilities,
    flags = common.flags,
    on_attach = function(client, bufnr)
        if #vim.lsp.get_active_clients { name = "denols" } > 0 then
            client.stop()
        else
            common.disableFormat(client)
            common.keyAttach(bufnr)
        end
    end,
}

return server
