    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local asst = require("logs.asst")
local enms = require("logs.enms")

    -- cartridges
local ctdg = {}
ctdg.ctdg = {}

function ctdg.ctdg.common()
    local i = 1
    local behavior = {
        function(s)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(6, 12),
                math.random(5, 15) / 10
            ))
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(6, 12),
                math.random(5, 15) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(6, 10),
                math.random(4, 10) / 10
            ))
        end,
        function(s)
            local random = math.random(2)
            if random == 1 then
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(s.data.w),
                    s.data.y + math.random(s.data.h),
                    math.random(20, 25),
                    math.random(6, 12) / 10
                ))
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(s.data.w),
                    s.data.y + math.random(s.data.h),
                    math.random(20, 25),
                    math.random(6, 12) / 10
                ))
            else
                s:insertObject(enms.unispin(
                    s.data.x + math.random(s.data.w),
                    s.data.x + math.random(s.data.h),
                    math.random(10, 20),
                    math.random(1, 4) / 10
                ))
            end
        end
    }

    return {
        difficulty = 5,
        high_score = 0,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 3)
            end,
            4
        )
    }
end
function ctdg.ctdg.spinhell()
    local i = 1
    local behavior = {
        function(s)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(8, 10),
                math.random(3, 8) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(25, 30),
                math.random(5, 10) / 10
            ))
            s:insertObject(enms.polybomb(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(25, 30),
                math.random(5, 10) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.unispin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(10, 15),
                math.random(1, 2) / 10
            ))
        end
    }

    return {
        difficulty = 7,
        high_score = 0,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 3)
            end,
            3
        )
    }
end
function ctdg.ctdg.explosive()
    local i = 1
    local behavior = {
        function(s)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(10, 14),
                math.random(5, 20) / 10
            ))
        end,
        function(s)
            for _ = 1, 3 do
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(s.data.w),
                    s.data.y + math.random(s.data.h),
                    math.random(20, 30),
                    math.random(5, 20) / 10
                ))
            end
        end,
        function(s)
            for _ = 1, 4 do
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(s.data.w),
                    s.data.y + math.random(s.data.h),
                    math.random(15, 25),
                    math.random(5, 20) / 10
                ))
            end
        end
    }

    return {
        difficulty = 8,
        high_score = 0,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 2)
            end,
            3
        )
    }
end

function ctdg.getCartridges(self)
    local cartridges = {}

    for name in pairs(self.ctdg) do
        table.insert(cartridges, name)
    end

    return cartridges
end

return ctdg