    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local asst = require("logs.asst")

    -- enemies
local enms = {}

    -- bullets
function enms.blueprint_bullet(basedmg, life, radius, baseclr, draw, interact)

    return function(ix, iy, vx, vy, color, dmg)
        local bullet = {
            x = ix,
            y = iy,
            vx = vx,
            vy = vy,
            c = color or baseclr,
            r = radius,
            single = true,
            damage = basedmg or dmg,
            life = life,
            interact = interact,
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
            draw(self)
        end

        return bullet
    end

end

enms.bullet = enms.blueprint_bullet(
    12, 4, 4,
    asst.clrs.red,
    function(self)
        love.graphics.setColor(self.c[1], self.c[2], self.c[3], self.life)
        love.graphics.circle("fill", self.x, self.y, self.r)
    end,
    function(self, twarzship)
        twarzship:hit(self.damage)
        return false
    end
)

enms.gullet = enms.blueprint_bullet(
    12, 4, 4,
    asst.clrs.red,
    function(self)
        love.graphics.setColor(self.c[1], self.c[2], self.c[3], self.life)
        love.graphics.circle("fill", self.x, self.y, self.r + 2)
        love.graphics.setColor(1, 1, 1, self.life)
        love.graphics.circle("fill", self.x, self.y, self.r)
    end,
    function(self, twarzship)
        twarzship:heal(self.damage)
        return false
    end
)

    -- enemies
local function defaultInteraction()
    return function(self, twarzship)
        twarzship:hit(self.damage)
    end
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
        r = 25,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 20,
        hurtable = true,
        damage = 2,

        delay = delay,
        timer = delay,
        bullets = {
            amount = bullets,
            vel = 2
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
            asst.snds.enemy_shot:stop()
            asst.snds.enemy_shot:play()

            for i = 0, (2 * math.pi)-.1, (2 * math.pi) / self.bullets.amount do
                self.timer = self.delay

                local random = math.random(1, 10)
                local bullet = (random == 1) and (enms.gullet) or (enms.bullet)

                S:insertEnemyBullet(
                    bullet(
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
        love.graphics.setLineWidth(6)

        love.graphics.circle("line", self.x, self.y, self.r)
    end
    polyshooter.interact = defaultInteraction()

    return polyshooter
end
function enms.polybomb(x, y, bullets, delay)
    local polybomb = {
        x = x,
        y = y,
        r = 10,
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
            vel = 3
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

                local random = math.random(1, 10)
                local bullet = (random == 1) and (enms.gullet) or (enms.bullet)
                S:insertEnemyBullet(
                    bullet(
                        self.x,
                        self.y,
                        math.cos(i) * self.bullets.vel,
                        math.sin(i) * self.bullets.vel,
                        {240/255, 104/255, 31/255},
                        16
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
            {240/255 + utls.limit(1 - self.timer, 0),
            104/255 + utls.limit(1 - self.timer, 0),
            31/255 + utls.limit(1 - self.timer, 0), self.life}
        )
        if self.init.isInit then love.graphics.setColor{240/255, 104/255, 31/255, 0.5} end
        love.graphics.setLineWidth(5)
        love.graphics.circle("line", self.x, self.y, self.r)
        love.graphics.setLineWidth(0)
        love.graphics.circle("fill", self.x, self.y, self.r*5/10)
    end
    polybomb.interact = defaultInteraction()

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
        r = 15,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 30,
        hurtable = true,
        damage = 4,

        ltime = 0,
        delay = delay,
        timer = delay,
        bullets = {
            amount = bullets,
            vel = 1
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
            asst.snds.enemy_shot:stop()
            asst.snds.enemy_shot:play()
            for i = 0, (2 * math.pi)-.1, (2 * math.pi) / self.bullets.amount do
                self.timer = self.delay

                local random = math.random(1, 20)
                local bullet = (random == 1) and (enms.gullet) or (enms.bullet)

                S:insertEnemyBullet(
                    bullet(
                        self.x,
                        self.y,
                        math.cos(self.ltime*4 + i) * self.bullets.vel,
                        math.sin(self.ltime*4 + i) * self.bullets.vel,
                        {240/255, 160/255, 31/255},
                        8
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
        love.graphics.setLineWidth(8)
        love.graphics.circle("line", self.x, self.y, self.r)
    end
    polyspin.interact = defaultInteraction()

    return polyspin
end
function enms.unispin(x, y, divisions, delay)
    local colors = {
        idle = asst.clrs.green,
        init = {181/255, 232/255, 39/255, 0.5},
        hurt = {1, 1, 1},
    }

    local unispin = {
        x = x,
        y = y,
        r = 25,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 60,
        hurtable = true,
        damage = 2,

        ltime = 0,
        delay = delay,
        timer = delay,
        bullets = {
            current = 1,
            divisions = divisions,
            vel = 2
        },
    }

    function unispin.update(self, S)
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
            asst.snds.enemy_shot:stop()
            asst.snds.enemy_shot:play()
            self.timer = self.delay

            local random = math.random(1, 10)
            local bullet = (random == 1) and (enms.gullet) or (enms.bullet)

            S:insertEnemyBullet(
                bullet(
                    self.x,
                    self.y,
                    math.cos(self.bullets.current) * self.bullets.vel,
                    math.sin(self.bullets.current) * self.bullets.vel,
                    asst.clrs.green
                )
            )

            self.bullets.current = self.bullets.current + (2*math.pi)/self.bullets.divisions
        end

        if self.life <= 0 then
            return false
        end

        ::init::

        return true
    end
    function unispin.draw(self)
        love.graphics.setColor(colors[self.state])
        if self.init.isInit then love.graphics.setColor(colors["init"]) end
        love.graphics.setLineWidth(8)
        love.graphics.circle("line", self.x, self.y, self.r)
    end
    unispin.interact = defaultInteraction()

    return unispin
end
function enms.uniaim(x, y, delay)
    local colors = {
        idle = asst.clrs.lgreen,
        init = {asst.clrs.lgreen[1], asst.clrs.lgreen[2], asst.clrs.lgreen[3], 0.5},
        hurt = {1, 1, 1},
    }

    local uniaim = {
        x = x,
        y = y,
        r = 20,
        state = "idle",
        init = {
            isInit = true,
            timer = 2
        },

        life = 45,
        hurtable = true,
        damage = 1,

        ltime = 0,
        delay = delay,
        timer = delay,
        bullets = {
            vel = 2
        },
    }

    local dif_x = 0
    local dif_y = 0
    local hip   = 1

    function uniaim.update(self, S)
        if self.init.isInit then
            self.init.timer = self.init.timer - love.timer.getAverageDelta()
            if self.init.timer <= 0 then
                self.init.isInit = false
            end
            goto init
        end

        dif_x = S.twarzship.space.x - self.x
        dif_y = S.twarzship.space.y - self.y
        hip = math.sqrt(dif_x^2 + dif_y^2)

        self.ltime = self.ltime + 1/60
        self.timer = self.timer - love.timer.getAverageDelta()
        self.life = self.life - love.timer.getAverageDelta()

        if self.timer <= 0 then
            asst.snds.enemy_shot:stop()
            asst.snds.enemy_shot:play()
            self.timer = self.delay

            local random = math.random(1, 20)
            local bullet = (random == 1) and (enms.gullet) or (enms.bullet)

            S:insertEnemyBullet(
                bullet(
                    self.x,
                    self.y,
                    (dif_x / hip) * self.bullets.vel,
                    (dif_y / hip) * self.bullets.vel,
                    asst.clrs.lgreen,
                    8
                )
            )
        end

        if self.life <= 0 then
            return false
        end

        ::init::

        return true
    end
    function uniaim.draw(self)
        love.graphics.setColor(colors[self.state])
        if self.init.isInit then love.graphics.setColor(colors["init"]) end
        love.graphics.setLineWidth(10)
        love.graphics.circle("line", self.x, self.y, self.r)
        love.graphics.circle("fill", self.x + (dif_x / hip)*4, self.y + (dif_y / hip)*4, self.r/3)
    end
    uniaim.interact = defaultInteraction()

    return uniaim
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

return enms