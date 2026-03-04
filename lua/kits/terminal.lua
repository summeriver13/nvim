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

return M
