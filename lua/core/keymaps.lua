--[[
快捷键配置模块 - Vibe Coding 交互体验
功能：AI交互快捷键定义 + 零冲突设计 + 肌肉记忆优化
Vibe Coding 提升点：
  1. 逻辑快捷键分组：AI快捷键统一使用<leader>a前缀，形成肌肉记忆集群
  2. 零冲突设计：严格避免与LSP/Telescope快捷键重叠，确保每个快捷键意图明确
  3. 模态感知映射：根据编辑模式（普通/可视）自动切换AI功能，减少模式切换负担
]]

-- Vibe Coding 提升：统一的前缀设计让AI功能易于记忆和触达
-- # core/keymaps.lua

vim.g.mapleader = " "

local keymap = vim.keymap

-- ## Vim模式

-- [插入模式] --
keymap.set("i", "jk", "<ESC>")

-- [视觉模式] --
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- [正常模式] --
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>h") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>nh", ":nohl<CR>")

-- ## 鼠标交互优化 - Vibe Coding 提升点
-- 1. 点击代码区域时自动取消搜索高亮（类似 GUI 行为，点击背景/新位置取消选择）
keymap.set("n", "<LeftMouse>", "<LeftMouse>:nohl<CR>", { silent = true })

-- 2. 插入模式下点击鼠标，自动切换回 Normal 模式进行定位，确保编辑区以 Vim 模式为主
-- 这实现了用户要求的“点击代码区域时使用 Vim 模式为主”的体验
keymap.set("i", "<LeftMouse>", "<Esc><LeftMouse>", { silent = true })

-- ## Plugin 插件
-- nvim-tree
keymap.set("n", "<leader>t", ":NvimTreeToggle<CR>")

-- 切换buffer
keymap.set("n", "<C-L>", ":bnext<CR>")
keymap.set("n", "<C-H>", ":bprevious<CR>")

-- ## AI 交互
-- Vibe Coding 提升：AI交互快捷键集群化设计，形成流畅的AI辅助编码工作流
-- 打开/关闭AI侧边栏 (类似Cursor的聊天界面)
keymap.set("n", "<leader>ai", ":AIChat<CR>", { desc = "打开/关闭AI聊天侧边栏" })
-- 发送选中代码给AI分析
keymap.set("v", "<leader>ac", ":AICode<CR>", { desc = "发送选中代码给AI分析" })
-- 发送错误日志给AI调试
keymap.set("n", "<leader>ad", ":AIDebug<CR>", { desc = "发送错误日志给AI调试" })
-- Copilot补全与Avante架构切换 (配置在 kits/ai/copilot.lua 中)
