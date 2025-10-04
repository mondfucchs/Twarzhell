    -- tools
local love = require("love")
local utls = require("tools.utils")
local save = require("tools.save")
    -- logs
local asst = require("logs.asst")
local ctdg = require("logs.ctdg")

    -- helpers
local function divideText(text, font, width)
    local divided = {}
    local current_line = ""

    -- gmatch searchs for non-space sequences;
    -- (though called 'word', 'word' also includes punctuation, e.g. "dot.", "what?")
    for word in string.gmatch(text, "%S+") do

        -- if adding this word makes the current_line's width greater than width
        if font:getWidth(current_line .. " " .. word) > width then
            -- add current_line to divided and reset it already with word
            table.insert(divided, current_line)
            current_line = word

        else
            -- else, just put word in current_line :)
            current_line = current_line .. " " .. word

        end

    end

    -- inserting final current_line
    table.insert(divided,current_line)

    return divided
end

    -- classes
local clss = {}

function clss.game(twarzship_x, twarzship_y, game_width, game_height)
    local game = {}

    -- helpers
    local function drawBackButton()
        local backbutton_color = {0.4, 0.4, 0.4}
        -- Hovering highlights
        if utls.checkHover(16, 16, 16, 16, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
            backbutton_color = {1, 1, 1}

            -- Printing description
            love.graphics.setColor(0.025, 0.025, 0.025, 0.8)
            love.graphics.rectangle("fill", 0, 0, game.coords.game_width, 50)
            love.graphics.setColor(1, 1, 1); love.graphics.setFont(asst.fnts.lilfont_a)
            love.graphics.print("Go back", (game.coords.game_width/2) - (asst.fnts.lilfont_a:getWidth("Go back")/2), 22)
        end

        -- Drawing backbutton
        love.graphics.setColor(backbutton_color); love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 16, 16, 16, 16)
        love.graphics.polygon(
            "fill",
            28, 20,
            20, 24,
            28, 28
        )
    end
    local function drawHUD()
            -- box
        love.graphics.setColor(asst.clrs.grey)
        love.graphics.rectangle("fill", 0, 0, game.coords.game_width, game.coords.stats_height)

            -- empty bars
        love.graphics.setColor(game.background_color)
        love.graphics.rectangle("fill", 8, 8, game.coords.game_width-16, 16)
        love.graphics.rectangle("fill", 8, 24, game.coords.game_width-16, 12)

            -- bars
        love.graphics.setColor(asst.clrs.red)
        love.graphics.rectangle("fill", 8, 8, (game.coords.game_width-16)*(game.twarzship.stats.health/game.twarzship.stats.max_health), 16)
        love.graphics.setColor(1, 1, 1)
        love.graphics.rectangle("fill", 8, 24, (game.coords.game_width-16)*(game.twarzship.stats.shield/game.twarzship.stats.max_shield), 12)

            -- bars text
        love.graphics.setColor(1, 1, 1); love.graphics.setFont(asst.fnts.lilfont_a)
        love.graphics.print(game.twarzship.stats.health, math.floor(game.coords.game_width/2 - asst.fnts.lilfont_a:getWidth(game.twarzship.stats.health)/2), 9)
        love.graphics.setColor(asst.clrs.red); love.graphics.setFont(asst.fnts.lilfont_a)
        love.graphics.print(game.twarzship.stats.shield, math.floor(game.coords.game_width/2 - asst.fnts.lilfont_a:getWidth(game.twarzship.stats.shield)/2), 22)

            -- score
        love.graphics.setColor(game.background_color)
        love.graphics.print(game.currentdata.score, 8, 35)

            -- timer
        love.graphics.print(
            math.floor(game.currentdata.timer),
            (game.coords.game_width - 8) - (asst.fnts.lilfont_a:getWidth(math.floor(game.currentdata.timer))),
            35
        )
    end
    local function drawTitlescreen()
        love.graphics.setLineWidth(2)
        love.graphics.setFont(asst.fnts.lilfont_a)

        for i, option in pairs(game.menu.options) do
            local y = 64 + (i-1)*(game.coords.menub_height+8)
            local color = game.menu.highlight[i]

            -- hovering highlights
            if utls.checkHover(16, y, game.coords.menub_width, game.coords.menub_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                color = asst.clrs.grey
            end

            -- Box
            love.graphics.setColor(color)
            love.graphics.rectangle("line", 16, y, game.coords.menub_width, game.coords.menub_height)
            -- Text
            love.graphics.print(option, (game.coords.game_width/2)-(asst.fnts.lilfont_a:getWidth(option)/2), y + (game.coords.menub_height/2)-8)
        end
    end
    local function drawCartridges()
        love.graphics.setLineWidth(2)
        love.graphics.setFont(asst.fnts.lilfont_a)

        love.graphics.setColor(0.4, 0.4, 0.4)
        love.graphics.print("Select a cartridge:", game.coords.game_width/2 - asst.fnts.lilfont_a:getWidth("Select a cartridge:")/2, 54)

        for i, cartridge in pairs(ctdg.getCartridges()) do
            local ctdgdata = ctdg.ctdg[cartridge]()
            local y = 80 + (i-1)*(game.coords.ctdg_height+8)
            local color = {1, 1, 1}
            -- Hovering highlights
            if utls.checkHover(16, y, game.coords.ctdg_width, game.coords.ctdg_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                color = {0.5, 0.5, 0.5}

                -- hitime
                love.graphics.setColor(asst.clrs.bley[1], asst.clrs.bley[2], asst.clrs.bley[3], .5)
                love.graphics.print("HItime: " .. ctdg:getTimes()[ctdgdata.name], 20, y + game.coords.ctdg_height - 42)

                -- hiscore
                love.graphics.setColor(asst.clrs.bley)
                love.graphics.print("HI: " .. ctdg:getScores()[ctdgdata.name], 20, y + game.coords.ctdg_height - 30)

                -- difficulty
                love.graphics.setColor(asst.clrs.red)
                love.graphics.print("Diff: " .. ctdgdata.difficulty .. "/10", 20, y + game.coords.ctdg_height - 18)

                love.graphics.setColor(0.025, 0.025, 0.025, 0.8)
                love.graphics.rectangle("fill", 0, 0, game.coords.game_width, 50)

                -- Printing description
                for j, line in pairs(divideText(ctdgdata.desc, asst.fnts.lilfont_a, game.coords.game_width - 60)) do
                    love.graphics.setColor(1, 1, 1)
                    love.graphics.print(
                        line,
                        (game.coords.game_width/2) - (asst.fnts.lilfont_a:getWidth(line)/2),
                        22 + (j-1)*12
                    )
                end
            end

            -- Difficulty
            love.graphics.setColor(asst.clrs.red)
            love.graphics.rectangle("fill", 16, y + game.coords.ctdg_height - 4, game.coords.ctdg_width * ctdgdata.difficulty/10, 4)
            -- Box
            love.graphics.setColor(color)
            love.graphics.rectangle("line", 16, y, game.coords.ctdg_width, game.coords.ctdg_height)
            -- Text
            love.graphics.print(cartridge, (game.coords.game_width/2)-(asst.fnts.lilfont_a:getWidth(cartridge)/2), y + (game.coords.ctdg_height/2)-8)
        end

        drawBackButton()
    end
    local function drawControls()

            -- interactive area
            -- values
        local box_x = 30
        local box_y = 105
        local box_w = 190
        local box_h = 175

            -- drawing
        love.graphics.setColor(asst.clrs.grey)
        love.graphics.rectangle("line", box_x, box_y, box_w, box_h)

        game.menu.interactive_space:draw()
        game.menu.interactive_twarzship:draw()

        game.menu.interactive_space:update()
        game.menu.interactive_twarzship:update()

            -- controls and descriptions
            -- values
        local line_height = 10
        local lines_content = {
            { control = "WASD", control_color = asst.clrs.orange, desc = "to move" },
            { control = "Arrows", control_color = asst.clrs.bley, desc = "to shoot" },
            { control = "ESC", control_color = asst.clrs.red, desc = "to pause game" }
        }

        love.graphics.setFont(asst.fnts.lilfont_a)
        for i, content in pairs(lines_content) do

            local controls_width = asst.fnts.lilfont_a:getWidth(content.control .. " ")

            -- controls
            love.graphics.setColor(content.control_color)
            love.graphics.print(content.control, 30, (i-1)*line_height + 60)
            -- desc
            love.graphics.setColor(1, 1, 1)
            love.graphics.print(content.desc, 30 + controls_width, (i-1)*line_height + 60)

        end

            -- backbutton
        drawBackButton()

    end
    local function drawPauseOptions()

            -- drawing settings
        love.graphics.setFont(asst.fnts.lilfont_a)

            -- drawing captions
        local caption_origin_y = (game_height/2) - (10*#game.configs.captions)/2
        for i, caption in pairs(game.configs.captions) do

                -- re-setting
            love.graphics.setColor(1, 1, 1)

                -- values
            local caption_x = (game_width/2) - (asst.fnts.lilfont_a:getWidth(caption)/2)
            local caption_y = caption_origin_y + 15*(i-1)

                -- changing color based on if option is currently selected
            love.graphics.setColor(
                (i == game.configs.selected)
                and asst.clrs.orange
                or  {1, 1, 1}
            )

                -- drawing
            love.graphics.print(caption, caption_x, caption_y)

        end

            -- drawing currently selected option's hint
        local hint = game.configs.hint[game.configs.selected]

        love.graphics.setColor(asst.clrs.grey)
        love.graphics.print(
            hint,
            game_width/2 - asst.fnts.lilfont_a:getWidth(hint)/2,
            game_height - 25
        )

    end
    local function drawMenuOptions()

        love.graphics.setLineWidth(2)
        love.graphics.setFont(asst.fnts.lilfont_a)

        local button_x      = 48
        local origin_y      = 64
        local button_height = 48
        local button_width  = game.coords.menub_width - 64

        for i, button in pairs(game.configs.buttons) do

            local button_y = origin_y + (i-1)*(button_height+8)

                -- box hovering highlights
            love.graphics.setColor(1, 1, 1) --default
            if utls.checkHover(button_x, button_y, button_width, button_height, love.mouse.getX() / game.coords.scale, love.mouse.getY() / game.coords.scale) then
                love.graphics.setColor(asst.clrs.grey)
            end

                -- box
            love.graphics.rectangle("line", button_x, button_y, button_width, button_height)
                -- text
            love.graphics.print(button, button_x+(button_width)/2-(asst.fnts.lilfont_a:getWidth(button)/2), button_y + (button_height/2)-8)

            -- arrows

                -- left arrow hovering highlights
            if utls.checkHover(16, button_y, 24, button_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                love.graphics.setColor(asst.clrs.grey)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.polygon("fill",
                16, button_y + button_height/2,
                40, button_y,
                40, button_y + button_height
            )

                -- right arrow hovering highlights
            if utls.checkHover(button_x + button_width + 8, button_y, 24, button_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                love.graphics.setColor(asst.clrs.grey)
            else
                love.graphics.setColor(1, 1, 1)
            end
            love.graphics.polygon("fill",
                button_x + button_width + 8 + 24, button_y + button_height/2,
                button_x + button_width + 8, button_y,
                button_x + button_width + 8, button_y + button_height
            )

        end

        drawBackButton()

    end
    local function loadCartridge(cartridge)
        game:clear()
        asst.snds.new_game:play()

        cartridge.influence(game)
        game.space:insertManager(cartridge.manager)

        game.currentdata.cartridge = cartridge.name
    end

    game.state = "menu" -- "playing"|"dead"|"menu"|"paused"
    game.background_color = {0.025, 0.025, 0.025}

    game.menu = {
        section = "opt", -- "opt"|"cartridge"|"controls"|"configurations"
        highlight = {
            asst.clrs.bley,
            {1, 1, 1},
            {1, 1, 1},
            {1, 1, 1}
        },
        options = {
            "Select Cartridge",
            "Random Cartridge",
            "Configurations",
            "Controls",
        },
        funcs = {
            function()
                game.menu.section = "cartridge"
            end,
            function()
                local choosen = ctdg.getCartridges()[math.random(#ctdg.getCartridges())]
                loadCartridge(ctdg.ctdg[choosen]())
            end,
            function()
                game.menu.section = "configurations"
            end,
            function()
                game.menu.section = "controls"
            end,
        }
    }
    game.menu.interactive_space = clss.newSpace(game, 30+9, 105+9, 190-18, 175-18)
    game.menu.interactive_twarzship = clss.newTwarzship(game.menu.interactive_space, twarzship_x, twarzship_y)

    game.currentdata = {
        cartridge = "",
        new_hiscore = false,
        new_hitime = false,
        score = 0,
        timer = 0,
    }
    game.music_volume = 4
    game.sfx_volume   = 3
    game.coords = {
        scale = 2,
        game_width = game_width,
        game_height = game_height,
        stats_height = 50,
        menub_width = game_width - 32,
        menub_height = (game_height - 80 - (#game.menu.options-1)*8) / #game.menu.options,
        ctdg_width = game_width - 32,
        ctdg_height = (game_height - 96 - (#ctdg.getCartridges()-1)*8) / #ctdg.getCartridges(),
    }
    game.configs = {
        selected = 1,

        -- paused

        captions = {
            "Resume game",
            "Back to menu",
            "Music volume " .. "(" .. game.music_volume*10 .. "%)",
            "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)",
        },
        hint = {
            "Select with space",
            "Select with space",
            "Change with arrows",
            "Change with arrows",
        },
        functions = {
            -- resume game
            function(key)

                if key ~= "space" then return end
                asst.snds.click:play()
                game.state = "playing"

            end,

            -- back to menu
            function(key)

                if key ~= "space" then return end
                asst.snds.twarzship_dead:play()
                game.state = "menu"

            end,

            -- music volume
            function(key)

                game.music_volume = utls.limit(
                    game.music_volume - utls.boolToValue(key == "left", 1, 0) + utls.boolToValue(key == "right", 1, 0),
                    0, 10
                )

                if key == "left" or key == "right"  then
                    asst.snds.click:play()
                end

                game.configs.buttons[1] = "Music volume " .. "(" .. game.music_volume*10 .. "%)"
                game.configs.captions[3] = "Music volume " .. "(" .. game.music_volume*10 .. "%)"

            end,

            -- sound effects volume
            function(key)

                game.sfx_volume = utls.limit(
                    game.sfx_volume - utls.boolToValue(key == "left", 1, 0) + utls.boolToValue(key == "right", 1, 0),
                    0, 10
                )

                if key == "left" or key == "right"  then
                    asst.snds.click:play()
                end

                game.configs.buttons[2] = "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)"
                game.configs.captions[4] = "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)"

            end
        },

        -- menu

        buttons = {
            "Music volume " .. "(" .. game.music_volume*10 .. "%)",
            "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)",
        },
        menufuncs = {
            -- music volume
            function(part)

                if part == "left" or part == "right" then

                    asst.snds.click:play()

                    game.music_volume = utls.limit(
                        game.music_volume - utls.boolToValue(part == "left", 1, 0) + utls.boolToValue(part == "right", 1, 0),
                        0, 10
                    )

                    game.configs.buttons[1] = "Music volume " .. "(" .. game.music_volume*10 .. "%)"
                    game.configs.captions[3] = "Music volume " .. "(" .. game.music_volume*10 .. "%)"

                end

            end,
            -- sound effects volume
            function(part)

                if part == "left" or part == "right" then

                    asst.snds.click:play()

                    game.sfx_volume = utls.limit(
                        game.sfx_volume - utls.boolToValue(part == "left", 1, 0) + utls.boolToValue(part == "right", 1, 0),
                        0, 10
                    )

                    game.configs.buttons[2] = "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)"
                    game.configs.captions[4] = "SFX volume " .. "(" .. game.sfx_volume*10 .. "%)"

                end

            end
        }

    }

    game.space = clss.newSpace(game)
    game.twarzship = clss.newTwarzship(game.space, twarzship_x, twarzship_y)
    game.space.twarzship = game.twarzship
    game.music = clss.music({
        asst.snds.musics.balles,
        asst.snds.musics.enfer,
        asst.snds.musics.fusil
    })

    function game.setDefaultConfigs(self)
        self.background_color = {0.025, 0.025, 0.025}
        self.twarzship:setDefaultConfigs()
    end
    function game.clear(self)
        self:setDefaultConfigs()
        self.twarzship:clear()
        self.space:clear()

        game.state = "playing"
        game.background_color = {0.025, 0.025, 0.025}
        game.currentdata = {
            score = 0,
            timer = 0
        }
    end
    function game.reset(self)
        save.save()
        self.twarzship:clear()
        self.space:reset()

        game.state = "playing"

        local cartridge = game.currentdata.cartridge
        game.currentdata = {
            cartridge = cartridge,
            new_hiscore = false,
            new_hitime = false,
            score = 0,
            timer = 0
        }
    end

    function game.update(self)
        self.music:update(self.state, self.music_volume, self.sfx_volume)

        if game.state == "playing" then
            self.currentdata.timer = self.currentdata.timer + love.timer.getAverageDelta()
            if self.twarzship:update() then

                if self.currentdata.score > ctdg:getScores()[self.currentdata.cartridge] then
                    self.currentdata.new_hiscore = true
                    ctdg:setScore(self.currentdata.cartridge, self.currentdata.score)
                end

                if self.currentdata.timer > ctdg:getTimes()[self.currentdata.cartridge] then
                    self.currentdata.new_hitime = true
                    ctdg:setTimes(self.currentdata.cartridge, self.currentdata.timer)
                end

                self.state = "dead"
                goto dead
            end

            self.space:update()

            ::dead::
        end
    end
    function game.draw(self)
        if self.state == "playing" or self.state == "paused" then
            -- Background
            love.graphics.setColor(game.background_color)
            love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

            self.space:draw()
            self.twarzship:draw()
            drawHUD()

        elseif self.state == "dead" then
            local hisomething = self.currentdata.new_hitime or self.currentdata.new_hiscore

            -- Background
            love.graphics.setColor(not (hisomething) and {1, 1, 1} or self.twarzship.colors.idle)
            love.graphics.rectangle("fill", 0, 0, self.coords.game_width, self.coords.game_height)

            -- Score
            love.graphics.setColor(hisomething and {1, 1, 1} or {0.5, 0.5, 0.5})
            love.graphics.print(ctdg:getScores()[self.currentdata.cartridge], math.floor(self.coords.game_width/2 - asst.fnts.lilfont_a:getWidth(ctdg:getScores()[game.currentdata.cartridge])/2), 16)
            love.graphics.setColor(hisomething and {1, 1, 1} or self.background_color)
            love.graphics.print(self.currentdata.score, math.floor(self.coords.game_width/2 - asst.fnts.lilfont_a:getWidth(self.currentdata.score)/2), 24)

            love.graphics.setColor(1, 1, 1)

            if self.currentdata.new_hiscore then
                love.graphics.print("New HIscore!", math.floor(self.coords.game_width/2 - asst.fnts.lilfont_a:getWidth("New HIscore!")/2), self.coords.game_height / 2)
            end

            if self.currentdata.new_hitime then
                love.graphics.print("New HItime!", math.floor(self.coords.game_width/2 - asst.fnts.lilfont_a:getWidth("New HItime!")/2), self.coords.game_height / 2 + 10)
            end

            self.twarzship:draw(hisomething and {1, 1, 1})
        elseif self.state == "menu" then
            -- Background
            love.graphics.setColor(0.025, 0.025, 0.025)
            love.graphics.rectangle("fill", 0, 0, self.coords.game_width, self.coords.game_height)

            -- Title
                -- Shadow
            love.graphics.setColor(asst.clrs.red); love.graphics.setFont(asst.fnts.midfont_a)
            love.graphics.print("Twarzhell", (self.coords.game_width/2), 32, math.sin(os.clock()-2)/16, 1, 1, (asst.fnts.midfont_a:getWidth("Twarzhell")/2), (asst.fnts.midfont_a:getHeight("Twarzhell")/2))                -- Title
            love.graphics.setColor(1, 1, 1)
            love.graphics.print("Twarzhell", (self.coords.game_width/2), 32, math.sin(os.clock())/16, 1, 1, (asst.fnts.midfont_a:getWidth("Twarzhell")/2), (asst.fnts.midfont_a:getHeight("Twarzhell")/2))

            if self.menu.section == "opt" then
                drawTitlescreen()
            elseif self.menu.section == "cartridge" then
                drawCartridges()
            elseif self.menu.section == "controls" then
                drawControls()
            elseif self.menu.section == "configurations" then
                drawMenuOptions()
            end

            -- Cursor
            love.graphics.setColor(love.mouse.isDown(1) and {1, 1, 1} or {0.025, 0.025, 0.025})
            love.graphics.polygon(
                "fill",
                love.mouse.getX()/game.coords.scale - 2, love.mouse.getY()/game.coords.scale - 2,
                love.mouse.getX()/game.coords.scale + 20, love.mouse.getY()/game.coords.scale + 5,
                love.mouse.getX()/game.coords.scale + 5, love.mouse.getY()/game.coords.scale + 20
            )
            love.graphics.setColor(love.mouse.isDown(1) and {0.025, 0.025, 0.025} or {1, 1, 1})
            love.graphics.polygon(
                "fill",
                love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale,
                love.mouse.getX()/game.coords.scale + 16, love.mouse.getY()/game.coords.scale + 6,
                love.mouse.getX()/game.coords.scale + 6, love.mouse.getY()/game.coords.scale + 16
            )
        end

        if game.state == "paused" then

            love.graphics.setColor(
                game.background_color[1],
                game.background_color[2],
                game.background_color[3],
                0.75
            )

            love.graphics.rectangle("fill", 0, 0, game_width, game_height)

            drawPauseOptions()

        end

        if love.keyboard.isDown("b") or love.keyboard.isDown("n") then
            love.graphics.setColor(asst.clrs.brey); love.graphics.setFont(asst.fnts.lilfont_a)
            love.graphics.print(utls.roundTo(self.volume*100, 10) .. "% volume", 4, self.coords.game_height-16)
        end
    end
    function game.keypressed(self, key)

        if self.state == "paused" then

            -- If using key to change selected option
            if key == "down" then
                self.configs.selected = utls.limit(self.configs.selected + 1, 1, #self.configs.captions)
            elseif key == "up" then
                self.configs.selected = utls.limit(self.configs.selected - 1, 1, #self.configs.captions)              
            -- If using key to use currently selected option
            else
                self.configs.functions[self.configs.selected](key)
            end

        elseif self.state == "menu" then

            if key == "escape" and (self.menu.section ~= "opt") then
                asst.snds.click:play()
                self.menu.section = "opt"
            end

        end

    end
    function game.mousepressed(self)
        if self.state == "menu" then
            if self.menu.section == "opt" then
                for i, _ in ipairs(self.menu.options) do
                    local y = 64 + (i-1)*(self.coords.menub_height+8)
                    if utls.checkHover(16, y, self.coords.menub_width, self.coords.menub_height, love.mouse.getX()/self.coords.scale, love.mouse.getY()/self.coords.scale) then
                        asst.snds.click:stop()
                        asst.snds.click:play()
                        self.menu.funcs[i]()
                    end
                end
            elseif self.menu.section == "cartridge" then
                -- Cartridge
                for i, cartridge in pairs(ctdg.getCartridges()) do
                    local y = 80 + (i-1)*(game.coords.ctdg_height+8)
                    if utls.checkHover(16, y, game.coords.ctdg_width, game.coords.ctdg_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                        loadCartridge(ctdg.ctdg[cartridge]())
                    end
                end
            elseif self.menu.section == "configurations" then

                local button_x      = 48
                local origin_y      = 64
                local button_height = 48
                local button_width  = game.coords.menub_width - 64

                for i, _ in pairs(game.configs.buttons) do

                    local button_y = origin_y + (i-1)*(button_height+8)

                        -- left arrow
                    if utls.checkHover(16, button_y, 24, button_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                        game.configs.menufuncs[i]("left")
                    end

                        -- right arrow
                    if utls.checkHover(button_x + button_width + 8, button_y, 24, button_height, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                        game.configs.menufuncs[i]("right")
                    end

                end

            end

            -- backbutton
            if self.menu.section == "cartridge" or self.menu.section == "controls" or self.menu.section == "configurations" then
                if utls.checkHover(16, 16, 16, 16, love.mouse.getX()/game.coords.scale, love.mouse.getY()/game.coords.scale) then
                    asst.snds.click:stop()
                    asst.snds.click:play()
                    self.menu.section = "opt"
                end
            end
        end
    end

    function game.load()
        local savefile = io.open("logs/score.txt", "r")

        if savefile then
            for line in savefile:lines("l") do
                ctdg:setScore(string.match(line, "(%w+):"), tonumber(string.match(line, ":(%d+)")))
            end

            savefile:close()
        end
    end

    return game
end
function clss.music(tracks)

    local m = {
        title = asst.snds.musics.twarzhell,

        tracks = tracks,
        tracksvolume = 5,
        current = 2,
    }

    function m:update(gstate, music_volume, sfx_volume)

            -- updating volumes
        for _, sound in pairs(asst.snds) do

            -- musics table (this piece of code isn't scable at all srry gonna fix it)
            if type(sound) == "table" then

                for _, music in pairs(sound) do
                    music:setVolume(music_volume/10)
                end

            else
                sound:setVolume(sfx_volume/10)
            end
        end

        if (gstate == "menu") then

            self.tracks[self.current]:stop()

            self.title:play()

        else

            self.title:stop()

            -- setting different audio effects deppending on game state
            if      gstate == "paused" then
                self.tracks[self.current]:setPitch(0.8)

            elseif  gstate == "dead" then
                self.tracks[self.current]:setPitch(0.5)

            elseif  gstate == "playing" then
                self.tracks[self.current]:setPitch(1)

            end

            -- if current music isn't playing anymore, go to the next one
            if not self.tracks[self.current]:isPlaying() then
                self.current = utls.circular(self.current + 1, #self.tracks)
            end

            -- play music with new configurations
            self.tracks[self.current]:play()

        end

    end

    function m:gotoMenu()

    end

    return m

end
function clss.newSpace(_game, x, y, w, h)
    local space = {
        -- Actual enemies, bosses and projectiles.
        objects = {},
        -- Twarzship's projectiles
        bullets = {},
        -- Not tangible structures that define the space's current behavior.
        managers = {},
        -- General information about the entire space itself
        data = {
            w = w or 250,
            h = h or 250,
            x = x or 0,
            y = y or 50, --magic numbers go brrr
        }
    }

    space.twarzship = {}
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
        self.managers = {}
        self.objects = {}
        self.bullets = {}
    end
    function space.reset(self)
        self.objects = {}
        self.bullets = {}
    end

    -- Checks if enemy ``obj`` was hit by any of the bullets in ``bullets``.
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
    function space.update(self)
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
            if (object.init and not object.init.isInit) or (not object.init) then
                if game.twarzship:interactWithObject(object) and object.single then
                    table.remove(self.objects, i)
                end
            end
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
function clss.newBullet(x, y, vx, vy, dmg, clr)
    local bullet = {
        x = x,
        y = y,
        vx = vx,
        vy = vy,
        r = 4,
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
        love.graphics.setColor(clr[1], clr[2], clr[3], self.life / 2)
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
            r = 8, -- radius
            -- hitbox_radius / radius
            hitbox_percentage = 0.85,

            vel_x = 0,
            vel_y = 0,
            vel   = 3,
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
            bullet_velocity = 4,
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

        self.space.vel_x = 0
        self.space.vel_y = 0

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

        self.space.vel_x = self.space.vel * movement.x
        self.space.vel_y = self.space.vel * movement.y

        self:move()
    end

    function twarzship.heal(self, shield)
        asst.snds.twarzship_heal:play()
        self.stats.shield = utls.limit(self.stats.shield + shield, 0, self.stats.max_shield)
    end
    function twarzship.hit(self, damage)
        asst.snds.twarzship_hurt:play()
        if self.stats.shield > 0 then
            self.stats.shield = utls.limit(self.stats.shield - damage, 0, self.stats.max_shield)
        else
            self.stats.health = utls.limit(self.stats.health - damage, 0, self.stats.max_health)
        end
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
                self.shooting.bullet_damage,
                self.colors.idle
            )
        )
    end
    function twarzship.processShooting(self)
        local shot_dir = {x = 0, y = 0}

        if (love.keyboard.isDown("delete") or love.keyboard.isDown("left")) and self.shooting.bullet_timer <= 0 then
            shot_dir.x = -1
        elseif (love.keyboard.isDown("pagedown")  or love.keyboard.isDown("right")) and self.shooting.bullet_timer <= 0 then
            shot_dir.x = 1
        end

        if (love.keyboard.isDown("home")  or love.keyboard.isDown("up")) and self.shooting.bullet_timer <= 0 then
            shot_dir.y = -1
        elseif (love.keyboard.isDown("end")  or love.keyboard.isDown("down")) and self.shooting.bullet_timer <= 0 then
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
    function twarzship.draw(self, opt_color)
        love.graphics.setColor(opt_color or self.colors[self.state])
        love.graphics.setLineWidth(
            self.state == "dead"
            and 2
            or  4
        )
        love.graphics.circle("line", self.space.x, self.space.y, self.space.r)
    end

    -- Interacts self with ```obj``` enms object. Returns true if interaction happened
    function twarzship.interactWithObject(self, obj)

        if utls.getDistanceBetweenPoints(self.space.x, self.space.y, obj.x, obj.y) <= obj.r + (self.space.hitbox_percentage * obj.r) then
            self.state = "hurt"
            obj:interact(self)
            return true
        end

        return false
    end
    function twarzship.setDefaultConfigs(self)
        self.stats.max_health = 100
        self.stats.max_shield = 50

        self.shooting.bullet_damage = 0.125
        self.shooting.bullet_delay = 0.125
        self.shooting.bullet_velocity = 4
        self.space.r = 8
        self.space.vel = 3

        self.colors.idle = asst.clrs.brey
    end
    function twarzship.clear(self)
        self.space.x = ix
        self.space.y = iy
        self.space.vel_x = 0
        self.space.vel_y = 0

        self.stats.state = "idle"
        self.stats.health = self.stats.max_health
        self.stats.shield = self.stats.max_shield
    end

    return twarzship
end

return clss