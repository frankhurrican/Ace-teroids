-- Small asteroid. Spawned when a medium asteroid is destroyed.
-- Spawns debris particles on death.

local Assets = require("src.assets")

local EnemySmall = {}
EnemySmall.__index = EnemySmall

function EnemySmall.new(spawnX, spawnY)
    local img = Assets.images.enemy_small
    local x   = spawnX or -100
    local y   = spawnY or -100
    local obj = {
        img    = img,
        w      = img:getWidth(),
        h      = img:getHeight(),
        x      = x,
        y      = y,
        newX   = x,
        newY   = y,
        angle  = math.rad(math.random(-180, 180)),
        speedX = math.random(-150, 150),
        speedY = math.random(-150, 150),
        isDead = false,
    }
    return setmetatable(obj, EnemySmall)
end

function EnemySmall:update(dt)
    self.newX = self.x + self.speedX * dt
    self.newY = self.y + self.speedY * dt

    if self.newX > love.graphics.getWidth()  then self.newX = -self.w end
    if self.newY > love.graphics.getHeight() then self.newY = -self.h end
    if self.newX + self.w < 0 then self.newX = love.graphics.getWidth()  end
    if self.newY + self.h < 0 then self.newY = love.graphics.getHeight() end

    self.x = self.newX
    self.y = self.newY
end

function EnemySmall:draw()
    love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemySmall
