-- Central asset registry. Call Assets.load() once inside love.load().
-- All entity/UI files reference Assets.images / .sounds / .fonts
-- instead of loading their own copies.
local Assets = {}

function Assets.load()
    Assets.images = {
        -- Background
        background        = love.graphics.newImage("assets/background.png"),

        -- Player
        player            = love.graphics.newImage("assets/player.png"),
        player_anim       = love.graphics.newImage("assets/animation/player_anim.png"),
        player_dmg        = love.graphics.newImage("assets/animation/player_dmg_anim.png"),

        -- Player bullet (laser)
        laser             = love.graphics.newImage("assets/laser.png"),
        laser_anim        = love.graphics.newImage("assets/animation/laser_anim.png"),

        -- Enemy bullet
        bullet            = love.graphics.newImage("assets/bullet.png"),
        bullet_anim       = love.graphics.newImage("assets/animation/bullet_anim.png"),

        -- Asteroids (static sprites used for draw, no animation)
        enemy_large       = love.graphics.newImage("assets/enemyL1.png"),
        enemy_medium      = love.graphics.newImage("assets/enemyM1.png"),
        enemy_small       = love.graphics.newImage("assets/enemyS1.png"),

        -- Stage-2 enemy ships
        ship              = love.graphics.newImage("assets/enemyS.png"),
        ship_anim         = love.graphics.newImage("assets/animation/enemyS_anim.png"),
        ship_large        = love.graphics.newImage("assets/enemyL.png"),
        ship_large_anim   = love.graphics.newImage("assets/animation/enemyL_anim.png"),

        -- Boss
        boss              = love.graphics.newImage("assets/boss.png"),
        boss_anim         = love.graphics.newImage("assets/animation/boss_anim.png"),

        -- Effects
        explosion         = love.graphics.newImage("assets/animation/explosion_anim.png"),
        final_explosion   = love.graphics.newImage("assets/animation/explosion1.png"),
        beam              = love.graphics.newImage("assets/animation/beam_anim.png"),
        beam_pre          = love.graphics.newImage("assets/animation/beam_pre_anim.png"),
        bomb              = love.graphics.newImage("assets/animation/bomb_anim.png"),
        debris            = love.graphics.newImage("assets/debris1.png"),

        -- Health pickup
        hp_pickup         = love.graphics.newImage("assets/animation/hp_anim.png"),

        -- HUD
        heart             = love.graphics.newImage("assets/heart.png"),
        bosshp_high       = love.graphics.newImage("assets/bosshp_high.png"),
        bosshp_mid        = love.graphics.newImage("assets/bosshp_mid.png"),
        bosshp_low        = love.graphics.newImage("assets/bosshp.png"),

        -- Cursors
        crosshair         = love.graphics.newImage("assets/crosshair1.png"),
        crosshair_menu    = love.graphics.newImage("assets/crosshair_menu.png"),

        -- Menu
        logo              = love.graphics.newImage("assets/menu/logo.png"),
        btn_start         = love.graphics.newImage("assets/menu/start.png"),
        btn_option        = love.graphics.newImage("assets/menu/option1.png"),
        btn_exit          = love.graphics.newImage("assets/menu/exit.png"),
        instruction       = love.graphics.newImage("assets/menu/instruction.png"),
        btn_back          = love.graphics.newImage("assets/menu/back.png"),

        -- End screens
        lose_screen       = love.graphics.newImage("assets/lose.png"),
        win_screen        = love.graphics.newImage("assets/win.png"),
    }

    Assets.sounds = {
        -- BGM (stream = decoded on the fly, suitable for long tracks)
        bgm_menu   = love.audio.newSource("assets/sound/menu.mp3",   "stream"),
        bgm_normal = love.audio.newSource("assets/sound/normal.mp3", "stream"),
        bgm_boss   = love.audio.newSource("assets/sound/boss.mp3",   "stream"),
        bgm_win    = love.audio.newSource("assets/sound/win.mp3",    "stream"),

        -- SFX (static = fully buffered in memory)
        shoot    = love.audio.newSource("assets/sound/shoot.ogg",   "static"),
        resize   = love.audio.newSource("assets/sound/resize.ogg",  "static"),
        boom     = love.audio.newSource("assets/sound/boom.ogg",    "static"),
        crack    = love.audio.newSource("assets/sound/crack.ogg",   "static"),
        pickhp   = love.audio.newSource("assets/sound/pickhp.ogg",  "static"),
        bosshurt = love.audio.newSource("assets/sound/bosshurt.ogg","static"),
        hurt     = love.audio.newSource("assets/sound/hurt.ogg",    "static"),
        bossboom = love.audio.newSource("assets/sound/bossboom.ogg","static"),
    }

    -- Set BGM volumes
    Assets.sounds.bgm_menu:setVolume(0.75)
    Assets.sounds.bgm_normal:setVolume(0.75)
    Assets.sounds.bgm_boss:setVolume(0.75)
    Assets.sounds.bgm_win:setVolume(0.75)

    Assets.fonts = {
        hud = love.graphics.newFont("assets/198O.ttf", 40),
        win = love.graphics.newFont("assets/198O.ttf", 120),
    }
end

return Assets
