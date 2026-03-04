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
--- 利用 vim.schedule 确保在插件初始化后，按顺序锁定四象限
function M.restore()
  vim.schedule(function()
    -- 1. 加载组件 API
    local tree_api = require("nvim-tree.api")
    local avante_api = require("avante.api")
    local terminal = require("toggleterm")

    -- 2. 锁定文件树 (Left)
    -- 使用 Side 属性与 H 命令双重锁定最左侧全高
    if not tree_api.tree.is_visible() then
      tree_api.tree.open({ focus = false })
    end
    vim.cmd("NvimTreeFocus")
    vim.cmd("wincmd H") -- 强制占据最左侧
    vim.api.nvim_win_set_width(0, M.config.tree_width)

    -- 3. 锁定 AI 对话区 (Right)
    -- 强制 Avante 占据最右侧
    avante_api.ask()
    vim.cmd("wincmd L") -- 强制占据最右侧
    vim.api.nvim_win_set_width(0, M.config.avante_width)

    -- 4. 锁定中间区域 (Middle)
    -- 跳回编辑区并开启嵌入式终端
    vim.cmd("wincmd h") -- 从 AI 区域向左跳回编辑区
    
    -- 唤起终端并设置方向
    terminal.toggle(0, 15, nil, "horizontal")
    
    -- 计算并强制设置终端高度
    local total_height = vim.api.nvim_get_option_value("lines", {})
    local term_height = math.floor(total_height * M.config.terminal_height_ratio)
    vim.api.nvim_win_set_height(0, term_height)

    -- 5. 焦点复位
    vim.cmd("wincmd k") -- 回到上方编辑区
    print("✅ 四象限沉浸式布局已重置")
  end)
end

--- 一键重置布局快捷键
function M.setup()
  vim.keymap.set("n", "<leader>L", M.restore, { desc = "一键重置四象限 IDE 布局" })
end

return M
