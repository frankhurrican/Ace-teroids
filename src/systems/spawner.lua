-- Spawner: creates entity tables for each stage transition.
-- Extracted from main.lua's Init_Level / Init_Level_stage2 / Init_Level_boss.

local Assets  -- lazy-loaded
local C = require("src.constants")

local Spawner = {}

local function getAssets()
    if not Assets then Assets = require("src.assets") end
    return Assets
end

-- Helper: build a row of HUD icons starting at (baseX, y), spaced by gap.
local function makeIconRow(img, count, baseX, y, gap)
    local A   = getAssets()
    local row = {}
    local w   = A.images[img]:getWidth()
    local h   = A.images[img]:getHeight()
    for i = 1, count do
        table.insert(row, {
            img   = A.images[img],
            x     = baseX + (i - 1) * gap,
            y     = y,
            w     = w,
            h     = h,
            angle = 0,
        })
    end
    return row
end

-- Stage 1: asteroids + player health icons.
-- Resets bullets, pickups, explosions and score so a restart is clean.
function Spawner.initStage1(world)
    local A = getAssets()
    local EnemyLarge = require("src.entities.enemy_large")

    world.bullets       = {}
    world.enemies       = { large = {}, medium = {}, small = {} }
    world.ships         = { normal = {}, large = {}, boss_spawn = {} }
    world.boss          = nil
    world.beams         = { pre = {}, active = {} }
    world.bombs         = {}
    world.enemy_bullets = {}
    world.explosions    = {}
    world.final_explosion = nil
    world.debris        = {}
    world.pickups       = {}
    world.score         = 0
    world.death_time    = -1
    world.boss_death_time = -1
    world.win           = false
    world.stage         = 1

    for _ = 1, C.STAGE1_ASTEROID_COUNT do
        table.insert(world.enemies.large, EnemyLarge.new())
    end

    world.health_icons      = makeIconRow("heart",    3, C.HEALTH_X,  C.HEALTH_Y,  C.HEALTH_GAP)
    world.boss_health_icons = {}
end

-- Stage 2: enemy ships (called once when all asteroids are cleared).
function Spawner.initStage2(world)
    local EnemyShip      = require("src.entities.enemy_ship")
    local EnemyShipLarge = require("src.entities.enemy_ship_large")

    world.ships.normal    = {}
    world.ships.large     = {}
    world.ships.boss_spawn = {}
    world.enemy_bullets   = {}
    world.stage           = 2

    for _, x in ipairs(C.STAGE2_SHIP_XS) do
        table.insert(world.ships.normal, EnemyShip.new(x, 0))
    end
    for _, x in ipairs(C.STAGE2_SHIPL_XS) do
        table.insert(world.ships.large, EnemyShipLarge.new(x, 0))
    end
end

-- Stage 3: boss (called once when all ships are cleared).
function Spawner.initStage3(world)
    local Boss = require("src.entities.boss")

    world.boss  = Boss.new(450, 0)
    world.stage = 3

    world.boss_health_icons = makeIconRow(
        "bosshp_high",
        world.boss.hp,
        C.BOSS_HP_X,
        C.BOSS_HP_Y,
        C.BOSS_HP_GAP
    )
end

return Spawner
