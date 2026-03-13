-- Debris particle. Spawned when a small asteroid is destroyed.

local Assets = require("src.assets")

local Debris = {}
Debris.__index = Debris

function Debris.new(x, y, speedX, speedY)
    local img = Assets.images.debris
    local obj = {
        img       = img,
        w         = img:getWidth(),
        h         = img:getHeight(),
        x         = x or -100,
        y         = y or -100,
        newX      = x or -100,
        newY      = y or -100,
        angle     = math.rad(math.random(-180, 180)),
        speedX    = speedX or 0,
        speedY    = speedY or 0,
        spawnTime = love.timer.getTime(),
        life      = 1,
        isDead    = false,
    }
    return setmetatable(obj, Debris)
end

function Debris:update(dt)
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

function Debris:draw()
    love.graphics.draw(self.img, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return Debris
