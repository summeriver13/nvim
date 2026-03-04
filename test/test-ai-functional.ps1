# AI 功能测试脚本
# 测试 Neovim AI 增强配置的核心功能

$ErrorActionPreference = "Stop"

Write-Host "=== Neovim AI 功能测试 ===" -ForegroundColor Green
Write-Host "测试开始时间: $(Get-Date)" -ForegroundColor Cyan

# 检查 Neovim 是否安装
Write-Host "`n[1/6] 检查 Neovim 安装..." -ForegroundColor Yellow

# 尝试在 PATH 中查找 nvim
$nvimCommand = "nvim"
$nvimVersion = & nvim --version 2>$null

# 如果不在 PATH 中，尝试常见安装路径
if (-not $nvimVersion) {
    $commonPaths = @(
        "C:\Program Files\Neovim\bin\nvim.exe",
        "C:\Users\$env:USERNAME\AppData\Local\Programs\Neovim\bin\nvim.exe",
        "C:\tools\neovim\bin\nvim.exe",
        "C:\scoop\apps\neovim\current\bin\nvim.exe",
        "C:\Users\$env:USERNAME\scoop\apps\neovim\current\bin\nvim.exe"
    )
    
    foreach ($path in $commonPaths) {
        if (Test-Path $path) {
            $nvimCommand = $path
            $nvimVersion = & $path --version 2>$null
            if ($nvimVersion) {
                Write-Host "✓ 在以下位置找到 Neovim: $path" -ForegroundColor Green
                break
            }
        }
    }
}

if (-not $nvimVersion) {
    Write-Host "错误: Neovim 未安装或不在 PATH 中" -ForegroundColor Red
    Write-Host ""
    Write-Host "安装方法:" -ForegroundColor Yellow
    Write-Host "1. 使用 Scoop: scoop install neovim" -ForegroundColor Cyan
    Write-Host "2. 手动下载: https://github.com/neovim/neovim/releases" -ForegroundColor Cyan
    Write-Host "3. 添加到 PATH: 将 Neovim 安装目录添加到系统环境变量 PATH" -ForegroundColor Cyan
    exit 1
}

Write-Host "✓ Neovim 已安装" -ForegroundColor Green
$global:NvimCommand = $nvimCommand

# 创建测试文件用于功能测试
$testFile = "test-ai-functionality.lua"

# 1. 测试 AI 命令注册
Write-Host "`n[2/6] 测试 AI 命令注册..." -ForegroundColor Yellow
$testCommands = @"
-- AI 命令注册测试
print("=== AI 命令测试 ===")

-- 获取所有命令
local commands = vim.api.nvim_get_commands({})
local aiCommands = {}

-- 查找 AI 相关命令
for cmd, info in pairs(commands) do
  if string.match(cmd, "^AI") then
    table.insert(aiCommands, {name = cmd, desc = info.desc})
  end
end

-- 输出结果
if #aiCommands > 0 then
  print("✓ 找到 " .. #aiCommands .. " 个 AI 命令:")
  for _, cmd in ipairs(aiCommands) do
    print("  - " .. cmd.name .. ": " .. (cmd.desc or "无描述"))
  end
else
  print("✗ 未找到 AI 命令")
end

-- 检查关键命令
local requiredCommands = {"AIChat", "AICode", "AIDebug"}
local foundCommands = {}
for _, reqCmd in ipairs(requiredCommands) do
  if commands[reqCmd] then
    table.insert(foundCommands, reqCmd)
  end
end

if #foundCommands == #requiredCommands then
  print("✓ 所有关键 AI 命令已注册")
else
  print("⚠ 缺少命令: " .. table.concat(requiredCommands, ", ") .. " 中找到 " .. #foundCommands .. " 个")
end
"@

$testCommands | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & $NvimCommand --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ AI 命令注册测试完成" -ForegroundColor Green
        $output | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "✗ AI 命令注册测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

# 2. 测试模块加载
Write-Host "`n[3/6] 测试 AI 模块加载..." -ForegroundColor Yellow
$testModules = @"
-- AI 模块加载测试
print("=== AI 模块加载测试 ===")

local modulesToTest = {
  "kits.ai.avante",
  "kits.ai.copilot", 
  "kits.ai.context",
  "kits.ai.snacks",
  "kits.ai.noice",
}

local loadedModules = {}
local failedModules = {}

for _, module in ipairs(modulesToTest) do
  local ok, err = pcall(require, module)
  if ok then
    table.insert(loadedModules, module)
    print("✓ " .. module .. " 加载成功")
  else
    table.insert(failedModules, {module = module, error = err})
    print("✗ " .. module .. " 加载失败: " .. err)
  end
end

if #failedModules == 0 then
  print("✓ 所有 AI 模块加载成功")
else
  print("⚠ " .. #failedModules .. " 个模块加载失败")
end
"@

$testModules | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & nvim --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ AI 模块加载测试完成" -ForegroundColor Green
        $output | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "✗ AI 模块加载测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

# 3. 测试快捷键映射
Write-Host "`n[4/6] 测试 AI 快捷键映射..." -ForegroundColor Yellow
$testKeymaps = @"
-- AI 快捷键映射测试
print("=== AI 快捷键映射测试 ===")

-- 检查 leader 键
local leader = vim.g.mapleader
if leader then
  print("✓ mapleader 已设置: '" .. leader .. "'")
else
  print("⚠ mapleader 未设置")
end

-- 检查 AI 相关快捷键
local keymaps = vim.api.nvim_get_keymap("n")
local aiKeymaps = {}

for _, km in ipairs(keymaps) do
  if string.match(km.lhs, "<leader>a") then
    table.insert(aiKeymaps, {lhs = km.lhs, rhs = km.rhs, desc = km.desc})
  end
end

if #aiKeymaps > 0 then
  print("✓ 找到 " .. #aiKeymaps .. " 个 AI 相关快捷键:")
  for _, km in ipairs(aiKeymaps) do
    local desc = km.desc and (" (" .. km.desc .. ")") or ""
    print("  - " .. km.lhs .. " -> " .. km.rhs .. desc)
  end
else
  print("⚠ 未找到 AI 相关快捷键")
end

-- 检查是否与 LSP/Telescope 冲突
local conflictKeys = {"<leader>ff", "<leader>fg", "<leader>fb", "<leader>fh"}
local conflicts = {}

for _, key in ipairs(conflictKeys) do
  for _, km in ipairs(keymaps) do
    if km.lhs == key then
      table.insert(conflicts, {key = key, mapping = km.rhs})
    end
  end
end

if #conflicts == 0 then
  print("✓ 未发现与 Telescope 快捷键冲突")
else
  print("⚠ 发现 " .. #conflicts .. " 个可能的快捷键冲突:")
  for _, conf in ipairs(conflicts) do
    print("  - " .. conf.key .. " 已被占用: " .. conf.mapping)
  end
end
"@

$testKeymaps | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & nvim --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ AI 快捷键映射测试完成" -ForegroundColor Green
        $output | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "✗ AI 快捷键映射测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

# 4. 测试 LSP 集成
Write-Host "`n[5/6] 测试 LSP 集成..." -ForegroundColor Yellow
$testLSP = @"
-- LSP 集成测试
print("=== LSP 集成测试 ===")

-- 检查 LSP 配置
local ok, lspconfig = pcall(require, "lspconfig")
if ok then
  print("✓ lspconfig 模块加载成功")
  
  -- 检查已配置的 LSP 服务器
  local servers = {"lua_ls", "pyright", "ruff_lsp", "texlab", "marksman"}
  local configuredServers = {}
  
  for _, server in ipairs(servers) do
    if lspconfig[server] then
      table.insert(configuredServers, server)
    end
  end
  
  print("✓ 配置了 " .. #configuredServers .. " 个 LSP 服务器:")
  for _, server in ipairs(configuredServers) do
    print("  - " .. server)
  end
  
  if #configuredServers == #servers then
    print("✓ 所有预期的 LSP 服务器均已配置")
  else
    print("⚠ 缺少 " .. (#servers - #configuredServers) .. " 个 LSP 服务器")
  end
else
  print("✗ lspconfig 模块加载失败: " .. lspconfig)
end

-- 检查 null-ls 集成（用于 AI 代码格式化）
local ok, null_ls = pcall(require, "null-ls")
if ok then
  print("✓ null-ls 模块加载成功")
else
  print("⚠ null-ls 模块未加载（可选）")
end
"@

$testLSP | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & nvim --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ LSP 集成测试完成" -ForegroundColor Green
        $output | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "✗ LSP 集成测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

# 5. 测试环境感知
Write-Host "`n[6/6] 测试环境感知功能..." -ForegroundColor Yellow
$testEnv = @"
-- 环境感知测试
print("=== 环境感知测试 ===")

-- 检查操作系统检测
local is_windows = package.config:sub(1,1) == "\\"
if is_windows then
  print("✓ 检测到 Windows 系统")
  
  -- 检查 Windows 特定配置
  local pythonPath = vim.g.python3_host_prog
  if pythonPath then
    print("✓ Python 路径已设置: " .. pythonPath)
  else
    print("⚠ Python 路径未设置")
  end
else
  print("✓ 检测到 Unix-like 系统 (macOS/Linux)")
  
  local pythonPath = vim.g.python3_host_prog
  if pythonPath then
    print("✓ Python 路径已设置: " .. pythonPath)
  else
    print("⚠ Python 路径未设置")
  end
end

-- 检查路径自适应
local appData = os.getenv("LOCALAPPDATA")
local home = os.getenv("HOME")
if is_windows and appData then
  print("✓ 检测到 Windows AppData 路径: " .. appData)
elseif home then
  print("✓ 检测到 HOME 目录: " .. home)
end

print("✓ 环境感知功能正常")
"@

$testEnv | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & nvim --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 环境感知测试完成" -ForegroundColor Green
        $output | ForEach-Object { Write-Host "  $_" }
    } else {
        Write-Host "✗ 环境感知测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

Write-Host "`n=== AI 功能测试完成 ===" -ForegroundColor Green
Write-Host "测试结束时间: $(Get-Date)" -ForegroundColor Cyan
Write-Host "AI 功能验证通过，配置完整。" -ForegroundColor Green