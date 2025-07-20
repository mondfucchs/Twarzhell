    -- tools
local love = require("love")
local utls = require("tools.utils")

    -- Classes
local clss = {}

function clss.newSpace()
    local space = {
        -- Actual enemies, bosses and projectiles.
        objects = {},
        -- Twarzship's projectiles
        bullets = {},
        -- Not tangible structures that define the space's current behavior.
        managers = {},
        -- General information about the entire space itself
        data = {
            w = 500,
            h = 500,
            x = 0,
            y = 100 --magic numbers go brrr
        }
    }

    -- Gets space's objects
    function space.getObjects(self)
        return self.objects
    end
    -- Sets space's objects to ```objects```
    function space.setObjects(self, objects)
        self.objects = utls.copyTable(objects)
    end

    -- Gets space's managers
    function space.getManagers(self)
        return self.managers
    end
    -- Sets space's managers
    function space.setManagers(self, managers)
        self.managers = utls.copyTable(managers)
    end


    function space.insertObject(self, enms_declaration)
        table.insert(self.objects, enms_declaration)
    end
    function space.removeObject(self, enms_declaration)
        local is_present, index = utls.searchTable(self.objects, enms_declaration)
        if is_present then
            table.remove(self.objects, index)
        end
    end


    function space.insertManager(self, enms_declaration)
        table.insert(self.managers, enms_declaration)
    end
    function space.removeManager(self, enms_declaration)
        local is_present, index = utls.searchTable(self.managers, enms_declaration)
        if is_present then
            table.remove(self.managers, index)
        end
    end


    function space.insertBullet(self, clss_declaration)
        table.insert(self.bullets, clss_declaration)
    end


    function space.clear(self)
        self.objects = {}
        self.managers = {}
    end

    local function checkShoot(obj, bullets)
        if obj.hurtable then
            for _, bullet in pairs(bullets) do
                if utls.getDistanceBetweenPoints(obj.x, obj.y, bullet.x, bullet.y) < obj.r + bullet.r then
                    obj.life = obj.life - bullet.damage
                    obj.state = "hurt"
                end
            end
        end
    end
    function space.update(self, behavior)
        for i, manager in pairs(self.managers) do
            if not manager:update(self) then
                table.remove(self.managers, i)
            end
        end

        for i, object in pairs(self.objects) do
            object.state = "idle"
            if not object:update(self) then
                table.remove(self.objects, i)
            end

            checkShoot(object, self.bullets)
            behavior(object, i)
        end

        for i, bullet in pairs(self.bullets) do
            if not bullet:update(self) then
                table.remove(self.bullets, i)
            end
        end
    end
    function space.draw(self)
        for _, object in pairs(self.objects) do
            object:draw()
        end
        for _, bullet in pairs(self.bullets) do
            bullet:draw()
        end
    end

    return space
end
function clss.newBullet(x, y, vx, vy, dmg)
    local bullet = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        r = 8,
        damage = dmg,
        life = 2,
    }

    function bullet.update(self)
        self.x = self.x + vx
        self.y = self.y + vy
        self.life = self.life - love.timer.getAverageDelta()

        if self.life <= 0 then
            return false
        end
        return true
    end

    function bullet.draw(self)
        love.graphics.setColor(0.4, 0.4, 0.4, self.life / 2)
        love.graphics.setLineWidth(4)
        love.graphics.circle("line", self.x, self.y, self.r)
        love.graphics.setColor(1, 1, 1)
    end

    return bullet
end
function clss.newTwarzship(s, ix, iy)
    local twarzship = {
        state = "idle", -- "idle"|"hurt"|"dead"

        s = s,

        -- Related to movement and localization
        space = {
            x = ix,
            y = iy,
            r = 16,

            vel_x = 0,
            vel_y = 0,
            vel_max = 8,

            acc = 0.5,
            dcc = 0.25,
        },

        stats = {
            max_health = 100,
            max_shield = 50,
            health = 100,
            shield = 50,
        },

        shooting = {
            bullet_damage = 1/8,
            bullet_delay = 1/8,
            bullet_timer = 0,
            bullet_velocity = 8,
        },

        colors = {
            idle = {0.5, 0.5, 0.75},
            hurt = {1, 1, 1},
            dead = {0.2, 0.2, 0.25}
        },
    }

    function twarzship.move(self)
        self.space.x = utls.limit(
            self.space.x + self.space.vel_x,
            self.s.data.x,
            self.s.data.x + self.s.data.w
        )
        self.space.y = utls.limit(
            self.space.y + self.space.vel_y,
            self.s.data.y,
            self.s.data.y + self.s.data.h
        )
    end
    function twarzship.processMovement(self)
        -- Checking keys
        local movement = {x = 0, y = 0}
        if love.keyboard.isDown("a") then
            movement.x = -1
        end
        if love.keyboard.isDown("d") then
            movement.x = 1
        end
        if love.keyboard.isDown("w") then
            movement.y = -1
        end
        if love.keyboard.isDown("s") then
            movement.y = 1
        end

        -- Accelerating
        self.space.vel_x = utls.limit(
            self.space.vel_x + movement.x * self.space.acc,
            -self.space.vel_max,
            self.space.vel_max
        )
        self.space.vel_y = utls.limit(
            self.space.vel_y + movement.y * self.space.acc,
            -self.space.vel_max,
            self.space.vel_max
        )

        -- Deaccelerating
        if movement.x == 0 then
            self.space.vel_x = utls.getSign(self.space.vel_x) * utls.limit(
                math.abs(self.space.vel_x) - self.space.dcc,
                0
            )
        end
        if movement.y == 0 then
            self.space.vel_y = utls.getSign(self.space.vel_y) * utls.limit(
                math.abs(self.space.vel_y) - self.space.dcc,
                0
            )
        end

        self:move()
    end

    function twarzship.shot(self, mode)
        s:insertBullet(
            clss.newBullet(
                self.space.x,
                self.space.y,
                0,
                self.shooting.bullet_velocity * mode,
                self.shooting.bullet_damage
            )
        )
    end
    function twarzship.processShooting(self)
        if love.keyboard.isDown("k") and self.shooting.bullet_timer <= 0 then
            self:shot(-1)
            self.shooting.bullet_timer = self.shooting.bullet_delay
        elseif love.keyboard.isDown("l") and self.shooting.bullet_timer <= 0 then
            self:shot(1)
            self.shooting.bullet_timer = self.shooting.bullet_delay
        end

        self.shooting.bullet_timer = self.shooting.bullet_timer - love.timer.getAverageDelta()
    end

    function twarzship.update(self)
        self.state = "idle"
        if self.stats.health <= 0 then
            self.state = "dead"
            return true
        end

        self:processMovement()
        self:processShooting()
    end
    function twarzship.draw(self)
        love.graphics.setColor(self.colors[self.state])
        love.graphics.setLineWidth(
            self.state == "dead"
            and 4
            or  8
        )
        love.graphics.circle("line", self.space.x, self.space.y, self.space.r)
    end

    function twarzship.interactWithObject(self, obj)
        if utls.getDistanceBetweenPoints(self.space.x, self.space.y, obj.x, obj.y) <= self.space.r + obj.r then
            twarzship.state = "hurt"
            twarzship.stats.health = twarzship.stats.health - obj.damage
        end
    end
    function twarzship.clear(self)
        self.space = {
            x = ix,
            y = iy,
            r = 16,

            vel_x = 0,
            vel_y = 0,
            vel_max = 8,

            acc = 0.5,
            dcc = 0.1,
        }

        self.stats.state = "idle"
        self.stats.health = self.stats.max_health
        self.stats.shield = self.stats.max_shield
    end

    return twarzship
end

return clss