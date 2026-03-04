-- # kits/tree.lua

-- - nvim-tree.nvim
-- - nvim-treesitter.nvim

-- ## nvim-tree.nvim

-- [Setup]()

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

-- empty setup using defaults
local status_nt, nvim_tree = pcall(require, "nvim-tree")
if status_nt then
  nvim_tree.setup({
    sort = {
      sorter = "case_sensitive",
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
      icons = {
        show = {
          file = true,
          folder = true,
          folder_arrow = true,
          git = true,
        },
      },
    },
    filters = {
      dotfiles = true,
    },
  })
end

-- ## nvim-treesitter.nvim

-- [Modules](https://github.com/nvim-treesitter/nvim-treesitter?tab=readme-ov-file)

local status_tree, treesitter = pcall(require, "nvim-treesitter.configs")
if status_tree then
  treesitter.setup {
    -- A list of parser names, or "all" (the five listed parsers should always be installed)
    ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "ruby", "html"},

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don't have `tree-sitter` CLI installed locally
    auto_install = true,

    -- List of parsers to ignore installing (or "all")
    ignore_install = { "javascript" },

    highlight = {
      enable = true,

      -- NOTE: these are the names of the parsers and not the filetype. (for example if you want to
      -- disable highlight for some filetypes, use `disable`)
      disable = function(lang, buf)
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
              return true
          end
      end,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      additional_vim_regex_highlighting = false,
    },
  }
else
  -- 简体中文注释：nvim-treesitter 尚未加载，这在初次启动或 lazy 同步时是正常的
end
