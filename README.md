<h1 align="center">IceNvim</h1>

<div align="center">

[![Neovim Minimum Version](https://img.shields.io/badge/Neovim-0.9.0-blueviolet.svg?style=flat-square&color=90E59A&logoColor=white)](https://github.com/neovim/neovim)
[![GitHub License](https://img.shields.io/github/license/Shaobin-Jiang/IceNvim?style=flat-square&color=EE999F&logoColor=white)](https://github.com/Shaobin-Jiang/IceNvim/blob/master/LICENSE)

</div>

IceNvim is a beautiful, powerful and customizable neovim config.

## Showcase

![](./screenshots/1.jpg)

![](./screenshots/2.jpg)

![](./screenshots/3.jpg)

## Features

- Ideal for development:
  - Set up for C# / Flutter / Lua / Python / Rust / Web development and markdown writing
  - Git integration
- Enhanced editing experience:
  - Plugins such as `hop.nvim`, `undotree` and `vim-surround`
  - For Chinese users, automatic IME switching when changing modes (needs [additional setup](#download-im-selectexe-recommended-for-windows--wsl-users))
- Nice looks:
  - Multiple colorschemes made ready
  - A custom colorschemes picker
- User friendly:
  - Uses which-key.nvim for new comers to check out keymaps
- Well equiped:
  - An icon viewer to check whether your font works well with icons
  - A configuration file selector
- Modern: uses `Lazy` and `Mason`
- Customizable:
  - Override defaults with your own [config file](#custom-configuration)

## Requirements

- This neovim configuration requires neovim **0.9.0+**
- Additionally, you need to install these also:
  - A [nerd font](https://www.nerdfonts.com/font-downloads): this is optional, but things may look funny without one installed
  - git: almost all the plugin and lsp installations depend on it
  - Required by Mason:
    - curl
    - gzip / 7zip
    - wget
  - Required by telescope:
    - fd
    - ripgrep
  - Required by nvim treesitter:
    - gcc
    - node
    - npm
  - Required by rust-tools:
    - rust-analyzer (NOT the rust-analyzer provided by Mason!!!)
  - python3 and pip3
  - Additional dependencies on Linux:
    - unzip
    - virtual environment
    - xclip (for accessing system clipboard; **not required on WSL**)
    - zip

Note that some of the packages might have different names with different package managers!

## Installation

On Windows:

```bash
git clone https://github.com/Shaobin-Jiang/neovim "$env:LOCALAPPDATA\nvim"
```

On Linux:

```bash
git clone https://github.com/Shaobin-Jiang/neovim ~/.config/nvim
```

### Download `im-select.exe` (recommended for windows / wsl users)

For automatic IME switching when inputing Chinese, im-select.exe is needed.

Download it from [https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe](https://github.com/daipeihust/im-select/raw/master/win/out/x86/im-select.exe) and place to the `bin` repository in the configuration directory.

Additionally, if you are using wsl, you might have to do this:

```bash
chmod +x ~/.config/nvim/bin/im-select.exe
```

## Custom Configuration

This neovim configuration allows users to override the default configuration by creating a `custom` dir under `lua/`.

IceNvim will try to detect and load `custom/init.lua`. Since `custom/` is git-ignored, it will be easy for you to make your own configurations without messing up the original git repo and missing follow-up updates.

Most IceNvim config options can be found under a global variable `Ice`. The entire setup follows this routine:

- IceNvim sets its default options and store some of them, e.g., plugin config and keymaps, in `Ice`
- IceNvim loads `custom/init.lua`
- IceNvim uses `Ice` to set up plugins and create keymaps

Therefore, almost everything IceNvim defines can be re-configured by you.

An example `custom/init.lua`:

```lua
Ice.plugins["nvim-transparent"].enabled = false

Ice.keymap.general.open_terminal = { "n", "<leader>terminal", ":split term://bash<CR>" }

local autogroup = vim.api.nvim_create_augroup("OverrideFtplugin", { clear = true })
vim.api.nvim_create_autocmd("BufEnter", {
    group = autogroup,
    callback = function()
        if vim.bo.filetype == "lua" then
            vim.cmd "setlocal colorcolumn=120"
        end
    end,
})
```

## Troubleshooting

### Installing Omnisharp / Csharpier

When installing omnisharp, make sure that dotnet sdk is installed.

When receiving nuget-related errors when installing csharpier, you might have to configure nuget source (see [https://learn.microsoft.com/zh-cn/nuget/reference/errors-and-warnings/nu1100#solution-2](https://learn.microsoft.com/zh-cn/nuget/reference/errors-and-warnings/nu1100#solution-2)):

```shell
dotnet nuget add source https://api.nuget.org/v3/index.json -n nuget.org
```

### Opening Links in `norg` Files on Wsl

By custom, Neorg uses `explorer.exe` to open links on Wsl. While this may work well with opening web links, it is not
quite so with file links, such as `{file:///path/to/file}`, as this is not a recognizable link for Windows' `explorer.exe`.

Until a workaround is provided by Neorg, one can define an `explorer.exe` in `/bin`:

```bash
echo 'wslview "$*' | sudo tee /bin/explorer.exe
sudo chmod +x /bin/explorer.exe
```

My preferred way of opening files with Windows programs is [`wslview`](https://wslutiliti.es/wslu/), but you can still use whatever command you like better, such as `xdg-open`.

### Rust not Working Properly

You need to check how you installed rust. I have not been able to set up rust-analyzer when installing rust only (e.g., via `scoop install rust` or `sudo zypper in rust`) either, but with the officially recommended way, i.e., by installing rustup, everything works properly.

Also, you might find that completion does not work when first opening a rust project. That is because some time needs to be taken to index the code, and completion would only work after indexing is done.
