-- Large multi-frame explosion used for the boss death sequence.

local anim8  = require("anim8")
local Assets = require("src.assets")

local FinalExplosion = {}
FinalExplosion.__index = FinalExplosion

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(96, 96, 480, 288, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-5", "1-3"), 0.1)
end

function FinalExplosion.new(x, y)
    ensureAssets()
    local obj = {
        imgAnim   = Assets.images.final_explosion,
        anim      = BASE_ANIM:clone(),
        w         = 96,
        h         = 96,
        x         = x or 0,
        y         = y or 0,
        angle     = math.rad(math.random(-180, 180)),
        spawnTime = love.timer.getTime(),
        life      = 1.5,
        isDead    = false,
    }
    return setmetatable(obj, FinalExplosion)
end

function FinalExplosion:update(dt)
    self.anim:update(dt)
    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
    end
end

-- Drawn as 5 offset copies in game.lua for the boss-death spectacle
function FinalExplosion:draw(ox, oy, sx, sy)
    sx = sx or 3
    sy = sy or 3
    self.anim:draw(self.imgAnim, ox, oy, self.angle, sx, sy, self.w/2, self.h/2)
end

return FinalExplosion
