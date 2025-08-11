    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local asst = require("logs.asst")
local enms = require("logs.enms")

    -- cartridges
local ctdg = {}
ctdg.scores = {
    common = 0,
    slowdeath = 0,
    tiny = 0
}
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
                    s.data.y + math.random(s.data.h),
                    math.random(10, 20),
                    math.random(1, 4) / 10
                ))
            end
        end,
        function(s)
            s:insertObject(enms.uniaim(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(4, 6) / 10
            ))
        end
    }

    return {
        name = "common",
        difficulty = 5,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 4)
            end,
            4
        ),
        influence = function() end
    }
end
function ctdg.ctdg.slowdeath()
    local i = 1
    local behavior = {
        function(s)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(20, 30),
                math.random(15, 25) / 10
            ))
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(20, 30),
                math.random(15, 25) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(18, 26),
                math.random(15, 25) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(45, 50),
                math.random(25, 35) / 10
            ))
            s:insertObject(enms.uniaim(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(15, 20) / 10
            ))
        end,
    }

    return {
        name = "slowdeath",
        difficulty = 6,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 3)
            end,
            4
        ),
        influence = function(g)
            g.background_color = {0.025, 0.025, 0.05}
            g.twarzship.stats.max_health = 125
            g.twarzship.stats.health = 125
            g.twarzship.space.vel = 1.5
            g.twarzship.shooting.bullet_velocity = 2
            g.twarzship.colors.idle = asst.clrs.bley
        end
    }
end
function ctdg.ctdg.tiny()
    local i = 1
    local behavior = {
        function(s)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(20, 30),
                math.random(5, 15) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(8, 12),
                math.random(15, 20) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(30, 40),
                math.random(5, 15) / 10
            ))
            s:insertObject(enms.unispin(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(20, 30),
                math.random(5, 15) / 10
            ))
        end,
        function(s)
            s:insertObject(enms.uniaim(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(10, 15) / 10
            ))
            s:insertObject(enms.uniaim(
                s.data.x + math.random(s.data.w),
                s.data.y + math.random(s.data.h),
                math.random(10, 15) / 10
            ))
        end
    }

    return {
        name = "tiny",
        difficulty = 9,
        manager = enms.manager(
            function(s)
                behavior[i](s)
                i = utls.circular(i + 1, 4)
            end,
            6
        ),
        influence = function(g)
            g.background_color = {0.075, 0.05, 0.025}
            g.twarzship.stats.max_health = 50
            g.twarzship.stats.health = 50

            g.twarzship.stats.max_shield = 50
            g.twarzship.stats.shield = 50

            g.twarzship.space.vel = 3.5
            g.twarzship.space.r = 6

            g.twarzship.shooting.bullet_delay = 0.125*2
            g.twarzship.shooting.bullet_damage = 0.125/4

            g.twarzship.colors.idle = asst.clrs.orange
        end
    }
end

function ctdg.getCartridges()
    return {
        "common",
        "slowdeath",
        "tiny"
    }
end

function ctdg.getScores(self)
    return self.scores
end
function ctdg.setScore(self, cartridge, score)
    self.scores[cartridge] = score
end

return ctdg