    -- tools
local ctdg = require("logs.ctdg")

local asst = require("logs.asst")

    -- saving funcs
local save = {}

local function invertBytes(str)

    local out = ""

    for i = 1, #str do
        local b = str:byte(i)
        out = out .. string.char(255 - b) -- bitwise NOT for a single byte
    end

    return out

end

function save.save()

    local savefile = love.filesystem.newFile("savefile.txt")

    savefile:open("w")
    for _, value in pairs(ctdg.getCartridges()) do
        savefile:write(invertBytes(value .. ":" .. ctdg:getScores()[value] .. ":" .. ctdg:getTimes()[value]))
    end

    savefile:close()

end
function save.load()

    -- If game wasn't ever saved before, do not load anything and save the base scores and times.
    if not love.filesystem.getInfo("savefile.txt") then

        save.save()
        return

    end

    -- If there is a savefile, then everything's OK.
    local content = love.filesystem.read("savefile.txt")

    if content then

        content = invertBytes(content)

        for _, value in pairs(ctdg.getCartridges()) do
            ctdg.scores[value], ctdg.times[value] = content:match(value .. ":" .. "(%d+):(%d+)")
            ctdg.scores[value] = tonumber(ctdg.scores[value]) or 0
            ctdg.times[value] = tonumber(ctdg.times[value]) or 0
        end

    end

end

return save