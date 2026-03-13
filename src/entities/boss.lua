-- Final boss (stage 3).
-- Three attack phases based on HP:
--   hp > BOSS_HP_PHASE_MID  → spawn enemy ships + spread bullets
--   hp > BOSS_HP_PHASE_LOW  → beam attacks + spread bullets
--   hp <= BOSS_HP_PHASE_LOW → bomb attacks
--
-- Fixes from original:
--   * Init_EnemyShip(obj, ...) passed undefined `obj` — removed
--   * bombs[1]:UpdateAnim(dt) called without bounds check — now guarded
--   * Wrong distance formula — collision moved to collision.lua (util.dist)
--   * Per-frame love.graphics.newImage for boss HP bar phases — now uses
--     Assets references; phase image is set once when threshold is crossed

local anim8  = require("anim8")
local Assets = require("src.assets")
local C      = require("src.constants")

local Boss = {}
Boss.__index = Boss

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(220, 210, 440, 210, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-2", 1), 0.1)
end

function Boss.new(x0, y0)
    ensureAssets()
    local img = Assets.images.boss
    local obj = {
        imgAnim    = Assets.images.boss_anim,
        anim       = BASE_ANIM:clone(),
        w          = img:getWidth(),
        h          = img:getHeight(),
        x          = x0,
        y          = y0,
        newX       = x0,
        newY       = y0,
        oriX       = x0,
        angle      = math.rad(180),
        speedX     = 0,
        speedY     = 0,
        counter    = 0,
        iCounter   = 0,
        first      = true,
        hp         = C.BOSS_HP,
        spawnTime  = love.timer.getTime(),
        isDead     = false,
        -- doOnce flags: prevent repeated setup work when entering a phase
        phaseMidDone = false,
        phaseLowDone = false,
    }
    return setmetatable(obj, Boss)
end

function Boss:update(dt, world)
    self.anim:update(dt)

    -- Movement: straight down, then oscillate left/right
    if self.counter <= 150 then
        self.newY = self.y + 2
        if self.y > 50 then
            self.counter = self.counter + 2
        end
    else
        if self.first then
            if self.iCounter >= 0 then
                self.newX    = self.x + 2
                self.iCounter = self.iCounter + 1
                if self.iCounter == 200 then self.iCounter = -1 end
            else
                self.newX    = self.x - 2
                self.iCounter = self.iCounter - 1
                if self.iCounter == -400 then
                    self.iCounter = 1
                    self.first = false
                end
            end
        else
            if self.iCounter >= 0 then
                self.newX    = self.x + 2
                self.iCounter = self.iCounter + 1
                if self.iCounter == 400 then self.iCounter = -1 end
            else
                self.newX    = self.x - 2
                self.iCounter = self.iCounter - 1
                if self.iCounter == -400 then self.iCounter = 1 end
            end
        end
    end

    -- Attack phases
    local EnemyBullet = require("src.entities.enemy_bullet")
    local EnemyShip   = require("src.entities.enemy_ship")
    local BeamPre     = require("src.entities.beam_pre")
    local Bomb        = require("src.entities.bomb")

    if self.hp > C.BOSS_HP_PHASE_MID then
        -- Phase 1: spawn a ship + 2-way spread bullets every 2 s
        if love.timer.getTime() - self.spawnTime >= 2 then
            self.spawnTime = love.timer.getTime()
            table.insert(world.ships.boss_spawn, EnemyShip.new(self.x, self.y))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y,  45, 100, 0, 0, 0))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y, -45, 100, 0, 0, 0))
        end

    elseif self.hp > C.BOSS_HP_PHASE_LOW then
        -- Phase 2: update HP bar icon to mid image (once)
        if not self.phaseMidDone then
            for _, icon in ipairs(world.boss_health_icons) do
                icon.img = Assets.images.bosshp_mid
            end
            self.phaseMidDone = true
        end
        -- Beam attack + 4-way spread every 3 s
        if love.timer.getTime() - self.spawnTime >= 3 then
            self.spawnTime = love.timer.getTime()
            world.beams.pre = {}
            table.insert(world.beams.pre, BeamPre.new(self.x, self.y))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y,  45, 100, 0, 0, 0))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y, -45, 100, 0, 0, 0))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y,  90, 100, 0, 0, 0))
            table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y, -90, 100, 0, 0, 0))
        end

    else
        -- Phase 3: update HP bar icon to low image (once)
        if not self.phaseLowDone then
            for _, icon in ipairs(world.boss_health_icons) do
                icon.img = Assets.images.bosshp_low
            end
            self.phaseLowDone = true
        end
        -- Drop a bomb every 2 s
        if love.timer.getTime() - self.spawnTime >= 2 and not self.isDead then
            self.spawnTime = love.timer.getTime()
            table.insert(world.bombs, Bomb.new(self.x, self.y + 100))
        end
        -- Animate the most recent bomb (guarded bounds check)
        if #world.bombs > 0 and not self.isDead then
            world.bombs[#world.bombs]:updateAnim(dt)
        end
    end

    self.x = self.newX
    self.y = self.newY
end

function Boss:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return Boss
