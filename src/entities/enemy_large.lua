-- Large asteroid (stage 1). Spawns two medium asteroids on death.
-- Collision with player handled by collision.checkEnemiesVsPlayer() in game.lua.
-- Fixes: removed unused variables (i, asinCord, iCounter, smooth).

local Assets = require("src.assets")

local EnemyLarge = {}
EnemyLarge.__index = EnemyLarge

function EnemyLarge.new()
    local img = Assets.images.enemy_large
    local w   = img:getWidth()
    local h   = img:getHeight()

    -- Spawn away from the centre so the player has breathing room
    local x, y
    repeat
        x = math.random(0, love.graphics.getWidth())
        y = math.random(0, love.graphics.getHeight())
    until x < 300 or x > 700 or y < 200 or y > 600

    local obj = {
        img    = img,
        w      = w,
        h      = h,
        x      = x,
        y      = y,
        newX   = x,
        newY   = y,
        angle  = math.rad(math.random(-180, 180)),
        speedX = math.random(-80, 80),
        speedY = math.random(-80, 80),
        isDead = false,
    }
    return setmetatable(obj, EnemyLarge)
end

function EnemyLarge:update(dt)
    self.newX = self.x + self.speedX * dt
    self.newY = self.y + self.speedY * dt

    -- Screen-edge wrap
    if self.newX - self.w > love.graphics.getWidth()  then self.newX = -self.w / 2 end
    if self.newY - self.h > love.graphics.getHeight() then self.newY = -self.h / 2 end
    if self.newX + self.w < 0 then self.newX = love.graphics.getWidth()  + self.w / 2 end
    if self.newY + self.h < 0 then self.newY = love.graphics.getHeight() + self.h / 2 end

    self.x = self.newX
    self.y = self.newY
end

function EnemyLarge:draw()
    love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemyLarge
