-- # kits/line.lua

-- - lualine.nvim 状态栏
-- - gitsigns.nvim 状态栏 git图标

-- ## lualine.nvim

require('lualine').setup {
  options = {
    theme  = 'tokyonight',
    icons_enabled = true,
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  }
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
