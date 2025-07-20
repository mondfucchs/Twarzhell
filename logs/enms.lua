    -- tools
local love = require("love")

    -- THIS SHOULD OR SHOULD NOT HAVE ACCESS TO THE FUCKING INSTANCES TABLE?
    -- > recompose
    -- It shouldn't. The instances table is part of the main.lua. However, how am I supposed
    -- to add new instances to that table with spawners and managers, for example?
    -- WOAHHH. What if the instances table IS a class by itself and then .add() or .delete()
    -- methods are runned in it??
    -- WOAHHHHHHHHHHHHHHHH

    -- helpers
local function getVectorBetweenPoints(x1, y1, x2, y2)
    local vec_x, vec_y = x1 - x2, y1 - y2
    local vec_length = math.sqrt(vec_x^2 + vec_y^2)

    return vec_x / vec_length, vec_y / vec_length
end

    -- enemies
local enms = {}

function enms.common_bullet(initial_x, initial_y, velocity_x, velocity_y, damage)
    return {
        x = initial_x,
        y = initial_y,
        damage = damage or 2,
        radius = 8,
        life = 2,

        update = function(self)
            self.x = self.x + velocity_x
            self.y = self.y + velocity_y

            self.life = self.life - 1/60
            if self.life <= 0 then
                return false
            end

            return true
        end,
        draw = function(self)
            love.graphics.setColor(1, 0, 0, self.life / 2)
            love.graphics.setLineWidth(4)
            love.graphics.circle("line", self.x, self.y, self.radius)
            love.graphics.setColor(1, 1, 1)
        end
    }
end

function enms.common_spawner(x, y, delay, shots, damage)
    return {
        x = x,
        y = y,
        radius = 64,
        damage = damage or 4,
        life = 16,
        shots = shots or 8,
        delay = delay,
        timer = 0,

        update = function(self, space)
            self.life = self.life - 1/60
            if self.life <= 0 then
                return false
            end

            self.timer = self.timer - 1/60
            if self.timer <= 0 then
                self.timer = self.delay

                for i = 0, 2*math.pi, 2*math.pi/self.shots do
                    space:insertObject(
                        enms.common_bullet(self.x, self.y, math.cos(i)*4, math.sin(i)*4)
                    )
                end
            end

            return true
        end,
        draw = function(self)
            love.graphics.setColor(1, 0, 0, self.life / 2)
            love.graphics.setLineWidth(10)
            love.graphics.circle("line", self.x, self.y, self.radius)
            love.graphics.setColor(1, 1, 1)
        end
    }
end

function enms.common_pointer(x, y, delay, shots, damage)
    return {
        x = x,
        y = y,
        radius = 48,
        damage = damage or 4,
        life = 10,
        shots = shots or 8,
        delay = delay,
        timer = 0,

        update = function(self, space)
            self.life = self.life - 1/60
            if self.life <= 0 then
                return false
            end

            self.timer = self.timer - 1/60
            if self.timer <= 0 then
                self.timer = self.delay

                local velx, vely = getVectorBetweenPoints(twarzship.movement.x, twarzship.movement.y, self.x, self.y)
                space:insertObject(
                    enms.common_bullet(self.x, self.y, velx*6, vely*6)
                )
            end

            return true
        end,
        draw = function(self)
            love.graphics.setColor(0.6, 0.6, 0.6, self.life / 2)
            love.graphics.setLineWidth(16)
            love.graphics.circle("line", self.x, self.y, self.radius)
            love.graphics.setColor(1, 1, 1)
        end
    }
end

function enms.manager(action, delay)
    return {
        action = action,
        delay = delay,
        timer = 0,

        update = function(self, space)
            self.timer = self.timer - 1/60

            if self.timer <= 0 then
                self.timer = self.delay

                action(space)
            end

            return true
        end,
    }
end

-- Premade managers
enms.managers = {}


return enms