--[[
Markdown渲染模块 - Vibe Coding 学术写作体验
功能：AI生成Markdown实时预览 + LaTeX数学公式支持 + 学术引用渲染
Vibe Coding 提升点：
  1. AI响应可视化渲染：Markdown格式的AI响应自动渲染为美观文档，提升阅读体验
  2. 学术写作深度支持：LaTeX数学公式和Zotero引用渲染，让AI成为学术写作助手
  3. 自动预览集成：AI返回Markdown时自动打开预览，实现从提问到精美文档的无缝转换
]]

-- Vibe Coding 提升：配置专业级Markdown渲染，让AI生成的文档拥有出版级视觉效果
-- Render Markdown 配置：完美渲染AI返回的Markdown文档，支持学术论文写作预览
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_open_ip = ''
vim.g.mkdp_browser = ''
vim.g.mkdp_echo_preview_url = 1
vim.g.mkdp_browserfunc = ''
vim.g.mkdp_preview_options = {
  mkit = {},
  katex = {},
  uml = {},
  maid = {},
  disable_sync_scroll = 0,
  sync_scroll_type = 'middle',
  hide_yaml_meta = 1,
  sequence_diagrams = {},
  flowchart_diagrams = {},
  content_editable = false,
  disable_filename = 0,
  toc = {}
}
vim.g.mkdp_markdown_css = ''
vim.g.mkdp_highlight_css = ''
vim.g.mkdp_port = ''
vim.g.mkdp_page_title = 'AI Markdown预览'
vim.g.mkdp_filetypes = { 'markdown', 'md', 'txt' }

-- 学术写作优化配置：支持LaTeX数学公式和Zotero引用
vim.g.mkdp_math_enabled = 1
vim.g.mkdp_bibliography_enabled = 1
vim.g.mkdp_citation_style = 'apa'

-- Vibe Coding 提升：AI响应自动渲染为精美文档，实现从对话到文档的无缝转换
-- 与Avante AI集成：自动预览AI返回的Markdown响应
local function setup_ai_integration()
  local avante = require("avante")
  
  -- 当AI返回Markdown格式响应时，自动打开预览
  avante.on_response(function(response)
    if response.format == "markdown" or response.content:match("# ") then
      -- 将AI响应写入临时文件并预览
      local temp_file = os.tmpname() .. ".md"
      local file = io.open(temp_file, "w")
      if file then
        file:write(response.content)
        file:close()
        
        -- 使用Markdown预览插件打开
        vim.cmd("MarkdownPreview " .. temp_file)
      end
    end
  end)
end

-- 环境感知：根据操作系统调整预览浏览器
local function setup_environment()
  local is_windows = package.config:sub(1,1) == "\\"
  
  if is_windows then
    -- Windows系统使用默认浏览器
    vim.g.mkdp_browser = ''
  else
    -- macOS系统使用Safari，Linux使用Firefox
    if vim.fn.has('mac') == 1 then
      vim.g.mkdp_browser = 'safari'
    else
      vim.g.mkdp_browser = 'firefox'
    end
  end
end

-- 快捷键配置：快速打开/关闭Markdown预览
vim.api.nvim_set_keymap('n', '<leader>mp', ':MarkdownPreview<CR>', { noremap = true, silent = true, desc = "打开Markdown预览" })
vim.api.nvim_set_keymap('n', '<leader>mc', ':MarkdownPreviewStop<CR>', { noremap = true, silent = true, desc = "关闭Markdown预览" })

setup_ai_integration()
setup_environment()

print("✅ Render Markdown 配置完成 - AI文档渲染系统已启用")
