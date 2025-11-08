    -- tools
local clss = require("tools.clss")
local utls = require("tools.utils")
local save = require("tools.save")
    -- libraries
local push = require("libraries.push")
    -- logs
local enms = require("logs.enms")
local ctdg = require("logs.ctdg")
local asst = require("logs.asst")


-- graphics settings
love.mouse.setVisible(false)

-- values
deltaTime = 0

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

    save.load()
end

function love.update(dt)
    deltaTime = dt
    game:update()
end

function love.draw()
    push:start()
    game:draw()
    push:finish()
end

function love.keypressed(key)

    game:keypressed(key)

    if game.state == "dead" and key == "space" then

        asst.snds.new_game:play()
        game:reset()

    elseif key == "escape" and (game.state == "paused" or game.state == "playing") then
        game.state = utls.boolToValue(game.state == "paused", "playing", "paused")
    end

end

function love.mousepressed()
    game:mousepressed()
end