    -- tools
local love = require("love")
local utls = require("tools.utils")
    -- logs
local asst = require("logs.asst")


    -- classes
local clss = {}

function clss.game(twarzship_x, twarzship_y)
    local game = {}

    -- helpers
    local function drawHUD()
            -- box
        love.graphics.setColor(asst.clrs.grey)
        love.graphics.rectangle("fill", 0, 0, game.coords.stats_w, game.coords.stats_h)

            -- empty bars
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", 16, 16, love.graphics.getWidth()-32, 32)
        love.graphics.rectangle("fill", 16, 48, love.graphics.getWidth()-32, 24)

            -- bars
        love.graphics.setColor(asst.clrs.red)
        love.graphics.rectangle("fill", 16, 16, (love.graphics.getWidth()-32)*(game.twarzship.stats.health/game.twarzship.stats.max_health), 32)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 16, 48, (love.graphics.getWidth()-32)*(game.twarzship.stats.shield/game.twarzship.stats.max_shield), 24)

            -- bars text
        love.graphics.setColor(1, 1, 1); love.graphics.setFont(asst.fnts.lilfont_a)
        love.graphics.print(game.twarzship.stats.health, love.graphics.getWidth()/2 - asst.fnts.lilfont_a:getWidth(game.twarzship.stats.health)/2, 16)
        love.graphics.setColor(asst.clrs.red); love.graphics.setFont(asst.fnts.lilfont_a)
        love.graphics.print(game.twarzship.stats.shield, love.graphics.getWidth()/2 - asst.fnts.lilfont_a:getWidth(game.twarzship.stats.shield)/2, 45)

            -- score
        love.graphics.setColor(0.025, 0.025, 0.025)
        love.graphics.print(game.currentdata.score, 16, 70)

            -- timer
        love.graphics.print(
            math.floor(game.currentdata.timer),
            (love.graphics.getWidth() - 16) - (asst.fnts.lilfont_a:getWidth(math.floor(game.currentdata.timer))),
            70
        )
    end

    game.coords = {
        stats_w = love.graphics.getWidth(),
        stats_h = 100
    }
    game.state = "playing" -- "playing"|"dead"
    game.currentdata = {
        score = 0,
        timer = 0,
    }
    game.globaldata = {
        high_score = 0,
    }

    game.space = clss.newSpace(game)
    game.twarzship = clss.newTwarzship(game.space, twarzship_x, twarzship_y)

    function game.clear(self)
        self.twarzship:clear()
        self.space:clear()

        game.state = "playing"
        game.currentdata = {
            score = 0,
            timer = 0
        }
    end

    function game.update(self)
        if game.state == "playing" then
            game.currentdata.timer = game.currentdata.timer + love.timer.getAverageDelta()
            if self.twarzship:update() then
                if game.currentdata.score > game.globaldata.high_score then
                    game.globaldata.high_score = game.currentdata.score
                end
                game.state = "dead"
                goto dead
            end
            self.space:update(
                function(obj)
                    if (obj.init and not obj.init.isInit) or (not obj.init) then
                        self.twarzship:interactWithObject(obj)
                    end
                end)

            ::dead::
        end
    end
    function game.draw(self)
        if self.state == "playing" or self.state == "paused" then
            -- Background
            love.graphics.setColor(0.025, 0.025, 0.025)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            self.space:draw()
            self.twarzship:draw()
            drawHUD()
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(#self.space.objects, 16, 96)

        elseif self.state == "dead" then
            -- Background
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            -- Score
            love.graphics.setColor(0.5, 0.5, 0.5)
            love.graphics.print(self.globaldata.high_score, math.floor(love.graphics.getWidth()/2 - asst.fnts.lilfont_a:getWidth(self.globaldata.high_score)/2), 32)
            love.graphics.setColor(0.025, 0.025, 0.025)
            love.graphics.print(self.currentdata.score, math.floor(love.graphics.getWidth()/2 - asst.fnts.lilfont_a:getWidth(self.currentdata.score)/2), 48)

            self.twarzship:draw()
        end

        if game.state == "paused" then
            love.graphics.setColor(0.025, 0.025, 0.025, 0.5)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
            love.graphics.setColor(1, 1, 1); love.graphics.setFont(asst.fnts.lilfont_a)
            love.graphics.print("PAUSED", math.floor(love.graphics.getWidth()/2 - asst.fnts.lilfont_a:getWidth("PAUSED")/2), math.floor(love.graphics.getHeight()/2 - asst.fnts.lilfont_a:getHeight("PAUSED")/2))
        end
    end

    return game
end
function clss.newSpace(_game)
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

    local game = _game

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
        self.bullets = {}
    end

    local function checkShoot(obj, bullets)
        if obj.hurtable and ((obj.init and not obj.init.isInit) or (not obj.init)) then
            for _, bullet in pairs(bullets) do
                if utls.getDistanceBetweenPoints(obj.x, obj.y, bullet.x, bullet.y) < obj.r + bullet.r then
                    asst.snds.enemy_hurt:play()
                    obj.life = obj.life - bullet.damage
                    obj.state = "hurt"
                    game.currentdata.score = game.currentdata.score + 1
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
                if object.hurtable then
                    asst.snds.enemy_dead:stop()
                    asst.snds.enemy_dead:play()
                end
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
        love.graphics.setColor(asst.clrs.brey[1], asst.clrs.brey[2], asst.clrs.brey[3], self.life / 2)
        love.graphics.setLineWidth(4)
        love.graphics.circle("fill", self.x, self.y, self.r)
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

    function twarzship.shot(self, x, y)
        asst.snds.twarzship_shot:stop()
        asst.snds.twarzship_shot:play()
        s:insertBullet(
            clss.newBullet(
                self.space.x,
                self.space.y,
                self.shooting.bullet_velocity * x,
                self.shooting.bullet_velocity * y,
                self.shooting.bullet_damage
            )
        )
    end
    function twarzship.hit(self, damage)
        asst.snds.twarzship_hurt:play()
        if self.stats.shield > 0 then
            self.stats.shield = utls.limit(self.stats.shield - damage, 0, self.stats.max_shield)
        else
            self.stats.health = utls.limit(self.stats.health - damage, 0, self.stats.max_health)
        end
    end
    function twarzship.processShooting(self)
        local shot_dir = {x = 0, y = 0}

        if love.keyboard.isDown("delete") and self.shooting.bullet_timer <= 0 then
            shot_dir.x = -1
        elseif love.keyboard.isDown("pagedown") and self.shooting.bullet_timer <= 0 then
            shot_dir.x = 1
        end

        if love.keyboard.isDown("home") and self.shooting.bullet_timer <= 0 then
            shot_dir.y = -1
        elseif love.keyboard.isDown("end") and self.shooting.bullet_timer <= 0 then
            shot_dir.y = 1
        end

        if shot_dir.x ~= 0 or shot_dir.y ~= 0 then
            self:shot(shot_dir.x, shot_dir.y)
            self.shooting.bullet_timer = self.shooting.bullet_delay
        end

        self.shooting.bullet_timer = self.shooting.bullet_timer - love.timer.getAverageDelta()
    end

    function twarzship.update(self)
        self.state = "idle"
        if self.stats.health <= 0 then
            asst.snds.twarzship_dead:play()
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
            self:hit(obj.damage)
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