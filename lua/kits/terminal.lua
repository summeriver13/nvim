-- # kits/terminal.lua

-- Vibe Coding 提升：类 Trae/VSCode 的底部嵌入式终端
-- 功能：Ctrl+\ 快速唤起/隐藏，始终位于编辑区下方

require("toggleterm").setup({
  -- 开启大小自动调整
  size = function(term)
    if term.direction == "horizontal" then
      return 15
    elseif term.direction == "vertical" then
      return vim.o.columns * 0.4
    end
  end,
  open_mapping = [[<c-\>]], -- 快捷键：Ctrl + \
  hide_numbers = true,
  shade_terminals = true,
  start_in_insert = true,
  insert_mappings = true,
  persist_size = true,
  direction = "horizontal", -- 水平开启（底部）
  close_on_exit = true,
  shell = vim.o.shell,
  auto_scroll = true,
  -- Vibe Coding 提升：配置终端开启时确保不占据文件树的空间
  -- 使用 wincmd j 确保它作为当前窗口（代码区）的下部分割，而不是全局底部
  on_open = function(term)
    vim.cmd("wincmd j")
  end,
  -- 样式设置
  highlights = {
    Normal = { link = "Normal" },
    NormalFloat = { link = "Normal" },
    FloatBorder = { link = "Normal" },
  },
  winbar = {
    enabled = true,
    name_formatter = function(term)
      return "   终端 " .. term.id
    end,
  },
})

-- 终端模式下的快捷键优化
function _G.set_terminal_keymaps()
  local opts = {buffer = 0}
  vim.keymap.set('t', '<esc>', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', 'jk', [[<C-\><C-n>]], opts)
  vim.keymap.set('t', '<C-h>', [[<Cmd>wincmd h<CR>]], opts)
  vim.keymap.set('t', '<C-j>', [[<Cmd>wincmd j<CR>]], opts)
  vim.keymap.set('t', '<C-k>', [[<Cmd>wincmd k<CR>]], opts)
  vim.keymap.set('t', '<C-l>', [[<Cmd>wincmd l<CR>]], opts)
  vim.keymap.set('t', '<C-w>', [[<C-\><C-n><C-w>]], opts)
end

-- 仅在进入终端缓冲区时启用这些映射
vim.cmd('autocmd! TermOpen term://* lua set_terminal_keymaps()')

-- 提供一个全局函数用于切换终端
local M = {}
function M.toggle()
  vim.cmd("ToggleTerm")
end

-- Vibe Coding 提升：启动时自动开启底部终端，复刻 IDE 完整布局
function M.setup()
  vim.api.nvim_create_autocmd("VimEnter", {
    callback = function()
      -- 延迟执行以确保主窗口布局已稳定
      vim.defer_fn(function()
        -- 仅在没有通过 nvim 打开特定文件（即空启动）或者正常启动时开启
        -- 避免在进行 git commit 等临时操作时弹出终端
        if vim.bo.buftype == "" then
          vim.cmd("ToggleTerm")
          -- 开启后将焦点跳回到上方编辑区，保持“编辑器优先”
          vim.cmd("wincmd k")
        end
      end, 300)
    end,
  })
end

return M
