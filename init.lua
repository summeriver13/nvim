-- # init.nvim

-- ## core

require("core.options")
require("core.keymaps")

-- ## kits

require("kits.plugin-manager") -- plugin manager  插件管理器

require("kits.theme.tokyonight") -- theme 主题 
require("kits.line") -- line 状态栏
require("kits.buffer") -- buffer 标签栏
require("kits.tree") -- tree 文件树

require("kits.lsp") -- lsp 语言服务协议
require("kits.cmp") -- cmp 代码补全
require("kits.comment") -- comment 注释
require("kits.autopair") -- autopair 括号匹配

require("kits.file-search") -- file search 文件搜索

