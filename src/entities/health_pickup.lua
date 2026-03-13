-- Collectible health pickup. Drifts for 6 seconds.
-- Collision with player handled by collision.checkEnemiesVsPlayer() in game.lua,
-- which calls world.restore_health() — this entity only handles movement/lifetime.
--
-- Fix: removed per-frame collision check after collection (self.once flag removed;
-- pickup is marked isDead immediately on collection by the collision system).

local anim8  = require("anim8")
local Assets = require("src.assets")

local HealthPickup = {}
HealthPickup.__index = HealthPickup

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(48, 36, 192, 36, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-4", 1), 0.2)
end

function HealthPickup.new(x, y, speedX, speedY)
    ensureAssets()
    local obj = {
        imgAnim   = Assets.images.hp_pickup,
        anim      = BASE_ANIM:clone(),
        w         = 48,
        h         = 36,
        x         = x or -100,
        y         = y or -100,
        newX      = x or -100,
        newY      = y or -100,
        angle     = math.rad(0),
        speedX    = speedX or 0,
        speedY    = speedY or 0,
        spawnTime = love.timer.getTime(),
        life      = 6,
        isDead    = false,
    }
    return setmetatable(obj, HealthPickup)
end

function HealthPickup:update(dt)
    self.anim:update(dt)

    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
        return
    end

    self.newX = self.x + self.speedX * dt
    self.newY = self.y + self.speedY * dt

    if self.newX > love.graphics.getWidth()  then self.newX = -self.w end
    if self.newY > love.graphics.getHeight() then self.newY = -self.h end
    if self.newX + self.w < 0 then self.newX = love.graphics.getWidth()  end
    if self.newY + self.h < 0 then self.newY = love.graphics.getHeight() end

    self.x = self.newX
    self.y = self.newY
end

function HealthPickup:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1.5, self.w/2, self.h/2)
end

return HealthPickup
