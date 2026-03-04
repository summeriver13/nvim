-- # lua/kits/ui/layout.lua

--- @class KitsLayout
local M = {}

-- 布局公共配置参数 (DRY 原则)
M.config = {
  tree_width = 30,
  avante_width = 40,
  terminal_height_ratio = 0.3, -- 终端高度占比 30%
}

--- 核心布局归位逻辑
--- 利用 Neovim 的 split (水平分割) 和 vsplit (垂直分割) API
--- 配合 wincmd 强制定位，确保四象限组件不冲突
function M.restore()
  -- 1. 确保所有 UI 插件已加载
  local tree_api = require("nvim-tree.api")
  local avante_api = require("avante.api")
  local terminal = require("toggleterm")

  -- 2. 归位文件树 (Left)
  -- 使用 topleft 属性或 wincmd H 确保其占据最左侧全高
  if not tree_api.tree.is_visible() then
    tree_api.tree.open({ focus = false })
  end
  vim.cmd("NvimTreeFocus")
  vim.cmd("wincmd H") -- 强制移动到最左侧
  vim.api.nvim_win_set_width(0, M.config.tree_width)

  -- 3. 归位 AI 对话区 (Right)
  -- Avante 默认配置为 right，通过 wincmd L 确保其在最右侧
  avante_api.ask()
  vim.cmd("wincmd L") -- 强制移动到最右侧
  vim.api.nvim_win_set_width(0, M.config.avante_width)

  -- 4. 归位中间代码区与终端 (Middle)
  -- 焦点回到中间编辑区
  vim.cmd("wincmd h") -- 从右侧往左跳回编辑区
  
  -- 开启/刷新底部终端
  -- ToggleTerm 配置为 horizontal，利用 wincmd J 确保其在当前窗口下方
  terminal.toggle(0, 15, nil, "horizontal")
  
  -- 调整高度比例
  local total_height = vim.api.nvim_get_option_value("lines", {})
  local term_height = math.floor(total_height * M.config.terminal_height_ratio)
  vim.api.nvim_win_set_height(0, term_height)

  -- 5. 最终焦点回到主代码编辑区 (Middle-Top)
  vim.cmd("wincmd k")
end

--- 自动监听窗口大小变化 (使用 vim.uv)
function M.setup_autoresize()
  local timer = vim.uv.new_timer()
  vim.api.nvim_create_autocmd("VimResized", {
    callback = function()
      -- 延迟 100ms 重新计算布局，避免频繁触发导致的闪烁
      timer:start(100, 0, vim.schedule_wrap(function()
        if M.is_layout_active() then
          M.restore()
        end
      end))
    end
  })
end

--- 判断当前是否处于四象限布局模式
function M.is_layout_active()
  local tree_visible = require("nvim-tree.api").tree.is_visible()
  -- 简单判断：如果文件树开着，则认为处于布局状态
  return tree_visible
end

return M
