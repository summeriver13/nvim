--[[
环境感知模块 - Vibe Coding 核心组件
功能：跨平台路径自适应 + 项目类型检测 + 智能上下文配置
Vibe Coding 提升点：
  1. 消除跨平台路径配置痛苦：自动检测操作系统并适配Python/Node路径，让AI工具链在任何系统上无缝运行
  2. 智能项目上下文感知：根据项目类型动态配置LSP和格式化工具，让AI生成的代码立即符合项目规范
  3. 学术写作模式自动切换：检测LaTeX/BibTeX文件后自动启用拼写检查与PDF编译，让AI辅助学术写作更专注
]]

local M = {}

-- Vibe Coding 提升：自动检测操作系统并适配路径，消除跨平台开发环境配置的认知负担
-- 路径辅助函数：使用vim.loop实现跨平台路径自适应
local function get_cross_platform_paths()
  local is_windows = package.config:sub(1, 1) == "\\"
  local is_mac = vim.fn.has("mac") == 1
  
  local paths = {}
  
  if is_windows then
    -- Windows路径：使用AppData和ProgramData
    paths.config = os.getenv("LOCALAPPDATA") or os.getenv("APPDATA") or ""
    paths.programs = os.getenv("ProgramFiles") or "C:\\Program Files"
    paths.home = os.getenv("USERPROFILE") or ""
    
    -- Python路径：优先检测常用安装位置
    local python_candidates = {
      paths.config .. "\\Programs\\Python\\Python312\\python.exe",
      paths.config .. "\\Programs\\Python\\Python311\\python.exe",
      paths.programs .. "\\Python312\\python.exe",
      paths.programs .. "\\Python311\\python.exe",
    }
    
    -- Node.js路径
    local node_candidates = {
      paths.home .. "\\AppData\\Roaming\\npm\\node.exe",
      paths.programs .. "\\nodejs\\node.exe",
    }
    
    paths.python = M.find_executable(python_candidates) or "python"
    paths.node = M.find_executable(node_candidates) or "node"
    
  elseif is_mac then
    -- macOS路径：使用标准Unix路径和Homebrew
    paths.config = vim.fn.stdpath("config")
    paths.home = vim.fn.expand("~")
    
    local python_candidates = {
      "/usr/bin/python3",
      "/usr/local/bin/python3",
      paths.home .. "/.pyenv/shims/python3",
    }
    
    local node_candidates = {
      "/usr/local/bin/node",
      "/opt/homebrew/bin/node",
      paths.home .. "/.nvm/versions/node/*/bin/node",
    }
    
    paths.python = M.find_executable(python_candidates) or "python3"
    paths.node = M.find_executable(node_candidates) or "node"
    
  else
    -- Linux路径：使用标准Unix路径和版本管理器
    paths.config = vim.fn.stdpath("config")
    paths.home = vim.fn.expand("~")
    
    local python_candidates = {
      "/usr/bin/python3",
      "/usr/local/bin/python3",
      paths.home .. "/.pyenv/shims/python3",
    }
    
    local node_candidates = {
      "/usr/bin/node",
      "/usr/local/bin/node",
      paths.home .. "/.nvm/versions/node/*/bin/node",
    }
    
    paths.python = M.find_executable(python_candidates) or "python3"
    paths.node = M.find_executable(node_candidates) or "node"
  end
  
  paths.os = is_windows and "windows" or (is_mac and "macos" or "linux")
  return paths
end

-- Vibe Coding 提升：智能查找可执行文件，确保AI工具链在各种环境都能正确调用
-- 查找可执行文件：使用vim.loop进行跨平台文件检测
function M.find_executable(candidates)
  for _, candidate in ipairs(candidates) do
    -- 处理通配符路径
    if candidate:match("%*") then
      local expanded = vim.fn.glob(candidate, false, true)
      if #expanded > 0 then
        candidate = expanded[1]
      end
    end
    
    -- 检查文件是否存在且可执行
    local stat = vim.loop.fs_stat(candidate)
    if stat and stat.type == "file" then
      return candidate
    end
  end
  return nil
end

-- Vibe Coding 提升：一键初始化AI编程环境，智能适配项目类型，让开发者专注于创意而非配置
-- 环境感知：自动检测操作系统和项目上下文
function M.setup()
  -- 获取跨平台路径
  local paths = get_cross_platform_paths()
  
  -- 设置全局路径变量
  vim.g.python3_host_prog = paths.python
  vim.g.node_host_prog = paths.node
  
  -- 项目类型检测
  local project_type = M.detect_project_type()
  
  -- 根据项目类型设置AI模式
  vim.g.ai_context = {
    os = paths.os,
    project_type = project_type,
    timestamp = os.time(),
    paths = paths,
  }
  
  -- 设置语言服务器配置
  M.setup_lsp(project_type)
  
  -- 设置格式化工具
  M.setup_formatters(project_type)
end

-- Vibe Coding 提升：自动识别项目类型，让AI生成的代码符合项目规范，减少手动配置
-- 检测项目类型
function M.detect_project_type()
  local cwd = vim.fn.getcwd()
  
  -- 检查常见的项目配置文件
  local config_files = {
    { "pyproject.toml", "python" },
    { "package.json", "javascript" },
    { "Cargo.toml", "rust" },
    { "go.mod", "go" },
    { "requirements.txt", "python" },
    { "composer.json", "php" },
    { "Gemfile", "ruby" },
  }
  
  for _, config in ipairs(config_files) do
    local file_path = cwd .. "/" .. config[1]
    if vim.fn.filereadable(file_path) == 1 then
      return config[2]
    end
  end
  
  -- 检查目录结构
  local dirs = {
    { "src", "generic" },
    { "lib", "generic" },
    { "app", "web" },
    { "public", "web" },
  }
  
  for _, dir in ipairs(dirs) do
    local dir_path = cwd .. "/" .. dir[1]
    if vim.fn.isdirectory(dir_path) == 1 then
      return dir[2]
    end
  end
  
  return "unknown"
end

-- Vibe Coding 提升：根据项目类型智能配置LSP，确保AI生成的代码获得实时语法检查和类型提示
-- 设置语言服务器
function M.setup_lsp(project_type)
  local lsp_config = require("lspconfig")
  
  -- Python项目：深度集成Pyright和Ruff
  if project_type == "python" then
    lsp_config.pyright.setup({
      settings = {
        python = {
          analysis = {
            typeCheckingMode = "strict",
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
          },
        },
      },
    })
    
    -- Ruff 配置 (替代已弃用的 ruff_lsp)
    lsp_config.ruff.setup({
      init_options = {
        settings = {
          args = { "--select=E9,F63,F7,F82", "--extend-select=UP" },
        },
      },
    })
  
  -- JavaScript/TypeScript项目
  elseif project_type == "javascript" then
    lsp_config.ts_ls.setup({
      settings = {
        typescript = {
          suggest = {
            completeFunctionCalls = true,
          },
        },
      },
    })
  end
end

-- Vibe Coding 提升：自动配置项目专用格式化工具，让AI生成的代码风格统一，符合团队规范
-- 设置格式化工具
function M.setup_formatters(project_type)
  local status_null, null_ls = pcall(require, "null-ls")
  if not status_null then
    -- 简体中文注释：null-ls 尚未加载或未安装，这在初次启动或 lazy 同步时是正常的
    return
  end
  
  local sources = {}
  
  -- Python格式化
  if project_type == "python" then
    table.insert(sources, null_ls.builtins.formatting.black)
    table.insert(sources, null_ls.builtins.formatting.isort)
    table.insert(sources, null_ls.builtins.diagnostics.ruff)
  
  -- JavaScript格式化
  elseif project_type == "javascript" then
    table.insert(sources, null_ls.builtins.formatting.prettier)
    table.insert(sources, null_ls.builtins.diagnostics.eslint_d)
  
  -- Markdown格式化（学术写作）
  else
    table.insert(sources, null_ls.builtins.formatting.prettier)
  end
  
  -- 通用格式化工具
  table.insert(sources, null_ls.builtins.formatting.stylua)
  
  null_ls.setup({ sources = sources })
end

-- 学术写作环境检测
function M.setup_academic()
  local cwd = vim.fn.getcwd()
  
  -- 检查学术写作相关文件
  local academic_files = {
    "references.bib",
    "*.tex",
    "*.bib",
    "paper.md",
  }
  
  for _, pattern in ipairs(academic_files) do
    local files = vim.fn.glob(cwd .. "/" .. pattern, false, true)
    if #files > 0 then
      -- 启用学术写作模式
      vim.g.academic_mode = true
      
      -- 设置Markdown和LaTeX相关配置
      vim.bo.textwidth = 80
      vim.bo.spell = true
      vim.bo.spelllang = "en_us"
      
      -- 学术写作快捷键
      vim.keymap.set("n", "<leader>cb", "<cmd>!pandoc % -o %:r.pdf<cr>", { desc = "编译Markdown到PDF" })
      
      break
    end
  end
end

-- 初始化环境感知
M.setup()

-- 学术写作环境检测（延迟执行）
vim.defer_fn(function()
  M.setup_academic()
end, 1000)

print("✅ 环境感知配置完成 - 智能上下文检测已启用")

return M