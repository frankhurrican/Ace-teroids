-- Beam pre-charge animation that plays before the actual beam fires.
-- After its 1-second life expires it spawns a Beam into world.beams.active.
-- Position tracks the boss each frame.

local anim8  = require("anim8")
local Assets = require("src.assets")

local BeamPre = {}
BeamPre.__index = BeamPre

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(36, 34, 360, 34, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-10", 1), 0.1)
end

function BeamPre.new(x0, y0)
    ensureAssets()
    local obj = {
        imgAnim   = Assets.images.beam_pre,
        anim      = BASE_ANIM:clone(),
        w         = 36,
        h         = 34,
        x         = x0,
        y         = y0,
        angle     = math.rad(180),
        spawnTime = love.timer.getTime(),
        life      = 1,
        isDead    = false,
    }
    return setmetatable(obj, BeamPre)
end

function BeamPre:update(dt, world)
    self.anim:update(dt)

    -- Track boss position
    if world.boss then
        self.x = world.boss.x
        self.y = world.boss.y + 100
    end

    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
        -- Spawn the real beam
        local Beam = require("src.entities.beam")
        world.beams.active = {}
        table.insert(world.beams.active, Beam.new(self.x, self.y))
    end
end

function BeamPre:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 2, 2, 36/2, 34/2)
end

return BeamPre
