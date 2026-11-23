-- Based on https://codeberg.org/alexjgriffith/min-love2d-fennel/src/commit/3ddc2747e7eb5127203b1198916483fadbdc2e43/main.lua

-- Bootstrap the compiler.
local fennel = require("lib.fennel").install({
    correlate = true,
    moduleName = "lib.fennel"
})

-- Replace debug functions with their fennel equivelents.
debug.getInfo = fennel.getInfo
debug.traceback = fennel.traceback

-- Add a fennel searcher that works for fennel functions in Löve. This
-- is a bit tricky because it has to work in a fused environment.
local make_love_searcher = function(env)
    return function(module_name)
        local m_name = "" .. module_name
        local path = m_name:gsub("%.", "/")
        if love.filesystem.getInfo(path .. ".fnl") then
            return function(...)
                local code = love.filesystem.read(path .. ".fnl")
                return fennel.eval(code, { env = env, filename = path .. ".fnl", correlate = true }, ...)
            end, path
        elseif env == "_COMPILER" and love.filesystem.getInfo(path .. ".fnlm") then
            return function(...)
                local code = love.filesystem.read(path .. ".fnlm")
                return fennel.eval(code, { env = env, filename = path .. ".fnl", correlate = true }, ...)
            end, path
        end
    end
end

table.insert(package.loaders or package.loaders, make_love_searcher(_G))
table.insert(fennel["macro-searchers"], make_love_searcher("_COMPILER"))

math.randomseed(os.time())

function love.threaderror(thread, errorstr)
    print("Thread error!\n" .. errorstr)
    print(thread)
end

require("init")
