    -- tools
local love = require("love")
local clss = require("tools.clss")
local push = require("tools.push")
local utls = require("tools.utils")
    -- logs
local enms = require("logs.enms")
local asst = require("logs.asst")


-- values
local gameWidth = 250
local gameHeight = 300
local scale = 2
local coords = {
    ship_initial_x = gameWidth / 2,
    ship_initial_y = gameHeight / 2,
}

-- graphics configs
love.graphics.setLineStyle("rough")
love.graphics.setDefaultFilter("nearest", "nearest")

math.randomseed(os.clock())

-- structures
local game = clss.game(coords.ship_initial_x, coords.ship_initial_y, gameWidth, gameHeight)

-- löve2d callbacks
function love.load()
    push:setupScreen(
        gameWidth,
        gameHeight,
        gameWidth * scale,
        gameHeight * scale,
        {
            pixelperfect = true
        }
    )

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
    push:start()
    game:draw()
    push:finish()
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