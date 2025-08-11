    -- tools
local love = require("love")
local clss = require("tools.clss")
local push = require("tools.push")
local utls = require("tools.utils")
    -- logs
local enms = require("logs.enms")
local asst = require("logs.asst")


-- graphics settings
love.mouse.setVisible(false)

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

    game:load()
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
    if key == "kp8" then
        game.volume = utls.limit(game.volume + 0.1, 0, 1)
    elseif key == "kp2" then
        game.volume = utls.limit(game.volume - 0.1, 0, 1)
    end

    if game.state == "dead" and key == "space" then

        asst.snds.new_game:play()
        game:reset()

    elseif key == "escape" and (game.state == "paused" or game.state == "playing") then
        game.state = utls.boolToValue(game.state == "paused", "playing", "paused")
    end

    if game.state == "paused" then
        if key == "m" then
            asst.snds.twarzship_dead:play()
            game:clear()
            game.state = "menu"
        end
    end
end

function love.mousepressed()
    game:mousepressed()
end