# nvim

nvim config for myself.

## environment

Windows11, WSL2, Debain.

## requirements

**Please make sure that your network environment is normal,especially that you can access Github.**

- neovim. (Version: >=0.8) ([lazy.nvim]())
- git
- wget or curl, unzip, tar or gtar,gzip. ([mason.nvim](https://github.com/williamboman/mason.nvim?tab=readme-ov-file#requirements))

## quick start

Enter your `.config` directory.

```bash
cd ~/.config
```

Clone config file.

```bash
git clone https://gitee.com/summeriver13/nvim.git
```

Open any file with nvim.
Than waitting for plugin manager download plugins.

```bash
nvim nvim/init.lua
```

Finshed.

## struct

```bash
# ~/.config/nvim
.
├── init.lua
├── lua
│   ├── core
│   ├── kits
│   └── plugins
└── README.md
```

## init.lua

import core,kits,plugins.

```lua
require("core.options")
require("core.keymaps")

require("kits.plugin-manager")      -- plugin manager 插件管理器
require("kits.theme.tokyonight")    -- theme 主题 
require("kits.line")                -- line 状态栏
require("kits.buffer")              -- buffer 标签栏
require("kits.tree")                -- tree 文件树
require("kits.lsp")                 -- lsp 语言服务协议
require("kits.cmp")                 -- cmp 代码补全
require("kits.comment")             -- comment 注释
require("kits.autopair")            -- autopair 括号匹配
require("kits.file-search")         -- file search 文件搜索
```

## core

manage nvim basic setting.

### options.lua

```lua
local opt = vim.opt

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 2
opt.expandtab = true
opt.autoindent = true

-- 防止包裹
opt.wrap = false

-- 光标行
opt.cursorline = true

-- 系统剪贴板
opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 外观
opt.termguicolors = true
opt.signcolumn = "yes"
``` 

### keymaps.lua 按键映射

```lua
vim.g.mapleader = " "

local keymap = vim.keymap

-- ## Vim模式

-- [insert 插入模式] --
keymap.set("i", "jk", "<ESC>")

-- [view 视觉模式] --
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- [normal 正常模式] --
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>h") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- ## Plugin 插件
-- nvim-tree
keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>")

-- 切换buffer
keymap.set("n", "<C-L>", ":bnext<CR>")
keymap.set("n", "<C-H>", ":bprevious<CR>")
```

## kits

manage nvim plugins usage.

```bash
.
├── autopair.lua        # 括号匹配
├── buffer.lua          # 标签栏
├── cmp.lua             # 代码补全
├── comment.lua         # 注释
├── file-search.lua     # 文件搜索
├── line.lua            # 状态栏
├── lsp.lua             # LSP
├── plugin-manager.lua  # 插件管理器
├── theme               # 主题
└── tree.lua            # 文件树
```

### theme

Add new theme.lua here.

```bash
theme
 └── tokyonight.lua
```

`kits.theme` may affect `kits.line`.
Please make sure that line is setting correct when you change theme.

## plugins

manage nvim plugins install.

- bufferline.lua
    - [akinsho/bufferlin.nvim](https://github.com/akinsho/bufferline.nvim)
- cmp.lua
    - [hrsh7th/nvim-cmp](https://github.com/hrsh7th/nvim-cmp)
    - [hrsh7th/cmp-nvim-lsp](https://github.com/hrsh7th/cmp-nvim-lsp)
    - [L3MON4D3/LuaSnip](https://github.com/L3MON4D3/LuaSnip)
    - [saadparwaiz1/cmp_luasnip](https://github.com/saadparwaiz1/cmp_luasnip)
    - [rafamadriz/friendly-snippets](https://github.com/rafamadriz/friendly-snippets)
    - [hrsh7th/cmp-path](https://github.com/hrsh7th/cmp-path)
- comment.lua
    - [numToStr/Comment.nvim](https://github.com/numToStr/Comment.nvim)
    - [windwp/nvim-autopairs](https://github.com/windwp/nvim-autopairs)
- gitsigns.lua
    - [lewis6991/gitsigns.nvim](https://github.com/lewis6991/gitsigns.nvim)
- init.lua
    - [folke/lazy.nvim](https://github.com/folke/lazy.nvim)
- lualine.lua
    - [nvim-lualine/lualine.nvim](https://github.com/nvim-lualine/lualine.nvim)
- mason-lspconfig.lua
    - [williamboman/mason-lspconfig](https://github.com/williamboman/mason-lspconfig)
- mason.lua
    - [williamboman/mason.nvim](https://github.com/williamboman/mason.nvim)
- nvim-lspconfig.lua
    - [neovim/nvim-lspconfig](https://github.com/neovim/nvim-lspconfig)
- nvim-tree.lua
    - [nvim-tree/nvim-tree.lua](https://github.com/nvim-tree/nvim-tree.lua)
- nvim-treesitter.lua
    - [nvim-treesitter/nvim-treesitter](https://github.com/nvim-treesitter.nvim)
- telescope.lua
    - [nvim-telescope/telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- tokyonight.lua
    - [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)
- vim-tmux-navigator.lua
    - [christoomey/vim-tmux-navigator](https://github.com/christoomey/vim-tmux-navigator)

