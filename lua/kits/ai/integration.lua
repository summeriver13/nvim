-- # lua/kits/ai/integration.lua

--- @class KitsAIIntegration
--- Windows 环境下 AI 系统深度集成模块
local M = {}

local env = require("kits.utils.env")
local encoding = require("kits.utils.encoding")
local ai_core = require("kits.ai.core")

--- 安全执行 AI 相关的系统命令
--- 自动处理 Windows 兼容性和编码问题
--- @param command string
--- @return string, integer
function M.safe_system_command(command)
  -- 路由命令到合适的平台
  local routed_cmd = env.route_command(command)
  
  -- 执行并深度清洗输出
  local output, exit_code = encoding.safe_execute(routed_cmd)
  
  -- 记录调试信息（仅在开发模式）
  if vim.g.debug_ai_integration then
    vim.notify(string.format("🔧 AI 命令执行:\n原始: %s\n路由: %s\n输出: %s", 
      command, routed_cmd, output:sub(1, 100)), vim.log.levels.DEBUG)
  end
  
  return output, exit_code
end

--- 获取安全的文件系统信息（用于 AI 上下文）
--- @param path? string
--- @return table
function M.get_safe_filesystem_info(path)
  local target_path = path or vim.fn.getcwd()
  local info = {}
  
  if env.is_windows() then
    -- Windows 专用文件扫描
    local output, exit_code = M.safe_system_command(
      string.format("Get-ChildItem -Path '%s' -Recurse -Depth 2 -File | Select-Object Name, Length, LastWriteTime", 
      target_path:gsub("'", "''"))
    )
    
    if exit_code == 0 then
      info.file_list = {}
      for line in output:gmatch("[^\r\n]+") do
        if not line:find("^Directory:") then
          table.insert(info.file_list, encoding.deep_clean_utf8(line))
        end
      end
    end
    
    -- 获取目录信息
    local dir_output = M.safe_system_command(
      string.format("Get-Item '%s' | Select-Object Name, FullName, LastWriteTime", 
      target_path:gsub("'", "''"))
    )
    info.directory_info = encoding.deep_clean_utf8(dir_output)
    
  else
    -- Unix 系统使用传统命令
    local output, exit_code = M.safe_system_command(
      string.format("find '%s' -type f -maxdepth 2 -exec ls -la {} \\;", 
      target_path:gsub("'", "'\\\\''"))
    )
    
    if exit_code == 0 then
      info.file_list = encoding.batch_clean(vim.split(output, "\n"))
    end
    
    info.directory_info = M.safe_system_command("pwd && date")
  end
  
  return info
end

--- 统一 AI 响应处理（确保编码安全）
--- @param data table
function M.safe_ai_response(data)
  -- 深度清洗所有字符串字段，防止 invalid unicode code point
  local cleaned_data = {}
  
  for key, value in pairs(data) do
    if type(value) == "string" then
      cleaned_data[key] = encoding.deep_clean_utf8(value)
    elseif type(value) == "table" then
      cleaned_data[key] = {}
      for k, v in pairs(value) do
        if type(v) == "string" then
          cleaned_data[key][k] = encoding.deep_clean_utf8(v)
        else
          cleaned_data[key][k] = v
        end
      end
    else
      cleaned_data[key] = value
    end
  end
  
  -- 触发核心回调
  ai_core.on_response(cleaned_data)
end

--- 注册到 AI 核心系统
function M.setup()
  -- 注册为默认的 AI 响应处理器
  ai_core.register_handler("integration", function(data)
    -- 这里可以添加统一的响应后处理逻辑
    if vim.g.debug_ai_integration then
      vim.notify("✅ AI 响应已安全处理", vim.log.levels.INFO)
    end
  end)
  
  -- 设置全局调试标志
  vim.g.debug_ai_integration = false
  
  vim.notify("🔧 AI 集成系统已就绪（Windows 优化版）", vim.log.levels.INFO)
end

return M