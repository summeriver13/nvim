--[[
AI交互核心模块 - Vibe Coding 核心体验
功能：Avante.nvim侧边栏聊天 + 多模式AI交互 + 一键代码分析
Vibe Coding 提升点：
  1. 类Cursor沉浸式侧边栏：无需切换窗口即可与AI对话，保持编码流程的连续性
  2. 多模式智能交互：代码补全/架构讨论/错误调试三种模式，让AI精准理解意图
  3. 一键代码分析：选中代码直接发送给AI，消除复制粘贴的认知负担
]]

local avante = require("avante")

-- Vibe Coding 提升：配置类Cursor的沉浸式侧边栏，让AI对话成为编码流程的自然延伸
-- 配置Avante.nvim作为AI交互核心
avante.setup({
  --- @alias Provider "openai" | "claude" | "azure" | "gemini" | "cohere" | "replicate" | "together" | "mistral" | "ollama"
  provider = "openai", -- 你可以根据需要修改为 gemini, claude 等
  auto_suggestions_provider = "openai",
  
  providers = {
    openai = {
      endpoint = "https://api.openai.com/v1",
      model = "gpt-4o", -- 推荐使用最新模型
      timeout = 30000, -- 超时时间
      max_tokens = 4096,
    },
  },

  -- 侧边栏配置：类似Cursor的聊天界面
  sidebar_header = {
    enabled = true,
    align = "center",
    rounded = true,
  },
  
  -- 侧边栏宽度
  width = 40,
  
  -- 交互行为
  behaviour = {
    auto_suggestions = false, -- 如果需要自动建议可以开启
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
  },
  
  -- 快捷键映射 (类 Cursor)
  mappings = {
    --- @class AvanteConflictMappings
    diff = {
      ours = "co",
      theirs = "ct",
      all_theirs = "ca",
      both = "cb",
      cursor = "cc",
      next = "]x",
      prev = "[x",
    },
    suggestion = {
      accept = "<M-l>",
      next = "<M-]>",
      prev = "<M-[>",
      dismiss = "<C-]>",
    },
    jump = {
      next = "]]",
      prev = "[[",
    },
    submit = {
      insert = "<cr>",
      normal = "<cr>",
    },
    sidebar = {
      apply_all = "A",
      apply_cursor = "a",
      switch_windows = "<Tab>",
      reverse_switch_windows = "<S-Tab>",
    },
  },

  -- UI 渲染配置
  hints = { enabled = true },
  windows = {
    --- @type "right" | "left" | "top" | "bottom"
    position = "right", -- 像 Trae/Cursor 一样放在右侧
    wrap = true,
    width = 30,
    sidebar_header = {
      enabled = true,
      align = "center",
      rounded = true,
    },
    input = {
      prefix = "> ",
      height = 8, -- 输入框高度
    },
    edit = {
      border = "rounded",
      start_insert = true, -- 打开时自动进入插入模式
    },
    ask = {
      floating = false, -- 使用侧边栏而不是浮窗
      start_insert = true,
      border = "rounded",
      focus_on_apply = "ours",
    },
  },
})

-- Vibe Coding 提升：一键打开AI侧边栏，让对话成为编码流程的自然部分，而非打断
-- 设置全局AI命令
vim.api.nvim_create_user_command("AIChat", function()
  avante.toggle_sidebar()
end, { desc = "打开/关闭AI聊天侧边栏" })

-- Vibe Coding 提升：选中代码一键分析，消除切换应用和复制粘贴的上下文中断
vim.api.nvim_create_user_command("AICode", function(opts)
  local range = opts.range
  local lines = vim.api.nvim_buf_get_lines(0, range[1] - 1, range[2], false)
  local code = table.concat(lines, "\n")
  
  avante.send_to_sidebar({
    mode = "completion",
    context = code,
    instruction = "请优化或重写这段代码:",
  })
end, { range = true, desc = "发送选中代码给AI分析" })

-- 环境感知：自动检测操作系统和项目类型
local function setup_environment()
  local is_windows = package.config:sub(1,1) == "\\"
  
  if is_windows then
    -- Windows特定配置
    vim.g.python3_host_prog = os.getenv("LOCALAPPDATA") .. "\\Programs\\Python\\Python311\\python.exe"
  else
    -- macOS/Linux配置
    vim.g.python3_host_prog = "/usr/bin/python3"
  end
  
  -- 自动检测项目类型并设置相应的AI模式
  if vim.fn.filereadable("pyproject.toml") == 1 then
    vim.g.ai_default_mode = "python"
  elseif vim.fn.filereadable("package.json") == 1 then
    vim.g.ai_default_mode = "javascript"
  else
    vim.g.ai_default_mode = "general"
  end
end

setup_environment()

-- Vibe Coding 提升：一键发送错误日志给AI，实现从发现问题到获得解决方案的无缝衔接
-- AI调试命令：发送错误日志或当前行给AI分析
vim.api.nvim_create_user_command("AIDebug", function(opts)
  local avante = require("avante")
  local range = opts.range
  local lines
  if range[1] > 0 and range[2] > 0 then
    -- 如果有选中范围，发送选中内容
    lines = vim.api.nvim_buf_get_lines(0, range[1] - 1, range[2], false)
  else
    -- 否则发送当前行
    lines = vim.api.nvim_buf_get_lines(0, vim.api.nvim_win_get_cursor(0)[1] - 1, vim.api.nvim_win_get_cursor(0)[1], false)
  end
  local text = table.concat(lines, "\n")
  
  avante.send_to_sidebar({
    mode = "debug",
    context = text,
    instruction = "请分析以下错误日志并提供解决方案:",
  })
end, { range = true, desc = "发送错误日志或当前行给AI调试" })

print("✅ Avante AI 配置加载完成 - 沉浸式AI编程体验已启用")