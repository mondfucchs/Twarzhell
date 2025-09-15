    -- tools
local love = require("love")

    -- assets
local asst = {}

asst.controls = love.graphics.newImage("assets/imgs/controls.png")

asst.clrs = {
    red = {0.8, 0.1, 0.1},
    bley = {81/255, 157/255, 232/255},
    orange = {240/255, 160/255, 31/255},
    lgreen = {90/255, 209/255, 138/255},
    green = {181/255, 232/255, 39/255},
    brey = {0.5, 0.5, 0.75},
    grey = {0.5, 0.5, 0.55},
    mdrey = {0.4, 0.4, 0.45},
    drey = {0.2, 0.2, 0.25}
}

asst.fnts = {
    lilfont_a = love.graphics.newFont("assets/fonts/kapel.ttf", 16),
    midfont_a = love.graphics.newFont("assets/fonts/kapel.ttf", 32)
}
asst.fnts.lilfont_a:setFilter("nearest", "nearest")
asst.fnts.midfont_a:setFilter("nearest", "nearest")

asst.snds = {
    -- sfx
    twarzship_shot = love.audio.newSource("assets/sounds/twarzship_shot.wav", "static"),
    twarzship_hurt = love.audio.newSource("assets/sounds/twarzship_hurt.wav", "static"),
    twarzship_dead = love.audio.newSource("assets/sounds/twarzship_dead.wav", "static"),
    twarzship_heal = love.audio.newSource("assets/sounds/gullet.wav", "static"),
    enemy_shot = love.audio.newSource("assets/sounds/enemy_shot.wav", "static"),
    enemy_hurt = love.audio.newSource("assets/sounds/enemy_hurt.wav", "static"),
    enemy_dead = love.audio.newSource("assets/sounds/enemy_dead.wav", "static"),
    new_game = love.audio.newSource("assets/sounds/new_game.wav", "static"),
    explosion = love.audio.newSource("assets/sounds/explosion.wav", "static"),
    click = love.audio.newSource("assets/sounds/click.wav", "static"),
    -- (bande originale)
    musics = {
        twarzhell   = love.audio.newSource("assets/sounds/musics/twarzhell.mp3", "stream"),
        balles      = love.audio.newSource("assets/sounds/musics/balles.mp3", "stream"),
        fusil       = love.audio.newSource("assets/sounds/musics/fusil.mp3", "stream"),
        enfer       = love.audio.newSource("assets/sounds/musics/enfer.mp3", "stream"),
    }
}

asst.snds.musics.twarzhell:setLooping(true)

return asst