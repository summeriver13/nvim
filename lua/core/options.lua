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

-- 鼠标与交互 - Vibe Coding 提升点
-- 1. 全模式鼠标支持
opt.mouse = "a"
-- 2. 鼠标滚轮速度优化
opt.mousescroll = "ver:3,hor:2"
-- 3. 开启右键菜单，让 Neovim 更有 GUI 质感
opt.mousemodel = "popup"
-- 4. 禁用选择模式，确保鼠标拖拽进入 Visual Mode 而不是 Select Mode
opt.selectmode = ""
-- 5. 延迟时间（影响 WhichKey 和鼠标菜单弹出速度）
opt.updatetime = 300
opt.timeoutlen = 400
