-- Boss bomb (phase 3). Falls a random distance then stops.
-- Collision with player handled centrally in collision.checkEnemiesVsPlayer().
-- Collision with player bullets handled in collision.checkBulletsVsBombs().
--
-- Fixes from original:
--   * self.isDead never set true — bombs now die when hit by a bullet
--     (collision.checkBulletsVsBombs sets isDead; life-timer also kills them)
--   * Dead variables removed: reached, doOnce (never read)
--   * Timer-based kill re-enabled (was commented out)

local anim8  = require("anim8")
local Assets = require("src.assets")

local Bomb = {}
Bomb.__index = Bomb

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(134, 134, 1072, 134, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-8", 1), 0.1)
end

function Bomb.new(x0, y0)
    ensureAssets()
    local obj = {
        imgAnim      = Assets.images.bomb,
        anim         = BASE_ANIM:clone(),
        w            = 134,
        h            = 134,
        x            = x0,
        y            = y0,
        newX         = x0,
        newY         = y0,
        angle        = math.rad(180),
        speedX       = 0,
        speedY       = 0,
        counter      = 0,
        distanceToGo = math.random(100, 500),
        spawnTime    = love.timer.getTime(),
        life         = 3,
        isDead       = false,
    }
    return setmetatable(obj, Bomb)
end

-- Called by boss.lua each frame to advance the animation
function Bomb:updateAnim(dt)
    self.anim:update(dt)
end

function Bomb:update(dt)
    self.anim:update(dt)

    -- Kill by timer
    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
        return
    end

    -- Fall until distanceToGo is reached, then hover
    if self.counter <= self.distanceToGo then
        self.newY    = self.y + 2
        self.counter = self.counter + 2
    end

    self.x = self.newX
    self.y = self.newY
end

function Bomb:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return Bomb
