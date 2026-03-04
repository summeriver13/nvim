--[[
AI插件声明模块 - Vibe Coding 基础设施
功能：AI插件依赖声明 + 模块化配置加载 + 版本管理
Vibe Coding 提升点：
  1. 模块化插件管理：每个AI功能独立声明，便于维护和按需启用
  2. 配置与声明分离：插件声明在此，具体配置在kits/ai/，提高可维护性
  3. 清晰的依赖关系：明确AI插件间的依赖，确保正确的加载顺序
]]

-- Vibe Coding 提升：清晰的插件架构，让复杂的AI生态系统易于理解和管理
return {
  -- Vibe Coding 提升：Avante作为核心AI交互层，提供类Cursor的沉浸式侧边栏体验
  -- Avante.nvim - 核心AI交互侧边栏
  {
    "yetone/avante.nvim",
    branch = "main",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    config = function()
      require("kits.ai.avante")
    end,
  },
  
  -- Vibe Coding 提升：Copilot提供流式代码补全，与Avante深度协作形成双AI模式
  -- GitHub Copilot - 流式代码补全
  {
    "github/copilot.vim",
    config = function()
      require("kits.ai.copilot")
    end,
  },
  
  -- Vibe Coding 提升：Noice提供现代化通知系统，让AI交互拥有优雅的视觉反馈
  -- Noice.nvim - 现代化UI通知系统
  {
    "folke/noice.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require("kits.ai.noice")
    end,
  },
  
  -- Vibe Coding 提升：Snacks提供类Cursor的平滑浮窗，让AI交互视觉统一化
  -- Snacks.nvim - 极简浮窗UI
  {
    "tamton-aquib/snacks.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require("kits.ai.snacks")
    end,
  },
  
  -- Vibe Coding 提升：Peek提供实时Markdown预览，让AI对话拥有可视化文档输出
  -- Markdown渲染增强
  {
    "toppair/peek.nvim",
    build = "deno task --quiet build:fast",
    config = function()
      require("kits.ai.peek")
    end,
  },
  
  -- Vibe Coding 提升：Markdown预览提供学术级渲染，让AI生成的文档拥有出版级视觉效果
  -- Render Markdown - AI返回的Markdown文档完美渲染
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end,
    config = function()
      require("kits.ai.render-markdown")
    end,
  },
}