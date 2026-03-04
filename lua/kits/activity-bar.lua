-- # kits/activity-bar.lua

-- Vibe Coding 提升：类 Trae/VSCode 的侧边活动栏 (Activity Bar)
-- 功能：最左侧垂直图标栏，支持鼠标点击切换文件树、AI对话等常用侧边栏

local Split = require("nui.split")
local event = require("nui.utils.autocmd").event

local M = {}

-- 定义活动项
local items = {
  { icon = "󰙅", label = "文件", action = function() require("nvim-tree.api").tree.toggle({ focus = true, find_file = true }) end },
  { icon = "󰚩", label = "AI",   action = function() require("avante.api").ask() end },
  { icon = "󰍉", label = "搜索", action = function() require("telescope.builtin").find_files() end },
  { icon = "󰒓", label = "设置", action = function() vim.cmd("edit $MYVIMRC") end },
}

local function create_activity_bar()
  local split = Split({
    relative = "editor",
    position = "left",
    size = 4,
    win_options = {
      number = false,
      relativenumber = false,
      signcolumn = "no",
      winhighlight = "Normal:Normal,FloatBorder:Normal",
      fillchars = "eob: ",
      cursorline = false,
    },
  })

  -- 挂载 split
  split:mount()

  -- 设置缓冲区内容
  local lines = {}
  table.insert(lines, "") -- 顶部留白
  for _, item in ipairs(items) do
    table.insert(lines, " " .. item.icon .. " ")
    table.insert(lines, "") -- 图标间距
  end
  
  vim.api.nvim_buf_set_lines(split.bufnr, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = split.bufnr })
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = split.bufnr })
  vim.api.nvim_set_option_value("filetype", "activitybar", { buf = split.bufnr })

  -- 设置鼠标点击映射
  vim.keymap.set("n", "<LeftRelease>", function()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row = cursor[1]
    -- 计算点击了哪个项 (基于上面的布局逻辑：1行留白，每项2行)
    local idx = math.floor((row - 1) / 2) + 1
    if items[idx] and items[idx].action then
      items[idx].action()
    end
  end, { buffer = split.bufnr, silent = true, nowait = true })

  -- 阻止该窗口被意外选中或用于打开文件
  vim.api.nvim_create_autocmd("BufEnter", {
    buffer = split.bufnr,
    callback = function()
      vim.opt_local.modifiable = false
      vim.opt_local.buflisted = false
    end
  })

  -- 自动清理实例
  split:on(event.BufDelete, function()
    M.instance = nil
  end)

  return split
end

function M.toggle()
  if M.instance then
    M.instance:unmount()
    M.instance = nil
  else
    M.instance = create_activity_bar()
  end
end

function M.setup()
  -- 启动时自动开启
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      vim.defer_fn(function()
        if not M.instance then
          M.instance = create_activity_bar()
        end
      end, 200) -- 稍微延迟，确保其他侧边栏布局稳定
    end
  })
end

return M
