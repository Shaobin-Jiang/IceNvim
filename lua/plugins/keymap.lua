local keymap = {}

keymap.bufferline = {
    { "<C-h>", ":BufferLineCyclePrev<CR>", mode = "n" },
    { "<C-l>", ":BufferLineCycleNext<CR>", mode = "n" },
    -- <esc> is added in case current buffer is the last
    { "<A-w>", ":bdelete!<CR><Esc>", mode = "n" },
    { "<leader>bl", ":BufferLineCloseRight<CR>", mode = "n" },
    { "<leader>bh", ":BufferLineCloseLeft<CR>", mode = "n" },
    { "<leader>bc", ":BufferLinePickClose<CR>", mode = "n" },
    { "<leader>bo", ":BufferLineCloseOthers<CR>", mode = "n" },
}

keymap._comment = {
    toggler = { line = "gcc", block = "gbc" },
    opleader = { line = "gc", block = "gb" },
    extra = { above = "gcO", below = "gco", eol = "gcA" },
    mappings = { basic = true, extra = true, extended = false },
}

keymap.hop = {
    { "<leader>hp", ":HopWord<CR>", mode = "n" },
}

keymap["markdown-preview"] = {
    {
        "<leader>mdp",
        function()
            if vim.bo.filetype == "markdown" then
                vim.cmd "MarkdownPreviewToggle"
            end
        end,
        mode = "n",
    },
}

keymap["nvim-tree"] = {
    { "<C-b>", ":NvimTreeToggle<CR>", mode = "n" },
}

keymap._nvimTreeOnAttach = function(bufnr)
    local api = require "nvim-tree.api"
    local opt = {
        buffer = bufnr,
        noremap = true,
        silent = true,
        nowait = true,
    }

    api.config.mappings.default_on_attach(bufnr)

    require("core.utils").map_group {
        { "<CR>", api.node.open.edit, opt = opt, mode = "n" },
        { "<2-LeftMouse>", api.node.open.edit, opt = opt, mode = "n" },
        { "v", api.node.open.vertical, opt = opt, mode = "n" },
        { "h", api.node.open.horizontal, opt = opt, mode = "n" },
        { "i", api.tree.toggle_custom_filter, opt = opt, mode = "n" },
        { ".", api.tree.toggle_hidden_filter, opt = opt, mode = "n" },
        { "<F5>", api.tree.reload, opt = opt, mode = "n" },
        { "a", api.fs.create, opt = opt, mode = "n" },
        { "d", api.fs.remove, opt = opt, mode = "n" },
        { "r", api.fs.rename, opt = opt, mode = "n" },
        { "x", api.fs.cut, opt = opt, mode = "n" },
        { "y", api.fs.copy.node, opt = opt, mode = "n" },
        { "p", api.fs.paste, opt = opt, mode = "n" },
        { "s", api.node.run.system, opt = opt, mode = "n" },
    }
end

keymap["symbols-outline"] = {
    {
        "<leader>otl",
        function()
            ---@diagnostic disable-next-line: param-type-mismatch
            local status, _ = pcall(vim.cmd, "FlutterOutlineToggle")
            if not status then
                vim.cmd "SymbolsOutline"
            end
        end,
        mode = "n",
    },
}

keymap._outline = {
    close = { "<Esc>" },
    goto_location = "<Cr>",
    focus_location = "o",
    hover_symbol = "<C-space>",
    toggle_preview = "K",
    rename_symbol = "<leader>rn",
    code_actions = "<leader>ca",
    fold = "<leader>fd",
    unfold = "ufd",
    fold_all = "fda",
    unfold_all = "ufa",
    fold_reset = "R",
}

keymap.telescope = {
    { "<C-p>", ":Telescope find_files<CR>", mode = "n" },
    { "<leader><C-f>", ":Telescope live_grep<CR>", mode = "n" },
    { "<C-f>", ":Telescope current_buffer_fuzzy_find<CR>", mode = "n" },
    { "<C-k><C-t>", ":Telescope colorscheme<CR>", mode = "n" },
    { "<leader>env", ":Telescope env<CR>", mode = "n" },
}

keymap._telescopeList = {
    i = {
        ["<C-j>"] = "move_selection_next",
        ["<C-k>"] = "move_selection_previous",
        ["<C-n>"] = "cycle_history_next",
        ["<C-p>"] = "cycle_history_prev",
        ["<C-c>"] = "close",
        ["<C-u>"] = "preview_scrolling_up",
        ["<C-d>"] = "preview_scrolling_down",
    },
}

keymap["todo-comments"] = {
    {
        "<leader>nt",
        function()
            require("todo-comments").jump_next()
        end,
        mode = "n",
    },
    {
        "<leader>pt",
        function()
            require("todo-comments").jump_prev()
        end,
        mode = "n",
    },
    { "todo", ":TodoTelescope<CR>", mode = "n" },
}

keymap.trouble = {
    { "<leader>tt", ":TroubleToggle<CR>", mode = "n" },
}

keymap.undotree = {
    { "<leader>udt", ":UndotreeToggle<CR>", mode = "n" },
}

return keymap
