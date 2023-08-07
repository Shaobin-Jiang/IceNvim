-- Import symbol settings
local symbols = require("settings").symbols

-- Set up mason
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

for name, config in pairs(require("settings").lsp.servers) do
    if lspconfig[name] ~= nil then
        if type(config) == "table" then
            lspconfig[name].setup(config)
        else
            local predefined_config = require("lsp.server-default")[name]
            if predefined_config ~= nil then
                lspconfig[name].setup(predefined_config)
            else
                lspconfig[name].setup(require("lsp.server-default").default)
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
local signs = { Error = symbols.Error, Warn = symbols.Warn, Hint = symbols.Hint, Info = symbols.Info }
for type, icon in pairs(signs) do
    local hl = "DiagnosticSign" .. type
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

local lspsaga = require "lspsaga"
lspsaga.setup {
    debug = false,
    use_saga_diagnostic_sign = true,
    error_sign = symbols.Error,
    warn_sign = symbols.Warn,
    hint_sign = symbols.Hint,
    infor_sign = symbols.Info,
    diagnostic_header_icon = symbols.Diagnostic,
    code_action_icon = symbols.CodeAction,
    code_action_prompt = {
        enable = true,
        sign = false,
        sign_priority = 40,
        virtual_text = true,
    },
    finder_definition_icon = symbols.LspSagaFinder,
    finder_reference_icon = symbols.LspSagaFinder,
    max_preview_lines = 10,
    finder_action_keys = {
        open = "<CR>",
        vsplit = "s",
        split = "i",
        quit = "<ESC>",
        scroll_down = "<C-f>",
        scroll_up = "<C-b>",
    },
    code_action_keys = {
        quit = "<ESC>",
        exec = "<CR>",
    },
    rename_action_keys = {
        quit = "<ESC>",
        exec = "<CR>",
    },
    definition_preview_icon = symbols.Definition,
    border_style = "single",
    rename_prompt_prefix = symbols.RenamePrompt,
    rename_output_qflist = {
        enable = false,
        auto_open_qflist = false,
    },
    server_filetype_map = {},
    diagnostic_prefix_format = "%d. ",
    diagnostic_message_format = "%m %c",
    highlight_prefix = false,
}

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

-- Set up cmp
local cmp = require "cmp"

cmp.setup {
    snippet = {
        expand = function(args)
            require('luasnip').lsp_expand(args.body)
        end,
    },
    sources = cmp.config.sources({
        { name = "nvim_lsp" },
        { name = "luasnip" },
        { name = "neorg" },
    }, {
        { name = "buffer" },
        { name = "path" },
    }),
    mapping = require("settings").lsp.keymap.cmp(cmp),
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

-- Set up null-ls
local null_ls = require "null-ls"

local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics
local code_actions = null_ls.builtins.code_actions

null_ls.setup {
    debug = false,
    sources = require("settings").lsp.null_ls_sources(
        formatting,
        diagnostics,
        code_actions
    ),
    diagnostics_format = "[#{s}] #{m}",
}
