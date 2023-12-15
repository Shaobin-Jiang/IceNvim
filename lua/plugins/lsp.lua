local lsp = {}

lsp.keyAttach = function(bufnr)
    require("core.utils").group_map(
        lsp.keymap.mapLsp,
        { noremap = true, silent = true, buffer = bufnr }
    )
end

lsp.disableFormat = function(client)
    client.server_capabilities.documentFormattingProvider = false
    client.server_capabilities.documentRangeFormattingProvider = false
end

lsp.flags = {
    debounce_text_changes = 150,
}

local server = {}

server.default = {
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    flags = lsp.flags,
    on_attach = function(client, bufnr)
        lsp.disableFormat(client)
        lsp.keyAttach(bufnr)
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
    capabilities = require("cmp_nvim_lsp").default_capabilities(),
    flags = lsp.flags,
    on_attach = function(client, bufnr)
        local active_client = vim.lsp.get_active_clients { name = "tsserver" }
        if #active_client > 0 then
            active_client[1].stop()
        end
        lsp.disableFormat(client)
        lsp.keyAttach(bufnr)
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

lsp.server = server

local keymap = {}

keymap.mapLsp = {
    rename = { "n", "<leader>rn", ":Lspsaga rename<CR>" },
    code_action = { "n", "<leader>ca", ":Lspsaga code_action<CR>" },
    go_to_definition = { "n", "gd", ":lua vim.lsp.buf.definition()<CR>" },
    doc = { "n", "gh", ":Lspsaga hover_doc<CR>" },
    references = { "n", "gr", ":Lspsaga lsp_finder<CR>" },
    go_to_implementation = { "n", "gi", ":lua vim.lsp.buf.implementation()<CR>" },
    show_line_diagnostic = { "n", "gP", ":Lspsaga show_line_diagnostics<CR>" },
    next_diagnostic = { "n", "gn", ":Lspsaga diagnostic_jump_next<CR>" },
    prev_diagnostic = { "n", "gp", ":Lspsaga diagnostic_jump_prev<CR>" },
    copy_diagnostic = { "n", "gy", ":Lspsaga yank_line_diagnostics<CR>" },
    format_code = {
        "n",
        "<leader>fm",
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

return lsp
