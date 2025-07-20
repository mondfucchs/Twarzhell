    -- tools
local love = require("love")
local inst = require("tools.inst")
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

-- structures
twarzship = {
    colors = {
        idle = colors.brey,
        hurt = colors.red,
    },
    stats = {
        max_hp = 100,
        max_df = 100,
        hp = 100,
        df = 0,
    },
    movement = {
        x = love.graphics.getWidth() / 2,
        y = coords.stats_h + (love.graphics.getHeight() - coords.stats_h) / 2,
        velocity_x = 0,
        velocity_y = 0,
        acceleration_x = 16/30,
        acceleration_y = 16/30,
        deceleration_x = 16/90,
        deceleration_y = 16/90,
        max_velocity_x = 8,
        max_velocity_y = 8,
        radius = 16,
    }
}
local space = inst.newSpace()

-- helpers
local function getDistanceBetweenPoints(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
end
local function getVectorBetweenPoints(x1, y1, x2, y2)
    local vec_x, vec_y = x1 - x2, y1 - y2
    local vec_length = math.sqrt(vec_x^2 + vec_y^2)

    return vec_x / vec_length, vec_y / vec_length
end

-- löve2d callbacks
function love.load()
    space:insertManager(
        enms.manager(
            function(s)
                s:insertObject(
                    enms.common_spawner(math.random(1, 500), 100 + math.random(1, 500), 2)
                )
                s:insertObject(
                    enms.common_pointer(math.random(1, 500), 100 + math.random(1, 500), 1)
                )
            end,
            8
        )
    )
end

function love.update()
    if game.state == "playing" then
        if twarzship.stats.hp <= 0 then
            game.state = "dead"
        end

        --#region Twarzship moving
        twarzship.movement.x = twarzship.movement.x + twarzship.movement.velocity_x
        twarzship.movement.y = twarzship.movement.y + twarzship.movement.velocity_y

        local ship_movement = {x = 0, y = 0}
        if love.keyboard.isDown("delete") then
            ship_movement.x = -1
        end
        if love.keyboard.isDown("pagedown") then
            ship_movement.x = 1
        end
        if love.keyboard.isDown("home") then
            ship_movement.y = -1
        end
        if love.keyboard.isDown("end") then
            ship_movement.y = 1
        end

        if ship_movement.x == 0 then
            twarzship.movement.velocity_x = utls.getSign(twarzship.movement.velocity_x) * utls.limit(
                math.abs(twarzship.movement.velocity_x) - twarzship.movement.deceleration_x,
                0,
                twarzship.movement.max_velocity_x
            )
        end
        if ship_movement.y == 0 then
            twarzship.movement.velocity_y = utls.getSign(twarzship.movement.velocity_y) * utls.limit(
                math.abs(twarzship.movement.velocity_y) - twarzship.movement.deceleration_y,
                0,
                twarzship.movement.max_velocity_y
            )
        end

        twarzship.movement.velocity_x = utls.limit(
            twarzship.movement.velocity_x + ship_movement.x * twarzship.movement.acceleration_x,
            -twarzship.movement.max_velocity_x,
            twarzship.movement.max_velocity_x
        )

        twarzship.movement.velocity_y = utls.limit(
            twarzship.movement.velocity_y + ship_movement.y * twarzship.movement.acceleration_y,
            -twarzship.movement.max_velocity_y,
            twarzship.movement.max_velocity_y
        )

        if twarzship.movement.x > love.graphics.getWidth() then
            twarzship.movement.x = -twarzship.movement.radius
        elseif twarzship.movement.x < -twarzship.movement.radius then
            twarzship.movement.x = love.graphics.getWidth()
        end

        if twarzship.movement.y > love.graphics.getHeight() then
            twarzship.movement.y = coords.stats_h - twarzship.movement.radius
        elseif twarzship.movement.y < coords.stats_h - twarzship.movement.radius then
            twarzship.movement.y = love.graphics.getHeight()
        end
        --#endregion
        --#region Instances
        twarzship.color = twarzship.colors.idle
        space:update(
            function(obj)
                if getDistanceBetweenPoints(twarzship.movement.x, twarzship.movement.y, obj.x, obj.y) <= twarzship.movement.radius + obj.radius then
                    twarzship.color = twarzship.colors.hurt
                    twarzship.stats.hp = twarzship.stats.hp - obj.damage
                end
            end)
        --#endregion

    end
end

function love.draw()
    if game.state == "playing" then
        -- Twarzship
        love.graphics.setColor(twarzship.color)
        love.graphics.setLineWidth(8)
        love.graphics.circle("line", twarzship.movement.x, twarzship.movement.y, twarzship.movement.radius)

        -- Stats
        -- box
        love.graphics.setColor(colors.grey)
        love.graphics.rectangle("fill", 0, 0, coords.stats_w, coords.stats_h)
        love.graphics.setColor(colors.drey)
        love.graphics.rectangle("fill", 0, coords.stats_h, coords.stats_w, 8)
        -- stats
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("HP: " .. twarzship.stats.hp .. " / " .. twarzship.stats.max_hp, 16, 16)
        love.graphics.print("DF: " .. twarzship.stats.df .. " / " .. twarzship.stats.max_df, 16, 32)

        -- Instances
        space:draw()
    elseif game.state == "dead" then
        -- Background
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

        -- Twarzship
        love.graphics.setColor(0, 0, 0)
        love.graphics.setLineWidth(2)
        love.graphics.circle("line", twarzship.movement.x, twarzship.movement.y, twarzship.movement.radius)    
    end
end

function love.keypressed(key)
    if game.state == "dead" then
        space:clear()
        twarzship.stats.hp = twarzship.stats.max_hp
        twarzship.movement.x = coords.ship_initial_x
        twarzship.movement.y = coords.ship_initial_y
        game.state = "playing"
    end
end

function love.mousepressed(x, y, mode)
end