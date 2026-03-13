-- Game state. Owns the world object and orchestrates all gameplay.
-- Replaces the monolithic Game_Content_Update / Draw_Game_Content in main.lua.
--
-- Stage flow:
--   1 → asteroids cleared → 2 → ships cleared → 3 → boss killed → win
-- Each stage transition is guarded by a doOnce flag so initStage*() runs once.

local Assets    = require("src.assets")
local Audio     = require("src.systems.audio")
local Collision = require("src.systems.collision")
local Spawner   = require("src.systems.spawner")
local HUD       = require("src.ui.hud")
local Background = require("src.ui.background")
local C         = require("src.constants")

-- Entity constructors (loaded lazily inside functions to avoid cycles)
local function newExplosion(x, y)
    return require("src.entities.explosion").new(x, y)
end
local function newFinalExplosion(x, y)
    return require("src.entities.final_explosion").new(x, y)
end
local function newDebris(x, y, sx, sy)
    return require("src.entities.debris").new(x, y, sx, sy)
end
local function newMedium(x, y)
    return require("src.entities.enemy_medium").new(x, y)
end
local function newSmall(x, y)
    return require("src.entities.enemy_small").new(x, y)
end
local function newPickup(x, y, sx, sy)
    return require("src.entities.health_pickup").new(x, y, sx, sy)
end

-- ── World ─────────────────────────────────────────────────────────────────────
-- Central game object.  All entity tables live here; no globals.
local function newWorld()
    return {
        player           = nil,
        bullets          = {},
        enemies          = { large={}, medium={}, small={} },
        ships            = { normal={}, large={}, boss_spawn={} },
        boss             = nil,
        beams            = { pre={}, active={} },
        bombs            = {},
        enemy_bullets    = {},
        explosions       = {},
        final_explosion  = nil,
        debris           = {},
        pickups          = {},
        health_icons     = {},
        boss_health_icons = {},
        stage            = 1,
        score            = 0,
        death_time       = -1,
        boss_death_time  = -1,
        win              = false,

        -- Callbacks used by collision.lua so it stays decoupled from entity constructors
        spawn_pickup     = nil,   -- set below
        restore_health   = nil,   -- set below
        on_boss_hit      = nil,   -- set below
    }
end

-- ── Game state ────────────────────────────────────────────────────────────────
local Game = {}
Game.__index = Game

function Game.new(sm)
    return setmetatable({ sm = sm }, Game)
end

function Game:enter()
    Audio.playBGM("bgm_normal")

    local world = newWorld()
    self.world = world

    -- Wire up collision callbacks
    world.spawn_pickup = function(x, y)
        table.insert(world.pickups, newPickup(x, y,
            math.random(-25, 25), math.random(-25, 50)))
    end

    world.restore_health = function()
        local A  = Assets
        local hp = #world.health_icons
        if hp > 0 then
            local last = world.health_icons[hp]
            table.insert(world.health_icons, {
                img   = A.images.heart,
                x     = last.x + C.HEALTH_GAP,
                y     = C.HEALTH_Y,
                w     = A.images.heart:getWidth(),
                h     = A.images.heart:getHeight(),
                angle = 0,
            })
        end
        Audio.playRandom("pickhp", 0.5, 1.0)
    end

    world.on_boss_hit = function()
        local hp = #world.boss_health_icons
        if hp > 0 then
            table.remove(world.boss_health_icons, hp)
        end
        world.boss.hp = world.boss.hp - 1
        if world.boss.hp <= 0 then
            world.boss.isDead     = true
            world.boss_death_time = love.timer.getTime()
            world.win             = true
            world.score           = world.score + 100
            world.final_explosion = newFinalExplosion(world.boss.x, world.boss.y)
            table.insert(world.explosions, newExplosion(world.boss.x, world.boss.y))
        else
            Audio.playRandom("bosshurt", 0.2, 0.6)
        end
    end

    -- Player
    local Player = require("src.entities.player")
    world.player = Player.new()

    -- Stage 1 entities
    Spawner.initStage1(world)

    self.stage2Init = false
    self.stage3Init = false
    self.clickTime  = love.timer.getTime()
    self.cursor     = Assets.images.crosshair
end

function Game:exit()
    -- nothing to tear down
end

-- ── Update ────────────────────────────────────────────────────────────────────
function Game:update(dt)
    local world = self.world

    if world.player.isDead then
        -- Wait then switch to game-over state
        if love.timer.getTime() - world.death_time >= C.DEATH_MENU_DELAY then
            local GameOver = require("src.states.gameover")
            self.sm:replace(GameOver.new(self.sm, world.score))
        end
        return
    end

    world.player:update(dt)

    -- ── Stage transitions ────────────────────────────────────────────────────
    local noAsteroids = #world.enemies.large + #world.enemies.medium + #world.enemies.small == 0
    local noShips     = #world.ships.normal + #world.ships.large == 0

    if noAsteroids and not self.stage2Init then
        Spawner.initStage2(world)
        Audio.playBGM("bgm_normal")
        self.stage2Init = true
    end

    if noAsteroids and noShips and self.stage2Init and not self.stage3Init then
        Spawner.initStage3(world)
        Audio.playBGM("bgm_boss")
        self.stage3Init = true
    end

    -- ── Win check ────────────────────────────────────────────────────────────
    if world.win and love.timer.getTime() - world.boss_death_time >= C.BOSS_DEATH_WIN_DELAY then
        local Win = require("src.states.win")
        self.sm:replace(Win.new(self.sm, world.score))
        return
    end

    -- ── Update entities ──────────────────────────────────────────────────────
    for _, b in ipairs(world.bullets)       do b:update(dt) end
    for _, b in ipairs(world.enemy_bullets) do b:update(dt) end

    for _, e in ipairs(world.enemies.large)  do e:update(dt) end
    for _, e in ipairs(world.enemies.medium) do e:update(dt) end
    for _, e in ipairs(world.enemies.small)  do e:update(dt) end

    for _, s in ipairs(world.ships.normal)     do s:update(dt, world) end
    for _, s in ipairs(world.ships.large)      do s:update(dt, world) end
    for _, s in ipairs(world.ships.boss_spawn) do s:update(dt, world) end

    if world.boss and not world.boss.isDead then
        world.boss:update(dt, world)
    end

    for _, bp in ipairs(world.beams.pre)    do bp:update(dt, world) end
    for _, bm in ipairs(world.beams.active) do bm:update(dt, world) end
    for _, bo in ipairs(world.bombs)        do bo:update(dt) end

    for _, d  in ipairs(world.debris)      do d:update(dt) end
    for _, p  in ipairs(world.pickups)     do p:update(dt) end
    for _, ex in ipairs(world.explosions)  do ex:update(dt) end

    if world.final_explosion then
        world.final_explosion:update(dt)
    end

    -- ── Collision ────────────────────────────────────────────────────────────
    Collision.checkBullets(world)
    Collision.checkEnemiesVsPlayer(world)
    Collision.checkBulletsVsBombs(world)

    -- ── Spawn children from dead enemies ─────────────────────────────────────
    -- Large asteroids → 2 mediums
    for i = #world.enemies.large, 1, -1 do
        local e = world.enemies.large[i]
        if e.isDead then
            for _ = 1, 2 do
                table.insert(world.enemies.medium, newMedium(e.x, e.y))
            end
            Audio.playRandom("crack", 0.2, 0.6)
            table.remove(world.enemies.large, i)
        end
    end

    -- Medium asteroids → 2 smalls
    for i = #world.enemies.medium, 1, -1 do
        local e = world.enemies.medium[i]
        if e.isDead then
            for _ = 1, 2 do
                table.insert(world.enemies.small, newSmall(e.x, e.y))
            end
            Audio.playRandom("crack", 0.2, 0.6)
            table.remove(world.enemies.medium, i)
        end
    end

    -- Small asteroids → 3 debris + explosion
    for i = #world.enemies.small, 1, -1 do
        local e = world.enemies.small[i]
        if e.isDead then
            for _ = 1, 3 do
                table.insert(world.debris, newDebris(e.x, e.y,
                    e.speedX + math.random(-100, 100),
                    e.speedY + math.random(-100, 100)))
            end
            Audio.playRandom("crack", 0.2, 0.6)
            table.remove(world.enemies.small, i)
        end
    end

    -- Ships (all types) → explosion + boom
    local shipTables = { world.ships.normal, world.ships.large, world.ships.boss_spawn }
    for _, grp in ipairs(shipTables) do
        for i = #grp, 1, -1 do
            local s = grp[i]
            if s.isDead then
                table.insert(world.explosions, newExplosion(s.x, s.y))
                Audio.play("boom")
                table.remove(grp, i)
            end
        end
    end

    -- ── Prune dead entities ──────────────────────────────────────────────────
    local function prune(list)
        for i = #list, 1, -1 do
            if list[i].isDead then table.remove(list, i) end
        end
    end
    prune(world.bullets)
    prune(world.enemy_bullets)
    prune(world.debris)
    prune(world.pickups)
    prune(world.explosions)
    prune(world.beams.pre)
    prune(world.beams.active)
    prune(world.bombs)
end

-- ── Draw ──────────────────────────────────────────────────────────────────────
function Game:draw()
    local world = self.world

    Background.draw()
    love.graphics.setColor(1, 1, 1, 1)

    if world.player.isDead then
        love.graphics.draw(Assets.images.lose_screen, 250, 250)
        return
    end

    -- Player
    world.player:draw()

    -- Bullets
    for _, b in ipairs(world.bullets)       do b:draw() end
    for _, b in ipairs(world.enemy_bullets) do b:draw() end

    -- Asteroids
    for _, e in ipairs(world.enemies.large)  do e:draw() end
    for _, e in ipairs(world.enemies.medium) do e:draw() end
    for _, e in ipairs(world.enemies.small)  do e:draw() end

    -- Ships
    for _, s in ipairs(world.ships.normal)     do s:draw() end
    for _, s in ipairs(world.ships.large)      do s:draw() end
    for _, s in ipairs(world.ships.boss_spawn) do s:draw() end

    -- Boss beams and bombs
    for _, bp in ipairs(world.beams.pre)    do bp:draw() end
    for _, bm in ipairs(world.beams.active) do bm:draw() end
    for _, bo in ipairs(world.bombs)        do bo:draw() end

    -- Boss
    if world.boss then
        if not world.boss.isDead then
            world.boss:draw()
        elseif world.final_explosion then
            -- Five offset blasts for the dramatic death
            local fe  = world.final_explosion
            local bx  = world.boss.x
            local by  = world.boss.y
            local offsets = {{ 50, 50},{50,-50},{-50,50},{-50,-50},{0,0}}
            for _, o in ipairs(offsets) do
                fe:draw(bx + o[1], by + o[2], 3, 3)
            end
            Audio.play("bossboom")
            world.bombs = {}
        end
    end

    -- Debris + pickups + explosions
    for _, d  in ipairs(world.debris)     do d:draw() end
    for _, p  in ipairs(world.pickups)    do p:draw() end
    for _, ex in ipairs(world.explosions) do ex:draw() end

    -- HUD (hearts, boss HP bar, score)
    HUD.draw(world)
end

-- ── Input ──────────────────────────────────────────────────────────────────────
function Game:keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Game:mousepressed(mx, my, button)
    local world = self.world
    if button == 1
        and not world.player.isDead
        and not world.win
        and love.timer.getTime() - self.clickTime >= C.BULLET_COOLDOWN
    then
        if #world.bullets < C.MAX_BULLETS then
            local Bullet = require("src.entities.bullet")
            table.insert(world.bullets, Bullet.new(world.player))
            self.clickTime = love.timer.getTime()
            Audio.playRandom("shoot", 0.3, 0.8)
        end
    end
end

return Game
