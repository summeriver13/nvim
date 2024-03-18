-- # kits/line.lua

-- - lualine.nvim 状态栏
-- - gitsigns.nvim 状态栏 git图标

-- ## lualine.nvim

require('lualine').setup {
  options = {
    theme  = 'tokyonight'
  }
}

-- ## gitsigns.nvim

require('gitsigns').setup {
  signs = {
    add = { text = '+' },
    change = { text = '~' },
    delete = { text = '_' },
    topdelete = { text = '‾' },
    changedelete = { text = '~' },
  },
}
