local utils = require "plugins.utils"

Ice.keymap.plugins = {
    check_icons = { "n", "<leader>ui", utils.check_icons },
    lazy_profile = {
        "n",
        "<leader>ul",
        "<Cmd>Lazy profile<CR>",
    },
    select_colorscheme = { "n", "<C-k><C-t>", utils.select_colorscheme },
    view_configuration = { "n", "<leader>uc", utils.view_configuration },
}
