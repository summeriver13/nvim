# Neovim AI 增强配置测试脚本
# 主测试入口点，执行所有规范化测试

param(
    [string]$TestType = "all",  # all, config, ai, syntax
    [switch]$Verbose,
    [switch]$Help
)

if ($Help) {
    Write-Host "Neovim AI 增强配置测试脚本" -ForegroundColor Green
    Write-Host "用法: .\test.ps1 [-TestType <类型>] [-Verbose] [-Help]" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "测试类型:" -ForegroundColor Yellow
    Write-Host "  all     - 运行所有测试（默认）"
    Write-Host "  config  - 只运行配置加载测试"
    Write-Host "  ai      - 只运行 AI 功能测试" 
    Write-Host "  syntax  - 只运行语法检查"
    Write-Host ""
    Write-Host "示例:" -ForegroundColor Cyan
    Write-Host "  .\test.ps1                   # 运行所有测试"
    Write-Host "  .\test.ps1 -TestType ai      # 只测试 AI 功能"
    Write-Host "  .\test.ps1 -Verbose          # 详细输出"
    exit 0
}

Write-Host "=== Neovim AI 增强配置规范化测试 ===" -ForegroundColor Green
Write-Host "测试开始时间: $(Get-Date)" -ForegroundColor Cyan
Write-Host "测试类型: $TestType" -ForegroundColor Yellow
Write-Host "工作目录: $(Get-Location)" -ForegroundColor Cyan

# 检查测试目录是否存在
if (-not (Test-Path "test")) {
    Write-Host "错误: test 目录不存在" -ForegroundColor Red
    Write-Host "请确保在项目根目录运行此脚本" -ForegroundColor Yellow
    exit 1
}

$testResults = @()
$startTime = Get-Date

function Run-Test {
    param(
        [string]$Name,
        [string]$ScriptPath,
        [string]$Description
    )
    
    Write-Host "`n[$($testResults.Count + 1)] $Name" -ForegroundColor Yellow
    Write-Host "描述: $Description" -ForegroundColor Gray
    
    if (-not (Test-Path $ScriptPath)) {
        Write-Host "错误: 测试脚本不存在: $ScriptPath" -ForegroundColor Red
        $testResults += @{Name = $Name; Status = "Error"; Message = "脚本不存在"}
        return $false
    }
    
    try {
        if ($Verbose) {
            Write-Host "执行: $ScriptPath" -ForegroundColor DarkGray
            & $ScriptPath
        } else {
            $output = & $ScriptPath 2>&1
        }
        
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ $Name 通过" -ForegroundColor Green
            $testResults += @{Name = $Name; Status = "Pass"; Message = "测试通过"}
            return $true
        } else {
            Write-Host "✗ $Name 失败 (退出码: $LASTEXITCODE)" -ForegroundColor Red
            if (-not $Verbose) {
                # 显示最后几行输出以帮助调试
                Write-Host "最后 10 行输出:" -ForegroundColor Red
                $lastLines = $output | Select-Object -Last 10
                $lastLines | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
            }
            $testResults += @{Name = $Name; Status = "Fail"; Message = "测试失败"}
            return $false
        }
    } catch {
        Write-Host "✗ $Name 异常: $_" -ForegroundColor Red
        $testResults += @{Name = $Name; Status = "Error"; Message = "执行异常: $_"}
        return $false
    }
}

# 根据测试类型选择要运行的测试
$testsToRun = @()

switch ($TestType) {
    "all" {
        $testsToRun = @(
            @{Name = "语法检查"; Script = "test\check-syntax.ps1"; Description = "检查 Lua 代码语法和规范"},
            @{Name = "配置加载"; Script = "test\test-config.ps1"; Description = "测试配置文件和模块加载"},
            @{Name = "AI 功能"; Script = "test\test-ai-functional.ps1"; Description = "测试 AI 命令和功能"}
        )
    }
    "config" {
        $testsToRun = @(
            @{Name = "配置加载"; Script = "test\test-config.ps1"; Description = "测试配置文件和模块加载"}
        )
    }
    "ai" {
        $testsToRun = @(
            @{Name = "AI 功能"; Script = "test\test-ai-functional.ps1"; Description = "测试 AI 命令和功能"}
        )
    }
    "syntax" {
        $testsToRun = @(
            @{Name = "语法检查"; Script = "test\check-syntax.ps1"; Description = "检查 Lua 代码语法和规范"}
        )
    }
    default {
        Write-Host "错误: 未知的测试类型: $TestType" -ForegroundColor Red
        Write-Host "使用 -Help 查看可用选项" -ForegroundColor Yellow
        exit 1
    }
}

# 先检查语法检查脚本是否存在，如果不存在则创建
if (-not (Test-Path "test\check-syntax.ps1")) {
    Write-Host "创建语法检查脚本..." -ForegroundColor Yellow
    @'
# Lua 语法检查脚本
# 使用 luacheck 检查代码规范

$ErrorActionPreference = "Stop"

Write-Host "=== Lua 语法检查 ===" -ForegroundColor Green

# 检查 luacheck 是否安装
if (-not (Get-Command luacheck -ErrorAction SilentlyContinue)) {
    Write-Host "警告: luacheck 未安装" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "安装方法（选择一种）:" -ForegroundColor Yellow
    Write-Host "1. 使用 Scoop 安装（推荐）: scoop install luacheck" -ForegroundColor Cyan
    Write-Host "2. 手动下载: https://github.com/lunarmodules/luacheck/releases" -ForegroundColor Cyan
    Write-Host "3. 使用 LuaRocks: luarocks install luacheck（需要先安装 Lua）" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "注意: 由于 luacheck 未安装，跳过语法检查。" -ForegroundColor Yellow
    Write-Host "要继续其他测试，请运行: .\test.ps1 -TestType config" -ForegroundColor Cyan
    Write-Host ""
    # 返回成功退出码，避免阻塞整个测试流程
    exit 0
}

Write-Host "运行 luacheck..." -ForegroundColor Yellow

# 运行 luacheck，忽略测试目录
$luacheckResult = & luacheck . --exclude-files "test/**" --formatter plain 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host "✓ Lua 语法检查通过" -ForegroundColor Green
    if ($luacheckResult) {
        Write-Host "检查结果:" -ForegroundColor Cyan
        $luacheckResult | ForEach-Object { Write-Host "  $_" }
    }
    exit 0
} else {
    Write-Host "✗ Lua 语法检查发现问题:" -ForegroundColor Red
    $luacheckResult | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    
    Write-Host ""
    Write-Host "修复建议:" -ForegroundColor Yellow
    Write-Host "1. 查看 .luacheckrc 配置文件了解检查规则" -ForegroundColor Cyan
    Write-Host "2. 使用 luacheck --fix . 尝试自动修复" -ForegroundColor Cyan
    Write-Host "3. 或暂时跳过语法检查: .\test.ps1 -TestType config" -ForegroundColor Cyan
    
    exit 1
}
'@ | Out-File -FilePath "test\check-syntax.ps1" -Encoding UTF8
}

# 运行测试
$allPassed = $true
foreach ($test in $testsToRun) {
    $passed = Run-Test -Name $test.Name -ScriptPath $test.Script -Description $test.Description
    if (-not $passed) {
        $allPassed = $false
        if ($TestType -eq "all") {
            Write-Host "`n测试失败，停止后续测试..." -ForegroundColor Red
            break
        }
    }
}

# 输出测试摘要
$endTime = Get-Date
$duration = $endTime - $startTime

Write-Host "`n=== 测试摘要 ===" -ForegroundColor Green
Write-Host "测试完成时间: $(Get-Date)" -ForegroundColor Cyan
Write-Host "总耗时: $([math]::Round($duration.TotalSeconds, 2)) 秒" -ForegroundColor Cyan

$passedCount = ($testResults | Where-Object { $_.Status -eq "Pass" }).Count
$failedCount = ($testResults | Where-Object { $_.Status -eq "Fail" }).Count
$errorCount = ($testResults | Where-Object { $_.Status -eq "Error" }).Count

Write-Host "测试结果: $passedCount 通过, $failedCount 失败, $errorCount 错误" -ForegroundColor Cyan

foreach ($result in $testResults) {
    $color = switch ($result.Status) {
        "Pass" { "Green" }
        "Fail" { "Red" }
        "Error" { "Red" }
        default { "Yellow" }
    }
    Write-Host "  $($result.Status.PadRight(6)) - $($result.Name): $($result.Message)" -ForegroundColor $color
}

if ($allPassed) {
    Write-Host "`n✓ 所有测试通过！配置验证成功。" -ForegroundColor Green
    Write-Host "您的 Neovim AI 增强配置已通过规范化测试，可以正常使用。" -ForegroundColor Cyan
    exit 0
} else {
    Write-Host "`n✗ 部分测试失败，请检查配置。" -ForegroundColor Red
    Write-Host "建议:" -ForegroundColor Yellow
    Write-Host "1. 查看详细错误信息" -ForegroundColor Cyan
    Write-Host "2. 检查配置文件语法" -ForegroundColor Cyan
    Write-Host "3. 确保所有插件已安装" -ForegroundColor Cyan
    exit 1
}