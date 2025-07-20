    -- tools
local love = require("love")

    -- enemies
local enms = {}

function enms.bullet(ix, iy, vx, vy)
    local bullet = {
        x = ix,
        y = iy,
        vx = vx,
        vy = vy,
        r = 8,
        damage = 2,
        life = 3,
        state = "idle"
    }

    function bullet.update(self)
        self.x = self.x + self.vx
        self.y = self.y + self.vy
        self.life = self.life - love.timer.getAverageDelta()

        if self.life <= 0 then
            return false
        end

        return true
    end

    function bullet.draw(self)
        love.graphics.setColor(0.8, 0.1, 0.1, self.life)
        love.graphics.circle("fill", self.x, self.y, self.r)
    end

    return bullet
end
function enms.polyshooter(x, y, bullets, delay)
    local polyshooter = {
        x = x,
        y = y,
        r = 40,
        state = "idle",

        life = 10,
        hurtable = true,
        damage = 8,

        delay = delay,
        timer = delay,
        bullets = {
            amount = bullets,
            vel = 4
        }
    }

    function polyshooter.update(self, S)
        self.timer = self.timer - love.timer.getAverageDelta()
        self.life = self.life - love.timer.getAverageDelta()

        if self.timer <= 0 then
            for i = 0, (2 * math.pi), (2 * math.pi) / self.bullets.amount do
                self.timer = self.delay
                S:insertObject(
                    enms.bullet(
                        self.x,
                        self.y,
                        math.cos(i) * self.bullets.vel,
                        math.sin(i) * self.bullets.vel
                    )
                )
            end
        end

        if self.life <= 0 then
            return false
        end

        return true
    end
    function polyshooter.draw(self)
        love.graphics.setColor(
            self.state == "hurt"
            and {1, 1, 1, self.life}
            or {0.8, 0.1, 0.1, self.life}
        )
        love.graphics.setLineWidth(10)
        love.graphics.circle("line", self.x, self.y, self.r)
    end

    return polyshooter
end

--[[ function enms.common_pointer(x, y, delay, shots, damage)
    return {
        x = x,
        y = y,
        r = 48,
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
            love.graphics.circle("line", self.x, self.y, self.r)
            love.graphics.setColor(1, 1, 1)
        end
    }
end ]]

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