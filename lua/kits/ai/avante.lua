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
  provider = "openai", -- 使用 OpenAI 兼容模式接入 DeepSeek
  auto_suggestions_provider = "openai",
  
  providers = {
    openai = {
      endpoint = "https://api.deepseek.com/v1", -- DeepSeek API 终端
      model = "deepseek-chat", -- DeepSeek 聊天模型
      api_key_name = "DEEPSEEK_API_KEY", -- 环境变量名
      timeout = 30000,
      max_tokens = 4096,
      extra_request_body = {
        temperature = 0,
      },
    },
  },

  -- 交互行为
  behaviour = {
    auto_suggestions = false,
    auto_set_highlight_group = true,
    auto_set_keymaps = true,
    auto_apply_diff_after_generation = false,
    support_paste_from_clipboard = true,
    enable_token_counting = false, -- 暂时禁用本地 Token 计算以修复 Windows 下的编码器崩溃问题
  },
  
  -- 快捷键映射 (类 Cursor)
  mappings = {
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
    position = "right",
    wrap = true,
    width = 30,
    sidebar_header = {
      enabled = true,
      align = "center",
      rounded = true,
    },
    input = {
      prefix = "> ",
      height = 8,
    },
    edit = {
      border = "rounded",
      start_insert = true,
    },
    ask = {
      floating = false,
      start_insert = true,
      border = "rounded",
      focus_on_apply = "ours",
    },
  },
  
  -- 强制使用 snacks 或 native 以避免 dressing.nvim 的列表错误
  selector = {
    provider = "snacks",
  },
  input = {
    provider = "snacks",
  },
})

-- Vibe Coding 提升：一键打开AI侧边栏，让对话成为编码流程的自然部分，而非打断
-- 设置全局AI命令
vim.api.nvim_create_user_command("AIChat", function()
  require("avante.api").ask()
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