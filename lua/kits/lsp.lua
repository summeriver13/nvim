--[[
LSP智能感知模块 - Vibe Coding 代码理解层
功能：AI代码分析支持 + 学术写作LSP集成 + 跨平台环境感知
Vibe Coding 提升点：
  1. AI代码质量保证：pyright+ruff_lsp双重保障，确保AI生成的代码符合PEP8标准
  2. 学术写作深度支持：texlab+marksman专门优化，让AI辅助学术写作更加精准
  3. 智能环境感知：自动检测Python虚拟环境，确保AI工具链在任何项目环境工作
]]

-- Vibe Coding 提升：智能的LSP配置，让AI生成的代码立即符合项目规范
-- # kits/lsp.lua
-- 语言服务器协议配置，深度集成AI代码分析与学术写作支持

-- 导入必要模块
local lspconfig = require("lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- ## mason.nvim - LSP服务器管理

-- [Configuration](https://github.com/williamboman/mason.nvim?tab=readme-ov-file#configuration)
require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

-- ## mason-lspconfig.nvim - 自动安装LSP服务器

-- [Configuration](https://github.com/williamboman/mason-lspconfig.nvim?tab=readme-ov-file#configuration)
require("mason-lspconfig").setup {
  ensure_installed = {
    "lua_ls",        -- Lua语言服务器
    "pyright",       -- Python类型检查与智能补全
    "ruff",          -- Python代码风格与格式化 (替代ruff_lsp)
    "texlab",        -- LaTeX写作支持 (学术论文必备)
    "marksman",      -- Markdown语言服务器 (增强AI文档渲染)
  },
}

-- ## lspconfig.nvim - 各语言服务器具体配置

-- Vibe Coding 提升：lua_ls优化Neovim配置编写体验，让AI生成的Lua代码更符合Neovim标准
-- Lua语言服务器
lspconfig.lua_ls.setup {
  capabilities = capabilities,
  settings = {
    Lua = {
      runtime = { version = "LuaJIT" },
      diagnostics = { globals = { "vim" } },
      workspace = { library = vim.api.nvim_get_runtime_file("", true) },
      telemetry = { enable = false },
    },
  },
}

-- Vibe Coding 提升：pyright提供Python智能类型检查，确保AI生成的代码类型安全
-- Python语言服务器 (pyright)
lspconfig.pyright.setup {
  capabilities = capabilities,
  settings = {
    pyright = {
      autoImportCompletion = true,
      typeCheckingMode = "basic",
    },
    python = {
      analysis = {
        autoSearchPaths = true,
        diagnosticMode = "workspace",
        useLibraryCodeForTypes = true,
      },
    },
  },
  -- 环境感知：自动检测虚拟环境
  on_attach = function(client, bufnr)
    -- 自动激活虚拟环境
    if vim.fn.findfile("pyproject.toml", ".;") ~= "" then
      client.config.settings.python.pythonPath = vim.fn.system("poetry env info -p") .. "/bin/python"
    end
  end,
}

-- Vibe Coding 提升：ruff自动格式化AI生成的代码，确保符合PEP8标准
-- Ruff语言服务器 (Python代码风格与格式化)
lspconfig.ruff.setup {
  capabilities = capabilities,
  init_options = {
    settings = {
      args = { "--line-length=88", "--select=ALL" }, -- 符合PEP8标准
    },
  },
  -- 与AI集成：当AI生成代码后自动格式化
  on_attach = function(client, bufnr)
    -- 禁用 ruff 的 hover 提示，因为它可能与 pyright 冲突
    client.server_capabilities.hoverProvider = false
    
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format({ async = false })
      end,
    })
  end,
}

-- Vibe Coding 提升：texlab提供专业级LaTeX支持，让AI辅助学术写作更加精准
-- LaTeX语言服务器 (texlab) - 学术论文写作
lspconfig.texlab.setup {
  capabilities = capabilities,
  settings = {
    texlab = {
      build = {
        executable = "latexmk",
        args = { "-pdf", "-interaction=nonstopmode", "-synctex=1", "%f" },
        onSave = true,
      },
      forwardSearch = {
        executable = "sumatra",
        args = { "-forward-search", "%c", "%p" },
      },
      chktex = {
        onOpenAndSave = true,
      },
    },
  },
}

-- Vibe Coding 提升：marksman增强AI生成的Markdown文档智能提示，提升文档编写体验
-- Markdown语言服务器 (marksman) - AI文档渲染增强
lspconfig.marksman.setup {
  capabilities = capabilities,
  filetypes = { "markdown", "md" },
}

-- Vibe Coding 提升：跨平台环境感知，确保AI工具链在任何操作系统无缝工作
-- 环境感知：根据操作系统调整LSP路径
local function setup_environment()
  local is_windows = package.config:sub(1,1) == "\\"
  
  if is_windows then
    -- Windows系统下使用AppData中的Python
    vim.g.python3_host_prog = os.getenv("LOCALAPPDATA") .. "\\Programs\\Python\\Python311\\python.exe"
  else
    -- macOS/Linux系统使用系统Python
    vim.g.python3_host_prog = "/usr/bin/python3"
  end
end

setup_environment()

print("✅ LSP 配置完成 - Python与学术写作支持已启用")

