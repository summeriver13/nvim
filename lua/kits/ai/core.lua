-- lua/kits/ai/core.lua
local M = {}

-- 存储所有注册的 AI 响应处理器
M.handlers = {}

--- 统一处理 AI 响应的回调注册
--- @param plugin_name string 插件名称 (如 'snacks', 'peek')
--- @param callback function 响应后执行的操作
M.register_handler = function(plugin_name, callback)
    M.handlers[plugin_name] = callback
    -- 简体中文注释：这里提供一个占位符，防止调用时 nil 崩溃
    -- 以后可以将 Avante 的真实 Hook 挂载在这里
end

--- 统一触发 AI 响应
--- @param data table AI 返回的数据对象
M.on_response = function(data)
    if M.handlers then
        for name, cb in pairs(M.handlers) do
            local status, err = pcall(cb, data)
            if not status then
                vim.notify(string.format("[%s] AI 联动失败: %s", name, err), vim.log.levels.ERROR)
            end
        end
    end
end

--- 统一触发 AI 建议 (可选)
M.on_suggestion = function(suggestion)
    -- 类似 on_response 的逻辑
end

return M
