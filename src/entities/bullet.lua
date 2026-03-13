-- Player bullet.
-- Collision detection removed from here — handled centrally in game.lua
-- via collision.checkBullets(world). This file only handles movement and lifetime.

local anim8  = require("anim8")
local Assets = require("src.assets")

local Bullet = {}
Bullet.__index = Bullet

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(15, 36, 30, 36, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-2", 1), 0.1)
end

function Bullet.new(player)
    ensureAssets()
    local dir = player.angle
    local w   = Assets.images.laser:getWidth()
    local h   = Assets.images.laser:getHeight()
    local obj = {
        imgAnim   = Assets.images.laser_anim,
        anim      = BASE_ANIM:clone(),
        w         = w,
        h         = h,
        x         = player.x + player.w / 2 * math.sin(dir) * 2,
        y         = player.y - player.w / 2 * math.cos(dir) * 2,
        angle     = dir,
        speedX    = player.speedX + math.sin(dir) * 700,
        speedY    = player.speedY - math.cos(dir) * 700,
        spawnTime = love.timer.getTime(),
        isDead    = false,
        life      = 1.0,
    }
    return setmetatable(obj, Bullet)
end

function Bullet:update(dt)
    self.anim:update(dt)

    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
        return
    end

    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt

    -- Screen-edge wrap
    if self.x > love.graphics.getWidth()  then self.x = -self.w  end
    if self.y > love.graphics.getHeight() then self.y = -self.h  end
    if self.x + self.w < 0               then self.x = love.graphics.getWidth()  end
    if self.y + self.h < 0               then self.y = love.graphics.getHeight() end
end

function Bullet:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return Bullet
