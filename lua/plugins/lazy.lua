-- Lazy.nvim-specific configuration here
local lazy = {}

lazy.bufferline = {
    dependencies = {
        "nvim-tree/nvim-web-devicons",
    },
}

lazy.comment = {
    event = "VeryLazy",
}

lazy["flutter-tools"] = {
    dependencies = {
        "nvim-lua/plenary.nvim",
        "stevearc/dressing.nvim",
    },
    ft = "dart",
}

lazy.gitsigns = {
    event = "VeryLazy",
}

lazy.hop = {
    event = "VeryLazy",
}

lazy.lualine = {
    dependencies = {
        "nvim-tree/nvim-web-devicons",
        "arkav/lualine-lsp-progress",
    },
}

lazy["markdown-preview"] = {
    build = "cd app && npm install",
    ft = "markdown",
}

lazy.mason = {
    dependencies = {
        "williamboman/mason-lspconfig.nvim",
        "neovim/nvim-lspconfig",
    },
    event = "VeryLazy",
}

lazy.neogit = {
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
    config = true,
}

lazy.neoscroll = {
    event = "VeryLazy",
}

lazy["null-ls"] = {
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
}

lazy["nvim-autopairs"] = {
    event = "InsertEnter",
}

lazy["nvim-cmp"] = {
    dependencies = {
        "hrsh7th/vim-vsnip",
        "hrsh7th/cmp-vsnip",
        "hrsh7th/cmp-nvim-lsp",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "rafamadriz/friendly-snippets",
        "onsails/lspkind-nvim",
        "tami5/lspsaga.nvim",
    },
    event = "InsertEnter",
}

lazy["nvim-notify"] = {
    event = "VeryLazy",
}

lazy["nvim-scrollview"] = {
    event = "VeryLazy",
}

lazy["nvim-tree"] = {
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
}

lazy["nvim-treesitter"] = {
    build = ":TSUpdate",
    dependencies = { "p00f/nvim-ts-rainbow" },
    event = "VeryLazy",
    pin = true,
}

lazy["symbols-outline"] = {
    event = "VeryLazy",
}

lazy.telescope = {
    dependencies = {
        "nvim-lua/plenary.nvim",
        "LinArcX/telescope-env.nvim",
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            build = "make",
        },
    },
    event = "VeryLazy",
}

lazy["todo-comments"] = {
    dependencies = "nvim-lua/plenary.nvim",
    event = "VeryLazy",
}

lazy.trouble = {
    dependencies = "nvim-tree/nvim-web-devicons",
    event = "VeryLazy",
}

lazy.undotree = {
    event = "VeryLazy",
}

lazy["vim-surround"] = {
    event = "VeryLazy",
}

return lazy
