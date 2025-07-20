    -- tools
local love = require("love")
local clss = require("tools.clss")
local utls = require("tools.utils")
    -- logs
local enms = require("logs.enms")


-- values
local coords = {
    ship_initial_x = love.graphics.getWidth() / 2,
    ship_initial_y = (love.graphics.getHeight() - 100) / 2,
    stats_w = love.graphics.getWidth(),
    stats_h = 100
}
local colors = {
    red = {0.8, 0.1, 0.1},
    brey = {0.5, 0.5, 0.75},
    grey = {0.5, 0.5, 0.55},
    drey = {0.2, 0.2, 0.25}
}
local game = {
    state = "playing"
}

math.randomseed(os.clock())

-- structures
local space     = clss.newSpace()
local twarzship = clss.newTwarzship(space, 250, 250)

-- löve2d callbacks
function love.load()
    space:insertManager(
        enms.manager(
            function(s)
                s:insertObject(enms.polyshooter(s.data.x + math.random(s.data.w), s.data.y + math.random(s.data.h), 8, 1))
            end,
            4
        )
    )
end

function love.update()
    if game.state == "playing" then
        if twarzship:update() then
            game.state = "dead"
            goto continue
        end
        space:update(
            function(obj)
                twarzship:interactWithObject(obj)
            end)

        ::continue::
    end
end

function love.draw()
    if game.state == "playing" then
        space:draw()
        twarzship:draw()

        -- HUD
        -- box
        love.graphics.setColor(colors.grey)
        love.graphics.rectangle("fill", 0, 0, coords.stats_w, coords.stats_h)
        love.graphics.setColor(colors.drey)
        love.graphics.rectangle("fill", 0, coords.stats_h, coords.stats_w, 8)
        -- stats
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("HP: " .. twarzship.stats.health .. " / " .. twarzship.stats.max_health, 16, 16)
        love.graphics.print("SH: " .. twarzship.stats.shield .. " / " .. twarzship.stats.max_shield, 16, 32)

    elseif game.state == "dead" then
        -- Background
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        twarzship:draw()
    end
end

function love.keypressed(key)
    if game.state == "dead" then
        space:clear()
        twarzship:clear()
        game.state = "playing"
    end
end

function love.mousepressed(x, y, mode)
end