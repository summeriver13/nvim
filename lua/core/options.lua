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

-- Vibe Coding 提升：显式配置 Windows 剪贴板，解决粘贴失效的问题
if vim.fn.has("win32") == 1 then
  vim.g.clipboard = {
    name = "win32yank-vibe",
    copy = {
      ["+"] = "win32yank.exe -i --crlf",
      ["*"] = "win32yank.exe -i --crlf",
    },
    paste = {
      ["+"] = "win32yank.exe -o --lf",
      ["*"] = "win32yank.exe -o --lf",
    },
    cache_enabled = 0,
  }
end

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
-- 延迟时间（影响 WhichKey 和鼠标菜单弹出速度）
opt.updatetime = 300
opt.timeoutlen = 400

-- Vibe Coding 提升：全面汉化界面 (系统语言与菜单)
-- 设置语言为中文 (zh_CN)
vim.api.nvim_command("language zh_CN.UTF-8")
-- 设置消息显示为中文
vim.api.nvim_command("language message zh_CN.UTF-8")
-- 菜单汉化 (如果支持)
opt.langmenu = "zh_CN.UTF-8"
-- 拼写检查建议使用中文 (可选)
opt.spelllang = { "en_us", "cjk" }
