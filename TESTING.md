# Neovim AI 增强配置规范化测试

本文档描述如何对 Neovim AI 增强配置进行可控的规范化测试，确保配置质量、功能完整性和跨平台兼容性。

## 测试架构

```
nvim/
├── test/                    # 测试目录
│   ├── test-config.ps1     # 配置加载测试
│   ├── test-ai-functional.ps1 # AI功能测试
│   └── check-syntax.ps1    # 语法检查
├── test.ps1               # 主测试脚本
├── .luacheckrc           # Lua语法检查配置
└── TESTING.md           # 本文档
```

## 测试类型

### 1. 语法检查 (Syntax Checking)
使用 `luacheck` 工具检查 Lua 代码的语法和规范。

**检查内容：**
- 语法错误
- 未使用的变量和函数
- 代码风格违规
- 潜在的逻辑错误

**配置：** `.luacheckrc` 文件包含针对 Neovim Lua 环境的特殊配置。

### 2. 配置加载测试 (Configuration Loading Test)
使用 Neovim 的 headless 模式测试配置文件是否能正常加载。

**测试内容：**
- 核心模块加载 (`core/`, `kits/`, `plugins/`)
- AI 模块加载 (`kits/ai/`)
- LSP 配置加载
- 插件管理器初始化

### 3. AI 功能测试 (AI Functional Test)
测试 AI 增强功能的完整性和可用性。

**测试内容：**
- AI 命令注册 (AIChat, AICode, AIDebug)
- AI 模块加载状态
- 快捷键映射和冲突检查
- LSP 集成配置
- 环境感知功能

## 使用方法

### 运行所有测试

```powershell
# 在项目根目录执行
.\test.ps1
```

### 运行特定测试类型

```powershell
# 只运行语法检查
.\test.ps1 -TestType syntax

# 只运行配置加载测试
.\test.ps1 -TestType config

# 只运行 AI 功能测试
.\test.ps1 -TestType ai
```

### 详细输出模式

```powershell
.\test.ps1 -Verbose
```

### 查看帮助

```powershell
.\test.ps1 -Help
```

## 测试用例详情

### 语法检查用例
1. **Lua 代码语法验证** - 确保所有 Lua 文件语法正确
2. **规范检查** - 检查代码风格和最佳实践
3. **未使用代码检测** - 识别未使用的变量和函数

### 配置加载测试用例
1. **模块加载测试** - 验证所有核心模块能正常加载
2. **插件初始化测试** - 检查插件管理器配置
3. **路径配置验证** - 验证跨平台路径适配

### AI 功能测试用例
1. **命令注册验证** - 检查 AI 命令是否正确定义
2. **快捷键冲突检查** - 确保 AI 快捷键不与 LSP/Telescope 冲突
3. **模块依赖测试** - 验证 AI 模块间的依赖关系
4. **环境感知测试** - 检查操作系统检测和路径适配
5. **LSP 集成测试** - 验证 LSP 服务器配置

## 前置要求

### 必需软件
1. **Neovim** (>= 0.8) - 测试目标
2. **PowerShell** (>= 5.1) - 测试脚本运行环境

### 可选软件
1. **luacheck** - 用于语法检查
   ```bash
   # 安装方法
   luarocks install luacheck
   ```

2. **LuaRocks** - luacheck 的包管理器
   - Windows: 从 [luarocks.org](https://luarocks.org) 下载安装
   - macOS: `brew install luarocks`
   - Linux: `apt install luarocks` 或 `yum install luarocks`

## 测试输出示例

### 成功输出
```
=== Neovim AI 增强配置规范化测试 ===
测试开始时间: 2026-03-04 23:30:00
测试类型: all

[1] 语法检查
描述: 检查 Lua 代码语法和规范
✓ Lua 语法检查通过

[2] 配置加载
描述: 测试配置文件和模块加载
✓ 配置加载测试通过

[3] AI 功能
描述: 测试 AI 命令和功能
✓ AI 功能测试完成

=== 测试摘要 ===
测试完成时间: 2026-03-04 23:30:15
总耗时: 15.23 秒
测试结果: 3 通过, 0 失败, 0 错误

✓ 所有测试通过！配置验证成功。
```

### 失败输出
```
[1] 语法检查
描述: 检查 Lua 代码语法和规范
✗ Lua 语法检查发现问题:
  lua/kits/ai/avante.lua:45: unused variable 'temp'

测试失败，停止后续测试...
```

## 故障排除

### 常见问题

1. **luacheck 未安装**
   ```
   错误: luacheck 未安装
   安装方法:
   1. 安装 LuaRocks: https://luarocks.org
   2. 安装 luacheck: luarocks install luacheck
   ```
   解决方案：安装 luacheck 或跳过语法检查：`.\test.ps1 -TestType config`

2. **Neovim 未找到**
   ```
   错误: Neovim 未安装或不在 PATH 中
   ```
   解决方案：确保 Neovim 已安装并添加到系统 PATH

3. **配置文件加载失败**
   ```
   ✗ 配置加载测试失败:
     Error: module 'kits.ai.avante' not found
   ```
   解决方案：检查模块路径和文件是否存在

4. **快捷键冲突**
   ```
   ⚠ 发现 1 个可能的快捷键冲突:
     - <leader>ff 已被占用: Telescope find_files
   ```
   解决方案：修改 AI 快捷键配置避免冲突

### 调试模式

使用详细输出模式查看完整测试过程：
```powershell
.\test.ps1 -Verbose
```

## 扩展测试

### 添加新测试

1. 在 `test/` 目录创建新的 PowerShell 测试脚本
2. 脚本应以非零退出码表示测试失败
3. 在 `test.ps1` 中添加测试到相应的测试类型

### 测试脚本模板

```powershell
# test/test-new-feature.ps1
$ErrorActionPreference = "Stop"

Write-Host "=== 新功能测试 ===" -ForegroundColor Green

# 测试逻辑...
# 使用 nvim --headless 进行测试

if ($测试通过) {
    Write-Host "✓ 测试通过" -ForegroundColor Green
    exit 0
} else {
    Write-Host "✗ 测试失败" -ForegroundColor Red
    exit 1
}
```

## CI/CD 集成

### GitHub Actions 示例

```yaml
name: Neovim Config Test

on: [push, pull_request]

jobs:
  test:
    runs-on: windows-latest
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Setup Neovim
      run: choco install neovim
    
    - name: Run Tests
      run: .\test.ps1
```

## 版本历史

- v1.0.0 (2026-03-04): 初始版本，包含语法检查、配置加载、AI功能测试

## 贡献指南

1. 确保新代码通过现有测试
2. 添加新功能时补充相应测试
3. 更新测试文档反映变更
4. 保持测试脚本跨平台兼容