local default = {}

local colorscheme_cache = vim.fn.stdpath "data" .. "/colorscheme"
local f = io.open(colorscheme_cache, "r")
if f ~= nil then
    local colorscheme = f:read "*a"
    f:close()
    vim.g.user_colorscheme = require("core.colorscheme")[colorscheme]
else
    vim.g.user_colorscheme = require("core.colorscheme")["tokyonight"]
end

default.keymap = require "core.keymap"

default.symbols = {
    Affirmative = "✓ ",
    Array = " ",
    Boolean = " ",
    Class = "󰠱 ",
    CodeAction = " ",
    Color = "󰏘 ",
    Component = "󰡀 ",
    Constant = "󰏿 ",
    Constructor = " ",
    Definition = " ",
    Diagnostic = " ",
    Dice1 = "󰇊 ",
    Dice2 = "󰇋 ",
    Dice3 = "󰇌 ",
    Dice4 = "󰇍 ",
    Dice5 = "󰇎 ",
    Dice6 = "󰇏 ",
    Dos = " ",
    Enum = " ",
    EnumMember = " ",
    Error = " ",
    Event = " ",
    Field = "󰜢 ",
    File = "󰈙 ",
    Folder = "󰉋 ",
    Fragment = " ",
    Function = "󰊕 ",
    Hint = " ",
    Info = " ",
    Interface = " ",
    Key = " ",
    Keyword = "󰌋 ",
    LspSagaFinder = " ",
    Mac = " ",
    Method = "󰆧 ",
    Module = "󰆧 ",
    Namespace = " ",
    Negative = "✗ ",
    Null = "󰟢 ",
    Number = " ",
    Object = " ",
    Operator = "󰆕 ",
    Package = " ",
    Pending = "➜ ",
    Property = "󰜢 ",
    Reference = "󰈇 ",
    RenamePrompt = "➤ ",
    Snippet = " ",
    String = " ",
    Struct = "󰙅 ",
    Text = "󰉿 ",
    TypeParameter = "󰉺 ",
    Unit = "󰑭 ",
    Unix = " ",
    Value = "󰎠 ",
    Variable = "󰀫 ",
    Warn = " ",
}

default.lsp = {
    ensure_installed = {
        "clangd",
        "cssls",
        "denols",
        "emmet_ls",
        "html",
        "jsonls",
        "lua_ls",
        "omnisharp",
        "pyright",
        "tsserver",
    },
    null_ls_sources = function(formatting, _, _)
        return {
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
            formatting.autopep8,
        }
    end,
    -- Do not configure dartls here when using flutter-tools
    servers = {
        clangd = "",
        cssls = "",
        denols = "",
        emmet_ls = "",
        html = "",
        jsonls = "",
        lua_ls = "",
        omnisharp = "",
        pyright = "",
        tsserver = "",
    },
}

return default
