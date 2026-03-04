-- # lua/kits/utils/env.lua

--- @class KitsEnv
local M = {}

--- 判断当前是否为 Windows 系统
--- @return boolean
function M.is_windows()
  local os = vim.uv.os_uname().sysname
  return os == "Windows_NT" or os:find("Windows") ~= nil
end

--- 强制将字符串转换为 UTF-8 编码
--- 解决 Windows 下外部命令输出（通常是 GBK）导致的 JSON 解析错误 (invalid unicode code point)
--- 同时清理非法 Unicode 字符，防止干扰 AI 的 API 请求
--- @param str string
--- @return string
function M.to_utf8(str)
  if not str or str == "" then return "" end
  
  -- 如果不是 Windows，或者字符串已经是有效的 UTF-8，则进行清理后返回
  local clean_str = str
  if M.is_windows() and vim.fn.isutf8(str) == 0 then
    -- Windows 下使用 iconv 进行编码转换 (GBK -> UTF-8)
    local ok, result = pcall(vim.fn.iconv, str, "cp936", "utf-8")
    if ok then clean_str = result end
  end

  -- 核心：过滤掉非法的 Unicode 字符 (防止 API 报错 invalid unicode code point)
  -- 匹配并替换掉无法解析的字节序列
  clean_str = clean_str:gsub("[\128-\255]", function(c)
    -- 如果该字符不在合法的 UTF-8 范围内，替换为占位符或删除
    return "" 
  end)

  return clean_str
end

--- 跨平台命令路由
--- 解决 AI 尝试执行 bash("pwd && ls -la") 在 Windows 下失败的问题
--- @param original_cmd string
--- @return string
function M.route_command(original_cmd)
  if not M.is_windows() then return original_cmd end

  -- 常见 Bash 指令到 PowerShell 的转换映射
  local map = {
    ["ls %-la"] = "dir",
    ["ls"] = "dir /b",
    ["pwd"] = "cd",
    ["cat"] = "type",
    ["rm %-rf"] = "Remove-Item -Recurse -Force",
  }

  local routed = original_cmd
  for bash, pwsh in pairs(map) do
    routed = routed:gsub(bash, pwsh)
  end

  -- 统一路径分隔符：将 / 转换为 Windows 风格的 \
  routed = routed:gsub("/", "\\")
  
  return routed
end

--- 获取默认 Shell
--- @return string
function M.get_shell()
  if M.is_windows() then
    return "pwsh.exe" -- 优先使用 PowerShell Core
  end
  return "zsh"
end

return M
