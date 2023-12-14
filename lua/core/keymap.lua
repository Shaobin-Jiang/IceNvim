-- Set leader key to space
vim.g.mapleader = " "

return {
    -- Black hole register
    -- See `:h quote_`
    { "\\", '"_', mode = { "n", "v" } },

    -- Clearing the command line
    { "<C-g>", ":echo<CR>", opt = { noremap = true }, mode = "n" },

    -- Map ctrl-z to undo in normal / insert / visual modes
    { "<C-z>", "<Esc>:u<CR>", mode = { "n", "i", "v" } },
    { "<C-z>", "<Nop>", mode = { "t", "c" } },

    -- Visual setting
    -- Indenting
    { "<", "<gv", mode = "v" },
    { ">", ">gv", mode = "v" },

    -- Saving files
    { "<C-s>", ":w<CR>", mode = "n" },
    { "<C-s>", "<Esc>:w<CR>", mode = { "i", "v" } },

    -- Open html file
    {
        "<A-b>",
        function()
            if vim.bo.filetype == "html" then
                vim.cmd "!explorer %"
            end
        end,
        mode = "n",
    },

    -- Terminal
    { "<C-t>", ":split term://bash<CR>", mode = "n" },
    { "<Esc>", "<C-\\><C-n>", mode = "t" },
}
