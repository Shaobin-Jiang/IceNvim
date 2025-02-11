local utils = require "plugins.utils"

Ice.keymap.plugins = {
    lazy_profile = { "n", "<leader>ul", "<Cmd>Lazy profile<CR>" },
    select_colorscheme = { "n", "<C-k><C-t>", utils.select_colorscheme },
    view_configuration = { "n", "<leader>uc", utils.view_configuration },
}
