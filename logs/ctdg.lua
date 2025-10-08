    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local asst = require("logs.asst")
local enms = require("logs.enms")

-- ctdg.lua: cartridges's information --
local ctdg = {}

-- cartridges' hiscore and hitime --

ctdg.scores = {
    common = 0,
    slowdeath = 0,
    hordes = 0,
    tiny = 0
}
ctdg.times = {
    common = 0,
    slowdeath = 0,
    hordes = 0,
    tiny = 0
}

-- cartridges' behavior and data --

ctdg.ctdg = {}

-- (helper) allows enemies to be spawned in a part of the screen, instead of all across it
local screen_areas = {
    { x = 0  , y = 0  , w = 250, h = 125 },
    { x = 0  , y = 125, w = 250, h = 250 },
    { x = 0  , y = 0  , w = 125, h = 250 },
    { x = 125, y = 0  , w = 250, h = 250 },
}

-- (helper) returns a manager with basic behavior and screen area system.
local function basicBehaviorManager(behavior_table, delay)

    local behavior       = behavior_table
    local behavior_index = 1
    local behavior_cycle = #behavior_table

    local area_index = 0 -- (starts at zero because will always be incremented on first function call)
    local area_cycle = #screen_areas

    return enms.manager(
        function(space)

            -- If all enemies were defeated, now area should be changed
            if (#space:getObjects() == 0) then
                area_index = utls.circular(area_index + 1, area_cycle)
            end

            -- Calling behavior for current index
            behavior[behavior_index](space, screen_areas[area_index])
            -- Incrementing behavior_index cyclically
            behavior_index = utls.circular(behavior_index + 1, behavior_cycle)

        end,
        delay
    )

end

function ctdg.ctdg.TROLLBERG()
    local behavior = {
        function(s, area)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(6, 12),
                math.random(5, 15) / 10
            ))
        end,
    }
    return {

        name        = "TROLLBERG",
        desc        = "Hilda's city",
        difficulty  = 5,

        manager = basicBehaviorManager(behavior, 4),
        influence = function() end

    }
end
function ctdg.ctdg.common()
    local behavior = {
        function(s, area)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(6, 12),
                math.random(5, 15) / 10
            ))
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(6, 12),
                math.random(5, 15) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(8, 10),
                math.random(10, 15) / 10
            ))
        end,
        function(s, area)
            local picked_behavior = math.random(2)
            if picked_behavior == 1 then
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(15, 20),
                    math.random(8, 12) / 10
                ))
                s:insertObject(enms.polybomb(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(15, 20),
                    math.random(8, 12) / 10
                ))
            else
                s:insertObject(enms.unispin(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(10, 20),
                    math.random(1, 4) / 10
                ))
            end
        end,
        function(s, area)
            s:insertObject(enms.uniaim(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(4, 6) / 10
            ))
        end
    }
    return {

        name        = "common",
        desc        = "Intervals of five seconds, simplest mode.",
        difficulty  = 7,

        manager = basicBehaviorManager(behavior, 4),
        influence = function() end

    }
end
function ctdg.ctdg.slowdeath()
    local behavior = {
        function(s, area)
            for i = 1, math.random(2, 4) do

                s:insertObject(enms.polyshooter(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(16, 22),
                    math.random(15, 20) / 10,
                    { bullet_vel = 1 }
                ))

            end

        end,
        function(s, area)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(20, 25),
                math.random(30, 35) / 10,
                { bullet_vel = 1.5 }
            ))
        end,
        function(s, area)
            local random_behavior = math.random()

            if (random_behavior <= 0.5) then
                s:insertObject(enms.polyspin(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(16, 22),
                    math.random(10, 15) / 10,
                    { bullet_vel = 1 }
                ))
            else
                s:insertObject(enms.uniaim(
                    s.data.x + math.random(area.x, area.w),
                    s.data.y + math.random(area.y, area.h),
                    math.random(5, 7) / 10,
                    { bullet_vel = 1 }
                ))
            end
        end,
    }
    return {

        name        = "slowdeath",
        desc        = "Slower enemies and more bullets.",
        difficulty  = 6,

        manager = basicBehaviorManager(behavior, 4),
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
function ctdg.ctdg.hordes()
    local area_index = 1
    local objects = {
        function(s, area)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(10, 20),
                math.random(8, 12) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(10, 20),
                math.random(8, 12) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(10, 12),
                math.random(6, 10) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(15, 20),
                math.random(10, 15) / 10
            ))
        end,
        function (s, area)
            s:insertObject(enms.unispin(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(20, 25),
                math.random(1, 4) / 10
            ))
        end
    }
    return {

        name        = "hordes",
        desc        = "Large intervals, several enemies appear at once.",
        difficulty  = 9,

        manager = enms.manager(
            function(s)

                -- If all enemies were defeated, now area should be changed
                if (#s:getObjects() == 0) then
                    area_index = utls.circular(area_index + 1, #screen_areas)
                end

                for _ = 1, 5, 1 do
                    local object_index = math.random(#objects)
                    objects[object_index](s, screen_areas[area_index])
                end

            end,
            10
        ),
        influence = function(g)
            g.background_color = {0.005, 0.005, 0.0075}

            g.twarzship.stats.max_shield = 100
            g.twarzship.stats.shield = 100

            g.twarzship.space.r = 7

            g.twarzship.space.vel = 2
            g.twarzship.shooting.bullet_delay = 0.125/2
            g.twarzship.shooting.bullet_damage = 0.125

            g.twarzship.colors.idle = asst.clrs.drey
        end

    }
end
function ctdg.ctdg.tiny()
    local behavior = {
        function(s, area)
            s:insertObject(enms.polyshooter(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(15, 20),
                math.random(10, 20) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polyspin(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(8, 12),
                math.random(15, 20) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.polybomb(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(15, 20),
                math.random(15, 25) / 10
            ))
            s:insertObject(enms.unispin(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(20, 30),
                math.random(5, 7) / 10
            ))
        end,
        function(s, area)
            s:insertObject(enms.uniaim(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(10, 15) / 10
            ))
            s:insertObject(enms.uniaim(
                s.data.x + math.random(area.x, area.w),
                s.data.y + math.random(area.y, area.h),
                math.random(10, 15) / 10
            ))
        end
    }
    return {

        name = "tiny",
        desc = "Ship has way less damage, health, and shield.",
        difficulty = 8,

        manager = basicBehaviorManager(behavior, 6),
        influence = function(g)
            g.background_color = {0.075, 0.05, 0.025}
            g.twarzship.stats.max_health = 50
            g.twarzship.stats.health = 50

            g.twarzship.stats.max_shield = 50
            g.twarzship.stats.shield = 50

            g.twarzship.space.vel = 2.8
            g.twarzship.space.r = 6

            g.twarzship.shooting.bullet_delay = 0.125
            g.twarzship.shooting.bullet_damage = 0.125/2

            g.twarzship.colors.idle = asst.clrs.orange
        end

    }
end

function ctdg.getCartridges()
    return {
        "TROLLBERG",
        "common",
        "slowdeath",
        "hordes",
        "tiny",
    }
end

function ctdg.getScores(self)
    return self.scores
end
function ctdg.setScore(self, cartridge, score)
    self.scores[cartridge] = score
end

function ctdg.getTimes(self)
    return self.times
end
function ctdg.setTimes(self, cartridge, time)
    self.times[cartridge] = math.floor(time)
end

return ctdg