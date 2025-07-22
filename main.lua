    -- tools
local love = require("love")
local clss = require("tools.clss")
local utls = require("tools.utils")
    -- logs
local enms = require("logs.enms")
local asst = require("logs.asst")


-- values
local coords = {
    ship_initial_x = love.graphics.getWidth() / 2,
    ship_initial_y = (love.graphics.getHeight() - 100) / 2,
}

math.randomseed(os.clock())

-- structures
local game = clss.game(coords.ship_initial_x, coords.ship_initial_y)

-- löve2d callbacks
function love.load()
    local i = 1
    game.space:insertManager(
        enms.manager(
            function(s)
                if i == 1 then
                    s:insertObject(
                        enms.polyshooter(
                            s.data.x + math.random(s.data.w),
                            s.data.y + math.random(s.data.h),
                            math.random(6, 12),
                            1
                        )
                    )
                    s:insertObject(
                        enms.polyshooter(
                            s.data.x + math.random(s.data.w),
                            s.data.y + math.random(s.data.h),
                            math.random(6, 12),
                            1
                        )
                    )
                elseif i == 2 then
                    s:insertObject(
                        enms.polybomb(
                            s.data.x + math.random(s.data.w),
                            s.data.y + math.random(s.data.h),
                            36,
                            1
                        )
                    )
                elseif i == 3 then
                    s:insertObject(
                        enms.polyspin(
                            s.data.x + math.random(s.data.w),
                            s.data.y + math.random(s.data.h),
                            math.random(8, 10),
                            0.5
                        )
                    )
                end
                i = utls.circular(i + 1, 3)
            end,
            4
        )
    )
end

function love.update()
    game:update()
end

function love.draw()
    game:draw()
end

function love.keypressed(key)
    if game.state == "dead" then
        asst.snds.new_game:play()
        asst.snds.new_game:play()
        game:clear()
    elseif key == "escape" then
        game.state = utls.boolToValue(game.state == "paused", "playing", "paused")
    end
end