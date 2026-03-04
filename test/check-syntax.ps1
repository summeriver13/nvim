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
$luacheckArgs = @(".", "--exclude-files", "test/**", "--formatter", "plain")
$luacheckResult = & luacheck @luacheckArgs 2>&1

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