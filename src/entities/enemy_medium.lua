-- Medium asteroid. Spawned when a large asteroid is destroyed.
-- Spawns two small asteroids on death.

local Assets = require("src.assets")

local EnemyMedium = {}
EnemyMedium.__index = EnemyMedium

function EnemyMedium.new(spawnX, spawnY)
    local img = Assets.images.enemy_medium
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
        speedX = math.random(-120, 120),
        speedY = math.random(-120, 120),
        isDead = false,
    }
    return setmetatable(obj, EnemyMedium)
end

function EnemyMedium:update(dt)
    self.newX = self.x + self.speedX * dt
    self.newY = self.y + self.speedY * dt

    if self.newX > love.graphics.getWidth()  then self.newX = -self.w end
    if self.newY > love.graphics.getHeight() then self.newY = -self.h end
    if self.newX + self.w < 0 then self.newX = love.graphics.getWidth()  end
    if self.newY + self.h < 0 then self.newY = love.graphics.getHeight() end

    self.x = self.newX
    self.y = self.newY
end

function EnemyMedium:draw()
    love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemyMedium
