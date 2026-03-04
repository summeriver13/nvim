--[[
Snacks极简浮窗模块 - Vibe Coding 视觉体验
功能：类Cursor平滑浮窗 + AI响应可视化 + 进度条反馈
Vibe Coding 提升点：
  1. 非侵入式视觉反馈：AI响应以浮窗形式显示，不打断编辑区视线焦点
  2. 实时进度可视化：LSP和AI任务进度条让等待过程可感知，消除不确定感
  3. 统一视觉语言：所有AI交互使用相同浮窗样式，建立肌肉记忆和预期
]]

-- Vibe Coding 提升：配置类Cursor的平滑浮窗，让AI交互拥有统一的视觉语言
-- Snacks.nvim 配置：极简浮窗UI，提供类似Cursor的平滑视觉反馈
local snacks = require("snacks")

-- Vibe Coding 提升：极简风格配置，让UI成为内容的透明载体而非干扰
-- 基础配置：极简风格，专注内容呈现
snacks.setup({
  -- 浮窗样式：圆角边框，浅色背景
  window = {
    border = "rounded",
    padding = { 1, 2 },
    margin = { 5, 5 },
    style = "minimal",
  },
  
  -- 提示框配置：用于AI建议和快速操作
  hint = {
    enabled = true,
    timeout = 3000,
    position = "bottom-right",
    max_width = 50,
    max_height = 10,
  },
  
  -- 进度条配置：LSP和AI任务进度可视化
  progress = {
    enabled = true,
    format = "正在处理... {percent}%",
    position = "bottom",
    width = 50,
    height = 2,
  },
  
  -- 通知系统：与Noice.nvim集成，避免重复
  notify = {
    enabled = false, -- 使用Noice.nvim作为主通知系统
  },
  
  -- AI专用浮窗：显示AI响应和代码建议
  ai = {
    enabled = true,
    position = "right-center",
    width = 60,
    height = 20,
    border = "double",
    title = "AI助手",
  },
  
  -- 快捷键提示：在浮窗中显示可用操作
  keyhint = {
    enabled = true,
    position = "bottom",
    timeout = 5000,
  },
})

-- 与Avante AI集成：当AI响应时显示Snacks浮窗
local function setup_ai_integration()
  local ai_core = require("kits.ai.core")
  
  -- 监听AI响应事件：通过 kits.ai.core 注册回调，避免直接调用 avante.on_response (a nil value)
  ai_core.register_handler("snacks", function(response)
    -- 在Snacks浮窗中显示AI响应摘要
    snacks.show({
      type = "ai_response",
      content = response.summary or response.content:sub(1, 200),
      position = "right-center",
      timeout = 10000,
    })
  end)
  
  -- 当代码建议生成时显示浮动提示
  -- 注意：这里也需要适配，暂时保留结构但不直接调用 avante.on_suggestion
end

-- 环境感知：根据操作系统调整浮窗位置
local function setup_environment()
  local is_windows = package.config:sub(1,1) == "\\"
  
  if is_windows then
    -- Windows系统下调整浮窗边距，适应任务栏
    snacks.config.window.margin = { 8, 8 }
  else
    -- macOS/Linux系统使用默认边距
    snacks.config.window.margin = { 5, 5 }
  end
end

setup_ai_integration()
setup_environment()

print("✅ Snacks UI 配置完成 - 极简浮窗系统已启用")
