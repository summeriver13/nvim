-- # kits/line.lua

-- - lualine.nvim 状态栏
-- - gitsigns.nvim 状态栏 git图标

-- ## lualine.nvim

-- Vibe Coding 提升：自定义 Avante API 消耗显示组件
local function avante_usage()
  local ok, avante = pcall(require, "avante")
  if not ok then return "" end
  
  -- 获取当前 tabpage 的 sidebar
  local sidebar = avante.get(false) -- 传入 false 避免触发侧边栏更新
  if not sidebar or not sidebar.chat_history or not sidebar.chat_history.tokens_usage then
    return ""
  end
  
  local usage = sidebar.chat_history.tokens_usage
  local prompt = usage.prompt_tokens or 0
  local completion = usage.completion_tokens or 0
  
  if prompt == 0 and completion == 0 then return "" end
  
  -- 格式：󱜙 输入/输出 (类 Trae/Cursor 风格)
  return string.format("󱜙 %d/%d", prompt, completion)
end

require('lualine').setup {
  options = {
    theme  = 'tokyonight',
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_x = {
      {
        avante_usage,
        color = { fg = "#7aa2f7" }, -- 使用 tokyonight 的蓝色
      },
      'encoding',
      'fileformat',
      'filetype',
    },
  },
}

-- ## gitsigns.nvim

require('gitsigns').setup {
  signs = {
    add          = { text = '┃' },
    change       = { text = '┃' },
    delete       = { text = '_' },
    topdelete    = { text = '‾' },
    changedelete = { text = '~' },
    untracked    = { text = '┆' },
  },
}
