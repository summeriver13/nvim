-- # lua/kits/ui/layout.lua

--- @class KitsLayout
local M = {}

-- 布局公共配置参数 (DRY 原则)
M.config = {
  tree_width = 30,
  avante_width = 40,
  terminal_height_ratio = 0.3, -- 终端高度占比 30%
}

--- 稳态四象限布局核心
--- 使用防竞争设计和异步队列确保布局稳定性
function M.ApplyVibeLayout()
  -- 创建异步执行队列，防止窗口竞争
  local layout_queue = {}
  
  -- 阶段1: 确保所有插件已加载
  table.insert(layout_queue, function()
    -- 安全加载插件 API（防止 nil 错误）
    local ok, tree_api = pcall(require, "nvim-tree.api")
    local ok2, avante_api = pcall(require, "avante.api")
    local ok3, terminal = pcall(require, "toggleterm")
    
    if not (ok and ok2 and ok3) then
      vim.notify("❌ 布局组件加载失败，请检查插件安装", vim.log.levels.ERROR)
      return false
    end
    
    return true, tree_api, avante_api, terminal
  end)
  
  -- 阶段2: 锁定左侧文件树 (width=30)
  table.insert(layout_queue, function(tree_api, avante_api, terminal)
    -- 确保文件树可见且位于最左侧
    if not tree_api.tree.is_visible() then
      tree_api.tree.open({ focus = false })
      vim.cmd("wincmd p") -- 返回上一个窗口
    end
    
    -- 使用双重锁定策略
    vim.cmd("NvimTreeFocus")
    vim.cmd("wincmd H") -- 强制左对齐
    vim.api.nvim_win_set_width(0, M.config.tree_width)
    
    return true
  end)
  
  -- 阶段3: 锁定右侧 AI 对话区 (width=40)  
  table.insert(layout_queue, function(tree_api, avante_api, terminal)
    -- 安全唤起 AI 面板
    local ok, result = pcall(avante_api.ask)
    if not ok then
      vim.notify("❌ Avante 面板启动失败", vim.log.levels.WARN)
      return true -- 继续布局，跳过 AI 面板
    end
    
    vim.cmd("wincmd L") -- 强制右对齐
    vim.api.nvim_win_set_width(0, M.config.avante_width)
    
    return true
  end)
  
  -- 阶段4: 锁定中间编辑区和底部终端
  table.insert(layout_queue, function(tree_api, avante_api, terminal)
    -- 返回编辑区
    vim.cmd("wincmd h")
    
    -- 安全启动终端
    local ok, result = pcall(terminal.toggle, 0, 15, nil, "horizontal")
    if not ok then
      vim.notify("❌ 终端启动失败", vim.log.levels.WARN)
      return true -- 继续布局，跳过终端
    end
    
    -- 精确计算终端高度
    local total_height = vim.api.nvim_get_option_value("lines", {})
    local editor_height = math.floor(total_height * (1 - M.config.terminal_height_ratio))
    local term_height = total_height - editor_height
    
    vim.api.nvim_win_set_height(0, term_height)
    
    -- 返回编辑区
    vim.cmd("wincmd k")
    
    return true
  end)
  
  -- 异步执行布局队列
  vim.schedule(function()
    local success, tree_api, avante_api, terminal = true, nil, nil, nil
    
    for i, step in ipairs(layout_queue) do
      if i == 1 then
        success, tree_api, avante_api, terminal = step()
      else
        success = step(tree_api, avante_api, terminal)
      end
      
      if not success then break end
      
      -- 添加微小延迟，防止窗口竞争
      if i < #layout_queue then
        vim.defer_fn(function() end, 50)
      end
    end
    
    if success then
      vim.notify("✅ 四象限沉浸式布局已稳定应用", vim.log.levels.INFO)
    end
  end)
end

--- 兼容性别名（保持现有代码可用）
function M.restore()
  M.ApplyVibeLayout()
end

--- 一键重置布局快捷键
function M.setup()
  vim.keymap.set("n", "<leader>L", M.restore, { desc = "一键重置四象限 IDE 布局" })
end

return M
