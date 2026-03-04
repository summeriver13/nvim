--[[
Noice现代化通知模块 - Vibe Coding 反馈体验
功能：AI响应通知系统 + LSP进度可视化 + 统一消息路由
Vibe Coding 提升点：
  1. 非侵入式通知：AI响应以优雅通知形式显示，不打断编码流程
  2. LSP进度可视化：代码分析和AI处理进度实时显示，消除等待焦虑
  3. 智能消息路由：AI消息优先显示，系统消息降级处理，确保重要信息不被淹没
]]

-- Vibe Coding 提升：配置现代化通知系统，让AI交互拥有优雅的视觉反馈
local noice = require("noice")

-- Vibe Coding 提升：统一的消息路由系统，让AI响应获得优先级显示
-- 配置Noice.nvim提供现代化通知系统
noice.setup({
  -- LSP进度提示：极简风格
  lsp = {
    progress = {
      enabled = true,
      format = "lsp_progress",
      format_done = "lsp_progress_done",
      throttle = 1000,
      view = "mini",
    },
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
    },
    signature = {
      enabled = false, -- 使用snacks.nvim代替
    },
  },
  
  -- 消息配置：AI响应和系统通知
  messages = {
    enabled = true,
    view = "notify",
    view_error = "notify",
    view_warn = "notify",
  },
  
  -- 通知系统：与AI交互完美集成
  notify = {
    enabled = true,
    view = "mini",
    timeout = 3000,
    fps = 60,
  },
  
  -- 命令行集成：AI命令提示
  cmdline = {
    enabled = true,
    view = "cmdline_popup",
    format = {
      cmdline = { pattern = "^:", icon = " " },
      search = { icon = " " },
    },
  },
  
  -- 弹出式菜单：AI建议显示
  popupmenu = {
    enabled = true,
    backend = "nui",
  },
  
  -- 智能路由：AI消息优先显示
  routes = {
    {
      filter = {
        event = "msg_show",
        kind = "",
        find = "AI响应",
      },
      view = "notify",
    },
    {
      filter = { event = "msg_show", kind = "search_count" },
      opts = { skip = true },
    },
  },
  
  -- 视觉样式：与Avante主题一致
  views = {
    cmdline_popup = {
      position = {
        row = 5,
        col = "50%",
      },
      size = {
        width = 60,
        height = "auto",
      },
      border = {
        style = "rounded",
        padding = { 0, 1 },
      },
    },
    notify = {
      timeout = 3000,
      replace = true,
      merge = true,
    },
  },
})

-- AI消息高亮配置
vim.api.nvim_set_hl(0, "NoiceNotifyAIMessage", {
  fg = "#50fa7b",
  bg = "#1e1e2e",
})

print("✅ Noice UI 配置完成 - 现代化通知系统已启用")