-- luacheck 配置文件 - Neovim AI 增强配置
-- 针对 Neovim Lua 环境的特殊配置

-- 全局变量配置
globals = {
    -- Neovim 核心 API
    "vim",
    -- Lua 标准库
    "assert", "collectgarbage", "dofile", "error", "getmetatable", "ipairs",
    "load", "loadfile", "next", "pairs", "pcall", "print", "rawequal",
    "rawget", "rawlen", "rawset", "select", "setmetatable", "tonumber",
    "tostring", "type", "xpcall",
    -- 模块系统
    "require", "package",
    -- 操作系统相关
    "io", "os", "string", "table", "math", "debug",
    -- Coroutine
    "coroutine",
    -- UTF-8 支持
    "utf8",
}

-- Neovim 特定全局变量
std = "lua54+lua_neovim"

-- 文件类型配置
files = {
    include = {"*.lua", "lua/**/*.lua"},
    exclude = {"test/**/*.lua", "spec/**/*.lua"}
}

-- 检查选项
unused = true
unused_args = false  -- 有时函数参数用于接口兼容性
redefined = false    -- 允许重定义（模块模式常见）
unused_secondaries = false

-- 忽略的警告
ignore = {
    "211",  -- 未使用的参数（用于回调函数）
    "212",  -- 未使用的参数（用于接口）
    "213",  -- 未使用的参数（用于 ... 可变参数）
    "611",  -- 行太长
    "612",  -- 行太长
    "621",  -- 代码行太长
    "631",  -- 行太长
}

-- 模块特定配置
-- 对于 kits/ai/ 目录，允许特定的全局变量
for filename, config in pairs({
    ["lua/kits/ai/avante.lua"] = {
        globals = {"avante"}
    },
    ["lua/kits/ai/copilot.lua"] = {
        globals = {"copilot"}
    },
    ["lua/kits/ai/noice.lua"] = {
        globals = {"noice"}
    },
    ["lua/kits/ai/snacks.lua"] = {
        globals = {"snacks"}
    },
    ["lua/kits/ai/peek.lua"] = {
        globals = {"peek"}
    },
}) do
    files[filename] = config
end

-- 最大行长度
max_line_length = 100

-- 允许的空格
allow_empty_if = false