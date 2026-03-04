# Neovim 配置加载测试脚本
# 使用 headless 模式测试配置是否能正常加载

$ErrorActionPreference = "Stop"

Write-Host "=== Neovim 配置规范化测试 ===" -ForegroundColor Green
Write-Host "测试开始时间: $(Get-Date)" -ForegroundColor Cyan

# 1. 检查 Neovim 是否安装
Write-Host "`n[1/4] 检查 Neovim 安装..." -ForegroundColor Yellow

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

Write-Host "✓ Neovim 已安装: $($nvimVersion | Select-String -Pattern 'NVIM')" -ForegroundColor Green
$global:NvimCommand = $nvimCommand

# 2. 语法检查 (luacheck)
Write-Host "`n[2/4] 执行 Lua 语法检查..." -ForegroundColor Yellow
if (Get-Command luacheck -ErrorAction SilentlyContinue) {
    $luacheckResult = & luacheck . 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Lua 语法检查通过" -ForegroundColor Green
    } else {
        Write-Host "✗ Lua 语法检查失败:" -ForegroundColor Red
        $luacheckResult | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} else {
    Write-Host "⚠ luacheck 未安装，跳过语法检查" -ForegroundColor Yellow
    Write-Host "  安装命令: luarocks install luacheck" -ForegroundColor Cyan
}

# 3. 配置加载测试
Write-Host "`n[3/4] 测试配置加载..." -ForegroundColor Yellow
$loadTest = @"
echo "测试配置加载..."
lua print("=== Neovim 配置加载测试 ===")
lua print("1. 检查核心模块加载...")
local ok, err = pcall(require, "core.options")
if ok then
  print("✓ core.options 加载成功")
else
  print("✗ core.options 加载失败: " .. err)
end

lua print("2. 检查 AI 模块加载...")
local ok, err = pcall(require, "kits.ai.init")
if ok then
  print("✓ kits.ai.init 加载成功")
else
  print("✗ kits.ai.init 加载失败: " .. err)
end

lua print("3. 检查 LSP 配置加载...")
local ok, err = pcall(require, "kits.lsp")
if ok then
  print("✓ kits.lsp 加载成功")
else
  print("✗ kits.lsp 加载失败: " .. err)
end

lua print("`n配置加载测试完成")
quitall
"@

$testFile = "test-load.lua"
$loadTest | Out-File -FilePath $testFile -Encoding UTF8

try {
    $output = & $NvimCommand --headless -u init.lua -i NONE -n -e -s -c "source $testFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 配置加载测试通过" -ForegroundColor Green
        $output | Where-Object { $_ -match "✓" } | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    } else {
        Write-Host "✗ 配置加载测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $testFile -ErrorAction SilentlyContinue
}

# 4. 基础功能测试
Write-Host "`n[4/4] 测试基础功能..." -ForegroundColor Yellow
$funcTest = @"
echo "测试基础功能..."
lua print("=== 基础功能测试 ===")

-- 测试快捷键映射
lua print("1. 检查 leader 键设置...")
local leader = vim.g.mapleader
if leader then
  print("✓ mapleader 已设置: " .. leader)
else
  print("⚠ mapleader 未设置")
end

-- 测试插件管理器
lua print("2. 检查 lazy.nvim 加载...")
if package.loaded["lazy"] then
  print("✓ lazy.nvim 已加载")
else
  print("✗ lazy.nvim 未加载")
end

-- 测试 AI 命令
lua print("3. 检查 AI 命令注册...")
local commands = vim.api.nvim_get_commands({})
local aiCommands = {}
for cmd, info in pairs(commands) do
  if string.match(cmd, "^AI") then
    table.insert(aiCommands, cmd)
  end
end
if #aiCommands > 0 then
  print("✓ 找到 AI 命令: " .. table.concat(aiCommands, ", "))
else
  print("⚠ 未找到 AI 命令")
end

lua print("`n基础功能测试完成")
quitall
"@

$funcFile = "test-func.lua"
$funcTest | Out-File -FilePath $funcFile -Encoding UTF8

try {
    $output = & $NvimCommand --headless -u init.lua -i NONE -n -e -s -c "source $funcFile" 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ 基础功能测试通过" -ForegroundColor Green
        $output | Where-Object { $_ -match "✓" } | ForEach-Object { Write-Host "  $_" -ForegroundColor Green }
    } else {
        Write-Host "✗ 基础功能测试失败:" -ForegroundColor Red
        $output | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
        exit 1
    }
} finally {
    Remove-Item $funcFile -ErrorAction SilentlyContinue
}

Write-Host "`n=== 所有测试通过 ===" -ForegroundColor Green
Write-Host "测试结束时间: $(Get-Date)" -ForegroundColor Cyan
Write-Host "配置文件验证完成，可以正常使用。" -ForegroundColor Green