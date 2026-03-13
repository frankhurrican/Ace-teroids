-- Small enemy ship (stage 2). Three movement phases: straight down →
-- circle → sine wave. Fires one bullet at player every fireDelay seconds.
-- Passes world to update() so it can insert into world.enemy_bullets.

local anim8  = require("anim8")
local Assets = require("src.assets")

local EnemyShip = {}
EnemyShip.__index = EnemyShip

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(48, 48, 96, 48, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-2", 1), 0.1)
end

function EnemyShip.new(x0, y0)
    ensureAssets()
    local img = Assets.images.ship
    local obj = {
        imgAnim    = Assets.images.ship_anim,
        anim       = BASE_ANIM:clone(),
        w          = img:getWidth(),
        h          = img:getHeight(),
        x          = x0,
        y          = y0,
        newX       = x0,
        newY       = y0,
        oriX       = x0,
        angle      = math.rad(180),
        speedX     = 0,
        speedY     = 0,
        counter    = 0,
        i          = 0,
        asinCord   = -math.pi / 2,
        iCounter   = 0,
        spawnTime  = love.timer.getTime(),
        fireDelay  = 2,
        isDead     = false,
    }
    return setmetatable(obj, EnemyShip)
end

function EnemyShip:update(dt, world)
    self.anim:update(dt)

    -- Phase 1: straight down until counter reaches 250
    if self.counter <= 250 then
        self.newY = self.y + 2
        if self.y > 50 then
            self.counter = self.counter + 2
        end

    -- Phase 2: circle
    elseif self.i <= 360 then
        self.newX  = self.x + 100 * math.sin(math.rad(self.i)) * dt
        self.newY  = self.y + 100 * math.cos(math.rad(self.i)) * dt
        self.i     = self.i + 1
        self.angle = math.rad(180 - self.i) + math.pi * 2

    -- Phase 3: sine-wave descent
    else
        self.newX    = self.oriX + (math.sin(self.asinCord) + 1) * 100
        self.asinCord = self.asinCord + 0.02
        self.newY    = self.y + 2

        local lo = -math.pi/2 + 2*math.pi*self.iCounter
        local hi =  math.pi/2 + 2*math.pi*self.iCounter
        if self.asinCord >= lo and self.asinCord <= hi then
            self.angle = math.pi - math.atan2(math.abs(self.newX - self.x), math.abs(self.newY - self.y))
        elseif self.asinCord >= hi and self.asinCord <= 3*math.pi/2 + 2*math.pi*self.iCounter then
            self.angle = math.pi + math.atan2(math.abs(self.newX - self.x), math.abs(self.newY - self.y))
        else
            self.iCounter = self.iCounter + 1
        end
    end

    -- Reset when it scrolls off the bottom
    if self.newY - self.h/2 > love.graphics.getHeight() then
        self.newY     = -self.h
        self.i        = 0
        self.counter  = 0
        self.asinCord = -math.pi / 2
        self.iCounter = 0
        self.angle    = math.rad(180)
        self.oriX     = self.x
    end

    -- Fire bullet toward current facing angle
    if love.timer.getTime() - self.spawnTime >= self.fireDelay then
        self.spawnTime = love.timer.getTime()
        local EnemyBullet = require("src.entities.enemy_bullet")
        table.insert(world.enemy_bullets,
            EnemyBullet.new(self.x, self.y, 0, 0, self.angle, self.speedX, self.speedY))
    end

    self.x = self.newX
    self.y = self.newY
end

function EnemyShip:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemyShip
