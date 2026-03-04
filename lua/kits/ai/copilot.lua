--[[
Copilot流式补全模块 - Vibe Coding 核心体验
功能：GitHub Copilot即时补全 + 与Avante深度集成 + 智能模式切换
Vibe Coding 提升点：
  1. 零延迟流式补全：AI建议在输入时即时出现，保持编码节奏不被中断
  2. 双模式智能切换：Copilot处理常规补全，Avante负责深度架构分析，各司其职
  3. 补全记忆集成：Copilot接受的建议自动记录到AI上下文，形成个性化学习循环
]]

-- Vibe Coding 提升：配置极简流式补全，让AI建议成为编码的自然延伸而非干扰
-- GitHub Copilot 配置：提供流畅的流式代码补全
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_filetypes = {
  ["*"] = true,
  markdown = true,
  python = true,
  lua = true,
  javascript = true,
  typescript = true,
}

-- 智能补全建议配置
vim.g.copilot_suggestion_auto_trigger = true
vim.g.copilot_suggestion_delay = 100
vim.g.copilot_suggestion_max_lines = 50

-- 视觉样式配置：极简提示
vim.g.copilot_suggestion_highlight = "Pmenu"
vim.g.copilot_suggestion_border = "rounded"

-- Vibe Coding 提升：Copilot与Avante深度集成，形成互补的AI编程体验
-- 与Avante的集成：Copilot作为快速补全，Avante作为深度分析
local function setup_copilot_integration()
  -- 当Copilot建议被接受时，自动记录到AI上下文
  vim.api.nvim_create_autocmd("User", {
    pattern = "CopilotSuggestionAccepted",
    callback = function()
      local avante = require("avante")
      local line = vim.api.nvim_get_current_line()
      
      -- 记录补全模式到AI记忆
      avante.record_context({
        type = "copilot_completion",
        content = line,
        timestamp = os.time(),
      })
    end,
  })
  
  -- 双模式切换：Copilot用于代码，Avante用于架构
  vim.keymap.set("i", "<C-G><C-A>", function()
    local avante = require("avante")
    avante.toggle_sidebar()
  end, { desc = "切换AI模式: Copilot补全 ↔ Avante架构" })
end

setup_copilot_integration()

print("✅ Copilot 配置完成 - 流式AI补全已就绪")