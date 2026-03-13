-- Small explosion animation. Spawned when enemies die.

local anim8  = require("anim8")
local Assets = require("src.assets")

local Explosion = {}
Explosion.__index = Explosion

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(128, 128, 640, 128, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-5", 1), 0.1)
end

function Explosion.new(x, y)
    ensureAssets()
    local obj = {
        imgAnim   = Assets.images.explosion,
        anim      = BASE_ANIM:clone(),
        w         = 128,
        h         = 128,
        x         = x or 0,
        y         = y or 0,
        angle     = math.rad(math.random(-180, 180)),
        spawnTime = love.timer.getTime(),
        life      = 0.49,
        isDead    = false,
    }
    return setmetatable(obj, Explosion)
end

function Explosion:update(dt)
    self.anim:update(dt)
    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
    end
end

function Explosion:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 0.6, 0.6, self.w/2, self.h/2)
end

return Explosion
