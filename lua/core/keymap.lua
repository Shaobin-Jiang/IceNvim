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

    -- Window management: starting with s
    { "s", "", mode = "n" }, -- Disable current mapping of s
    { "sV", ":vsp<CR>", mode = "n" }, -- Vertical split
    { "sH", ":sp<CR>", mode = "n" }, -- Horizontal split
    { "sh", ":vertical resize -10<CR>", mode = "n" }, -- Decrease current vertical split width
    { "sl", ":vertical resize +10<CR>", mode = "n" }, -- Increase current vertical split width
    { "sj", ":resize -5<CR>", mode = "n" }, -- Decrease current horizontal split height
    { "sk", ":resize +5<CR>", mode = "n" }, -- Increase current horizontal split height
    { "s=", "<C-w>=", mode = "n" }, -- Equal size

    -- Visual setting
    -- Indenting
    { "<", "<gv", mode = "v" },
    { ">", ">gv", mode = "v" },

    -- Move selected content
    { "J", ":move '>+1<CR>gv-gv", mode = "v" },
    { "K", ":move '<-2<CR>gv-gv", mode = "v" },

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
