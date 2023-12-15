local utils = require "plugins.utils"

Ice.keymap.plugins = {
    check_icons = { "n", "<leader>ico", utils.check_icons },
    select_colorscheme = { "n", "<leader>cs", utils.select_colorscheme },
    view_configuration = { "n", "<leader>cfg", utils.view_configuration },
}
