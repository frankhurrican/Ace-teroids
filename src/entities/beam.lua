-- Boss laser beam. Active for 1 second after beam_pre completes.
-- Position tracks the boss each frame.
--
-- Fix from original: collision now checks BOTH X range AND Y range.
-- Original only checked X, so standing directly above/below was safe.
-- Collision handled in collision.checkEnemiesVsPlayer() — see that file.

local anim8  = require("anim8")
local Assets = require("src.assets")

local Beam = {}
Beam.__index = Beam

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(60, 458, 600, 458, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-10", 1), 0.1)
end

function Beam.new(x0, y0)
    ensureAssets()
    local obj = {
        imgAnim   = Assets.images.beam,
        anim      = BASE_ANIM:clone(),
        x         = x0,
        y         = y0,
        angle     = math.rad(0),
        spawnTime = love.timer.getTime(),
        life      = 1,
        isDead    = false,
    }
    return setmetatable(obj, Beam)
end

function Beam:update(dt, world)
    self.anim:update(dt)

    -- Track boss position
    if world.boss then
        self.x = world.boss.x - 28
        self.y = world.boss.y + 90
    end

    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
    end
end

function Beam:draw()
    -- Scale 2x, origin at top-centre of beam sprite
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 2, 2, 36/2, 0)
end

return Beam
