-- # lua/kits/ui/focus.lua

--- @class KitsFocus
--- Windows 环境下焦点管理模块，解决 AI 对话输入问题
local M = {}

--- 安全切换到可编辑缓冲区
--- 解决用户被困在文件树或终端等非编辑区域的问题
function M.safe_focus_editable()
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_type = vim.api.nvim_buf_get_option(current_buf, "buftype")
  local filetype = vim.api.nvim_buf_get_option(current_buf, "filetype")
  
  -- 检查当前是否在不可编辑的缓冲区
  local non_editable_buffers = {
    "nofile", "nowrite", "acwrite", "quickfix", "terminal", "prompt"
  }
  
  local is_non_editable = vim.tbl_contains(non_editable_buffers, buf_type) 
                      or filetype == "NvimTree"
                      or filetype == "toggleterm"
                      or filetype == "avante"
  
  if is_non_editable then
    -- 尝试找到最近的编辑缓冲区
    local editable_wins = {}
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local win_buf = vim.api.nvim_win_get_buf(win)
      local win_buf_type = vim.api.nvim_buf_get_option(win_buf, "buftype")
      local win_filetype = vim.api.nvim_buf_get_option(win_buf, "filetype")
      
      if win_buf_type == "" and win_filetype ~= "NvimTree" and win_filetype ~= "toggleterm" then
        table.insert(editable_wins, win)
      end
    end
    
    if #editable_wins > 0 then
      vim.api.nvim_set_current_win(editable_wins[1])
      vim.notify("🔍 已切换到可编辑区域", vim.log.levels.INFO)
    else
      -- 如果没有可编辑窗口，创建一个新的
      vim.cmd("enew")
      vim.notify("📝 已创建新的编辑缓冲区", vim.log.levels.INFO)
    end
  end
end

--- 安全切换到 AI 输入框
--- 专门解决 Avante 输入框焦点问题
function M.focus_ai_input()
  local avante_ok, avante_api = pcall(require, "avante.api")
  if not avante_ok then
    vim.notify("❌ Avante API 不可用", vim.log.levels.ERROR)
    return false
  end
  
  -- 首先确保 Avante 侧边栏是打开的
  if not avante_api.is_open() then
    avante_api.ask()
    -- 给一点时间让窗口创建
    vim.defer_fn(function()
      M._focus_ai_input_internal()
    end, 100)
  else
    M._focus_ai_input_internal()
  end
  
  return true
end

--- 内部焦点切换实现
function M._focus_ai_input_internal()
  -- 查找 Avante 输入窗口
  local ai_input_win = nil
  
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local filetype = vim.api.nvim_buf_get_option(buf, "filetype")
    local buf_name = vim.api.nvim_buf_get_name(buf)
    
    -- 通过多种方式识别 AI 输入窗口
    if filetype == "avante" or buf_name:find("avante") or buf_name:find("AI.*input") then
      ai_input_win = win
      break
    end
  end
  
  if ai_input_win then
    -- 切换到 AI 输入窗口并进入插入模式
    vim.api.nvim_set_current_win(ai_input_win)
    vim.cmd("startinsert")
    vim.notify("💬 已聚焦到 AI 输入框", vim.log.levels.INFO)
  else
    vim.notify("❌ 未找到 AI 输入框", vim.log.levels.WARN)
  end
end

--- 检查并修复窗口焦点状态
function M.check_and_fix_focus()
  local current_win = vim.api.nvim_get_current_win()
  local current_buf = vim.api.nvim_win_get_buf(current_win)
  
  local mode = vim.api.nvim_get_mode().mode
  local modifiable = vim.api.nvim_buf_get_option(current_buf, "modifiable")
  
  -- 如果当前不可编辑且不在插入模式，尝试修复
  if not modifiable and mode ~= "i" and mode ~= "ic" then
    M.safe_focus_editable()
  end
end

--- 设置全局焦点管理快捷键
function M.setup()
  -- 焦点修复快捷键
  vim.keymap.set("n", "<leader>fe", M.safe_focus_editable, 
    { desc = "切换到可编辑区域" })
  
  vim.keymap.set("n", "<leader>fa", M.focus_ai_input, 
    { desc = "聚焦到 AI 输入框" })
  
  -- 自动焦点检查（可选）
  vim.api.nvim_create_autocmd("WinEnter", {
    callback = M.check_and_fix_focus,
    desc = "自动检查窗口焦点状态"
  })
  
  vim.notify("🔧 焦点管理系统已启用", vim.log.levels.INFO)
end

return M