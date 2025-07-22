    -- tools
local love = require("love")

    -- assets
local asst = {}

asst.clrs = {
    red = {0.8, 0.1, 0.1},
    orange = {240/255, 160/255, 31/255},
    brey = {0.5, 0.5, 0.75},
    grey = {0.5, 0.5, 0.55},
    mdrey = {0.4, 0.4, 0.45},
    drey = {0.2, 0.2, 0.25}
}

asst.fnts = {
    lilfont_a = love.graphics.newFont("assets/fonts/kapel.ttf", 32)
}

asst.snds = {
    twarzship_shot = love.audio.newSource("assets/sounds/twarzship_shot.wav", "static"),
    twarzship_hurt = love.audio.newSource("assets/sounds/twarzship_hurt.wav", "static"),
    twarzship_dead = love.audio.newSource("assets/sounds/twarzship_dead.wav", "static"),
    enemy_shot = love.audio.newSource("assets/sounds/enemy_shot.wav", "static"),
    enemy_hurt = love.audio.newSource("assets/sounds/enemy_hurt.wav", "static"),
    enemy_dead = love.audio.newSource("assets/sounds/enemy_dead.wav", "static"),
    new_game = love.audio.newSource("assets/sounds/new_game.wav", "static"),
    explosion = love.audio.newSource("assets/sounds/explosion.wav", "static"),
}

return asst