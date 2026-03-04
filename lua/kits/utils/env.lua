-- # lua/kits/utils/env.lua

--- @class KitsEnv
local M = {}

--- 判断当前是否为 Windows 系统
--- 使用 vim.uv (或 vim.loop) 的 os_uname 接口
--- @return boolean
function M.is_windows()
  local os = vim.uv.os_uname().sysname
  return os == "Windows_NT" or os:find("Windows") ~= nil
end

--- 统一路径分隔符
--- 在 Windows 下将 / 转换为 \，在 Unix 下保持 /
--- 注意：Neovim 内部 API 大多支持 /，但调用外部 cmd.exe 或某些 Windows 原生程序时必须使用 \
--- @param path string
--- @return string
function M.normalize_path(path)
  if M.is_windows() then
    return path:gsub("/", "\\")
  end
  return path
end

--- 强制将字符串转换为 UTF-8 编码
--- 解决 Windows 下外部命令输出（通常是 GBK）导致的 JSON 解析错误 (invalid unicode code point)
--- @param str string
--- @return string
function M.to_utf8(str)
  if not str or str == "" then return "" end
  
  -- 如果不是 Windows，或者字符串已经是有效的 UTF-8，则直接返回
  if not M.is_windows() or vim.fn.isutf8(str) == 1 then
    return str
  end

  -- Windows 下使用 iconv 进行编码转换 (GBK -> UTF-8)
  -- Neovim 内置了 iconv 支持
  local ok, result = pcall(vim.fn.iconv, str, "cp936", "utf-8")
  if ok then
    return result
  end
  return str
end

--- 跨平台命令路由
--- 根据系统返回对应的 shell 指令
--- @param cmd_type "ls" | "pwd" | "cat"
--- @return string
function M.get_command(cmd_type)
  local is_win = M.is_windows()
  
  local routes = {
    ls = is_win and "dir /b" or "ls -la",
    pwd = is_win and "cd" or "pwd",
    cat = is_win and "type" or "cat",
  }
  
  return routes[cmd_type] or ""
end

--- 安全执行外部命令并返回 UTF-8 文本
--- @param cmd string
--- @return string
function M.safe_execute(cmd)
  local handle = io.popen(cmd)
  if not handle then return "" end
  local result = handle:read("*a")
  handle:close()
  return M.to_utf8(result)
end

return M
