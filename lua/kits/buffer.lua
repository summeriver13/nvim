-- # kits/buffer.lua

-- - bufferline.nvim 缓冲区（文件标签栏）

-- ## bufferline.nvim

-- [usage](https://github.com/eggtoopain/Neovim-Configuration-Tutorial/blob/lazy/%E5%AE%8C%E6%95%B4%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%A0%81/nvim/lua/plugins/bufferline.lua)

vim.opt.termguicolors = true

require("bufferline").setup {
    options = {
        -- 使用 nvim 内置lsp
        diagnostics = "nvim_lsp",
        -- 左侧让出 nvim-tree 的位置
        offsets = {{
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left"
        }}
    }
}
