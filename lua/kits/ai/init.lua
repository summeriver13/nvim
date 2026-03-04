--[[
AI核心初始化模块 - Vibe Coding 统一入口
功能：模块化AI组件加载 + 依赖顺序管理 + 统一初始化流程
Vibe Coding 提升点：
  1. 模块化架构：各AI功能独立配置，可按需加载，避免配置臃肿
  2. 智能加载顺序：环境感知最先加载，确保其他模块获得正确上下文
  3. 统一初始化体验：所有AI功能一次性初始化，提供一致的使用体验
]]

-- Vibe Coding 提升：统一的模块化入口，让复杂的AI配置变得简单可控
-- AI核心模块初始化
-- 此文件整合所有AI相关配置，提供统一的AI编程体验

print("🧠 正在加载AI核心模块...")

-- 加载环境感知模块（最先加载，为其他模块提供上下文）
require("kits.ai.context")

-- 加载AI交互核心模块
require("kits.ai.avante")

-- 加载Copilot流式补全模块
require("kits.ai.copilot")

-- 加载UI反馈模块
require("kits.ai.noice")
require("kits.ai.snacks")

-- 加载Markdown渲染模块
require("kits.ai.render-markdown")
require("kits.ai.peek")

-- 初始化完成提示
vim.defer_fn(function()
  print("✅ AI核心模块加载完成")
  print("   📝 可用命令: AIChat, AICode, AIDebug")
  print("   🔑 快捷键: <leader>ai, <leader>ac, <leader>ad")
  print("   🎨 UI系统: Noice, Snacks, Markdown预览")
end, 1000)

return {
  context = require("kits.ai.context"),
  avante = require("kits.ai.avante"),
  copilot = require("kits.ai.copilot"),
}