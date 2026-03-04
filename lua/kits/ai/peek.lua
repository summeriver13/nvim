--[[
Peek实时预览模块 - Vibe Coding 文档交互体验
功能：Markdown实时预览 + AI响应自动显示 + 极简交互界面
Vibe Coding 提升点：
  1. AI文档即时预览：AI生成的Markdown实时渲染，实现所见即所得的对话体验
  2. 非模态预览窗口：预览与编辑并存，无需切换模式即可查看AI生成的文档
  3. 极简交互设计：专注内容呈现，避免预览工具的复杂度干扰创作流程
]]

-- Vibe Coding 提升：配置实时Markdown预览，让AI对话拥有可视化文档输出
-- Peek.nvim 配置：Markdown实时预览，与AI响应无缝集成
local peek = require("peek")

-- Vibe Coding 提升：极简预览界面，让文档内容成为唯一焦点
-- 基础配置：极简预览界面
peek.setup({
  -- 预览窗口位置
  window = {
    position = "right",
    width = 50,
    height = "100%",
  },
  
  -- Markdown渲染选项
  markdown = {
    enabled = true,
    theme = "dark",
    math = true,
    diagrams = true,
  },
  
  -- 自动预览配置
  auto = {
    enabled = true,
    filetypes = { "markdown", "md", "txt" },
  },
  
  -- 快捷键配置
  keymaps = {
    close = "q",
    refresh = "r",
    toggle = "<leader>pp",
  },
})

-- 与Avante AI集成：AI生成的Markdown自动预览
local function setup_ai_integration()
  local avante = require("avante")
  
  -- 监听AI Markdown响应
  avante.on_response(function(response)
    if response.format == "markdown" then
      -- 在Peek预览窗口中显示
      peek.open(response.content)
    end
  end)
end

setup_ai_integration()

print("✅ Peek Markdown 预览配置完成")
