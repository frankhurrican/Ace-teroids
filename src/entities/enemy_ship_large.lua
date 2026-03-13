-- Large enemy ship (stage 2). Same movement pattern as small ship but
-- with the larger sprite. Fires spread bullets periodically.

local anim8  = require("anim8")
local Assets = require("src.assets")

local EnemyShipLarge = {}
EnemyShipLarge.__index = EnemyShipLarge

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(78, 90, 156, 90, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-2", 1), 0.1)
end

function EnemyShipLarge.new(x0, y0)
    ensureAssets()
    local img = Assets.images.ship_large
    local obj = {
        imgAnim   = Assets.images.ship_large_anim,
        anim      = BASE_ANIM:clone(),
        w         = img:getWidth(),
        h         = img:getHeight(),
        x         = x0,
        y         = y0,
        newX      = x0,
        newY      = y0,
        oriX      = x0,
        angle     = math.rad(180),
        speedX    = 0,
        speedY    = 0,
        counter   = 0,
        iCounter  = 0,
        spawnTime = love.timer.getTime(),
        fireDelay = 2,
        isDead    = false,
    }
    return setmetatable(obj, EnemyShipLarge)
end

function EnemyShipLarge:update(dt, world)
    self.anim:update(dt)

    -- Straight-down phase then oscillate left/right
    if self.counter <= 100 then
        self.newY = self.y + 1
        if self.y > 50 then
            self.counter = self.counter + 1
        end
    else
        if self.iCounter >= 0 then
            self.newX    = self.x + 1
            self.iCounter = self.iCounter + 1
            if self.iCounter == 100 then self.iCounter = -1 end
        else
            self.newX    = self.x - 1
            self.iCounter = self.iCounter - 1
            if self.iCounter == -100 then self.iCounter = 1 end
        end
    end

    -- Reset on bottom exit
    if self.newY - self.h/2 > love.graphics.getHeight() then
        self.newY     = -self.h
        self.counter  = 0
        self.iCounter = 0
        self.angle    = math.rad(180)
        self.oriX     = self.x
    end

    -- Spread fire
    if love.timer.getTime() - self.spawnTime >= self.fireDelay then
        self.spawnTime = love.timer.getTime()
        local EnemyBullet = require("src.entities.enemy_bullet")
        table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y,  30,  40, 0, 0, 0))
        table.insert(world.enemy_bullets, EnemyBullet.new(self.x, self.y, -30,  40, 0, 0, 0))
    end

    self.x = self.newX
    self.y = self.newY
end

function EnemyShipLarge:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemyShipLarge
