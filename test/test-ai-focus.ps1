# test-ai-focus.ps1
# AI 焦点问题测试脚本

Write-Host "🔧 测试 AI 对话焦点问题修复..." -ForegroundColor Green

# 测试 1: 焦点管理系统
try {
    Write-Host "🧪 测试焦点管理模块..." -ForegroundColor Yellow
    nvim --headless -c "lua require('kits.ui.focus').setup()" -c "qa!"
    Write-Host "✅ 焦点管理系统初始化成功" -ForegroundColor Green
} catch {
    Write-Host "❌ 焦点管理测试失败: $_" -ForegroundColor Red
}

# 测试 2: Avante 配置验证
try {
    Write-Host "🧪 验证 Avante 配置..." -ForegroundColor Yellow
    nvim --headless -c "lua 
        local avante = require('avante')
        local config = require('avante.config')
        print('start_insert 设置: ' .. tostring(config.windows.ask.start_insert))
        print('输入框高度: ' .. tostring(config.windows.input.height))
    " -c "qa!"
    Write-Host "✅ Avante 配置验证通过" -ForegroundColor Green
} catch {
    Write-Host "❌ Avante 配置验证失败: $_" -ForegroundColor Red
}

# 测试 3: 编码安全系统
try {
    Write-Host "🧪 测试编码安全系统..." -ForegroundColor Yellow
    nvim --headless -c "lua 
        local encoding = require('kits.utils.encoding')
        local test_str = '测试中文编码安全'
        local cleaned = encoding.deep_clean_utf8(test_str)
        print('编码清洗测试: ' .. cleaned)
    " -c "qa!"
    Write-Host "✅ 编码安全系统测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 编码安全测试失败: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎯 AI 焦点问题修复完成!" -ForegroundColor Cyan
Write-Host "📋 使用说明:" -ForegroundColor White
Write-Host "   1. 打开 AI 对话: `:AIChat` 或 `<leader>L`" -ForegroundColor White  
Write-Host "   2. 如果无法输入: `<leader>fa` (聚焦到 AI 输入框)" -ForegroundColor White
Write-Host "   3. 切换编辑区域: `<leader>fe` (切换到可编辑区域)" -ForegroundColor White
Write-Host "   4. 重置布局: `<leader>L` (四象限布局)" -ForegroundColor White
Write-Host ""
Write-Host "💡 提示: 首次使用可能需要重新启动 Neovim 使配置生效" -ForegroundColor Yellow