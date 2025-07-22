    -- tools
local love = require("love")
    -- logs
local asst = require("logs.asst")

    -- enemies
local enms = {}

function enms.bullet(ix, iy, vx, vy, color)
    local bullet = {
        x = ix,
        y = iy,
        vx = vx,
        vy = vy,
        c = color or {0.8, 0.1, 0.1},
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
        love.graphics.setColor(self.c[1], self.c[2], self.c[3], self.life)
        love.graphics.circle("fill", self.x, self.y, self.r)
    end

    return bullet
end
function enms.polyshooter(x, y, bullets, delay)
    local colors = {
        idle = asst.clrs.red,
        init = {0.8, 0.1, 0.1, 0.5},
        hurt = {1, 1, 1},
    }

    local polyshooter = {
        x = x,
        y = y,
        r = 40,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 20,
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
        if self.init.isInit then
            self.init.timer = self.init.timer - love.timer.getAverageDelta()
            if self.init.timer <= 0 then
                self.init.isInit = false
            end
            goto init
        end

        self.timer = self.timer - love.timer.getAverageDelta()
        self.life = self.life - love.timer.getAverageDelta()

        if self.timer <= 0 then
            for i = 0, (2 * math.pi)-.1, (2 * math.pi) / self.bullets.amount do
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

        ::init::

        return true
    end
    function polyshooter.draw(self)
        love.graphics.setColor(colors[self.state])
        if self.init.isInit then love.graphics.setColor(colors["init"]) end
        love.graphics.setLineWidth(10)
        love.graphics.circle("line", self.x, self.y, self.r)
    end

    return polyshooter
end
function enms.polybomb(x, y, bullets, delay)
    local polybomb = {
        x = x,
        y = y,
        r = 20,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 20,
        damage = 2,

        delay = delay,
        timer = delay,
        bullets = {
            amount = bullets,
            vel = 6
        }
    }

    function polybomb.update(self, S)
        if self.init.isInit then
            self.init.timer = self.init.timer - love.timer.getAverageDelta()
            if self.init.timer <= 0 then
                self.init.isInit = false
            end
            goto init
        end

        self.timer = self.timer - love.timer.getAverageDelta()

        if self.timer <= 0 then
            asst.snds.explosion:stop()
            asst.snds.explosion:play()
            for i = 0, (2 * math.pi)-.1, (2 * math.pi) / self.bullets.amount do
                self.timer = self.delay
                S:insertObject(
                    enms.bullet(
                        self.x,
                        self.y,
                        math.cos(i) * self.bullets.vel,
                        math.sin(i) * self.bullets.vel,
                        {240/255, 104/255, 31/255}
                    )
                )
            end
            return false
        end

        if self.life <= 0 then
            return false
        end

        ::init::

        return true
    end
    function polybomb.draw(self)
        love.graphics.setColor(
            {240/255 + (1 - self.timer),
            104/255 + (1 - self.timer),
            31/255 + (1 - self.timer), self.life}
        )
        if self.init.isInit then love.graphics.setColor{240/255, 104/255, 31/255, 0.5} end
        love.graphics.setLineWidth(10)
        love.graphics.circle("line", self.x, self.y, self.r)
    end

    return polybomb
end
function enms.polyspin(x, y, bullets, delay)
    local colors = {
        idle = asst.clrs.orange,
        init = {240/255, 160/255, 31/255, 0.5},
        hurt = {1, 1, 1},
    }

    local polyspin = {
        x = x,
        y = y,
        r = 30,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 30,
        hurtable = true,
        damage = 2,

        ltime = 0,
        delay = delay,
        timer = delay,
        bullets = {
            amount = bullets,
            vel = 2
        },
    }

    function polyspin.update(self, S)
        if self.init.isInit then
            self.init.timer = self.init.timer - love.timer.getAverageDelta()
            if self.init.timer <= 0 then
                self.init.isInit = false
            end
            goto init
        end

        self.ltime = self.ltime + 1/60
        self.timer = self.timer - love.timer.getAverageDelta()
        self.life = self.life - love.timer.getAverageDelta()

        if self.timer <= 0 then
            for i = 0, (2 * math.pi)-.1, (2 * math.pi) / self.bullets.amount do
                self.timer = self.delay
                S:insertObject(
                    enms.bullet(
                        self.x,
                        self.y,
                        math.cos(self.ltime*4 + i) * self.bullets.vel,
                        math.sin(self.ltime*4 + i) * self.bullets.vel,
                        {240/255, 160/255, 31/255}
                    )
                )
            end
        end

        if self.life <= 0 then
            return false
        end

        ::init::

        return true
    end
    function polyspin.draw(self)
        love.graphics.setColor(colors[self.state])
        if self.init.isInit then love.graphics.setColor(colors["init"]) end
        love.graphics.setLineWidth(10)
        love.graphics.circle("line", self.x, self.y, self.r)
    end

    return polyspin
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