-- main.lua for development mode

local fennel = require("lib.fennel").install({ correlate = true })

package.loaded["fennel-modules"] = {}

debug.traceback = fennel.traceback

fennel.path = "src/?.fnl;?.fnl"
fennel["macro-path"] = "src/dev/?.fnlm"

table.insert(package.loaders, function(name)
    local loader, extra = fennel.searcher(name)
    if type(loader) == "function" then
        package.loaded["fennel-modules"][name] = true
    end
    return loader, extra
end)

require("src.main")
