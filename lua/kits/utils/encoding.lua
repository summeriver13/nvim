-- # lua/kits/utils/encoding.lua

--- @class KitsEncoding
local M = {}

local env = require("kits.utils.env")

--- 深度清洗字符串，确保安全的 UTF-8 输出
--- 解决 Windows 下 GBK 编码导致的 invalid unicode code point 错误
--- @param input string
--- @return string
function M.deep_clean_utf8(input)
  if not input or input == "" then return "" end
  
  local cleaned = input
  
  -- 第一步：Windows 环境下的编码转换
  if env.is_windows() and vim.fn.isutf8(cleaned) == 0 then
    local ok, converted = pcall(vim.fn.iconv, cleaned, "cp936", "utf-8")
    if ok and converted then cleaned = converted end
  end
  
  -- 第二步：过滤非法 Unicode 字符（防止 API 崩溃）
  cleaned = cleaned:gsub("[\x80-\xFF]", function(char)
    -- 只保留有效的 UTF-8 连续字节序列
    local byte = char:byte()
    if byte >= 0xC2 and byte <= 0xF4 then
      return char -- 有效的 UTF-8 起始字节
    end
    return "" -- 无效字节序列
  end)
  
  -- 第三步：移除控制字符（除了换行和制表符）
  cleaned = cleaned:gsub("[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]", "")
  
  -- 第四步：确保字符串以有效 UTF-8 结束
  if cleaned:sub(-1):byte() >= 0x80 then
    -- 如果以多字节字符的中间字节结束，移除不完整的字符
    cleaned = cleaned:gsub("[\x80-\xBF]+$", "")
  end
  
  return cleaned
end

--- 安全执行外部命令并返回清洗后的 UTF-8 输出
--- 专门用于 AI 相关的文件扫描和系统信息获取
--- @param cmd string
--- @return string, integer
function M.safe_execute(cmd)
  local routed_cmd = env.route_command(cmd)
  local output = vim.fn.system(routed_cmd)
  local exit_code = vim.v.shell_error
  
  -- 深度清洗输出，确保 AI API 安全
  local cleaned_output = M.deep_clean_utf8(output)
  
  return cleaned_output, exit_code
end

--- 批量清洗字符串数组（用于文件列表等）
--- @param strings table
--- @return table
function M.batch_clean(strings)
  local cleaned = {}
  for _, str in ipairs(strings) do
    table.insert(cleaned, M.deep_clean_utf8(str))
  end
  return cleaned
end

--- 检查字符串是否为安全的 UTF-8（用于调试）
--- @param str string
--- @return boolean
function M.is_safe_utf8(str)
  if not str or str == "" then return true end
  
  -- 检查是否包含非法 Unicode 码点
  local has_invalid = str:find("[\x80-\xFF]") and vim.fn.isutf8(str) == 0
  
  -- 检查控制字符（除了允许的）
  local has_dangerous_control = str:find("[\x00-\x08\x0B-\x0C\x0E-\x1F\x7F]")
  
  return not has_invalid and not has_dangerous_control
end

return M