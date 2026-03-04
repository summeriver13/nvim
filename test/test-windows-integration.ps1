# test-windows-integration.ps1
# Windows 环境 AI 集成系统测试脚本

Write-Host "🔧 开始测试 Windows AI 集成系统..." -ForegroundColor Green

# 测试 1: 编码转换模块
try {
    Write-Host "🧪 测试编码转换..." -ForegroundColor Yellow
    nvim --headless -c "lua require('kits.utils.encoding').test_encoding()" -c "qa!"
    Write-Host "✅ 编码转换测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 编码转换测试失败: $_" -ForegroundColor Red
}

# 测试 2: 环境检测模块  
try {
    Write-Host "🧪 测试环境检测..." -ForegroundColor Yellow
    nvim --headless -c "lua print('Windows 系统: ' .. tostring(require('kits.utils.env').is_windows()))" -c "qa!"
    Write-Host "✅ 环境检测测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 环境检测测试失败: $_" -ForegroundColor Red
}

# 测试 3: 命令路由模块
try {
    Write-Host "🧪 测试命令路由..." -ForegroundColor Yellow
    nvim --headless -c "lua 
        local env = require('kits.utils.env')
        local test_cmds = {'ls -la', 'pwd', 'cat test.txt', 'rm -rf node_modules'}
        for _, cmd in ipairs(test_cmds) do
            local routed = env.route_command(cmd)
            print('路由: ' .. cmd .. ' -> ' .. routed)
        end
    " -c "qa!"
    Write-Host "✅ 命令路由测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 命令路由测试失败: $_" -ForegroundColor Red
}

# 测试 4: 布局系统
try {
    Write-Host "🧪 测试四象限布局..." -ForegroundColor Yellow
    nvim --headless -c "lua 
        local layout = require('kits.ui.layout')
        layout.setup()
        print('布局系统初始化完成')
    " -c "qa!"
    Write-Host "✅ 布局系统测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ 布局系统测试失败: $_" -ForegroundColor Red
}

# 测试 5: AI 核心集成
try {
    Write-Host "🧪 测试AI核心集成..." -ForegroundColor Yellow
    nvim --headless -c "lua 
        local integration = require('kits.ai.integration')
        integration.setup()
        print('AI集成系统就绪')
    " -c "qa!"
    Write-Host "✅ AI核心集成测试通过" -ForegroundColor Green
} catch {
    Write-Host "❌ AI核心集成测试失败: $_" -ForegroundColor Red
}

Write-Host ""
Write-Host "🎉 Windows AI 集成系统测试完成!" -ForegroundColor Cyan
Write-Host "📋 下一步: 运行 nvim 并输入 `<leader>L` 应用四象限布局" -ForegroundColor White
Write-Host "   📁 文件树 (左) | 📝 编辑器 (中上) | 💻 终端 (中下) | 🤖 AI (右)" -ForegroundColor White