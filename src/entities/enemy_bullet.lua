-- Enemy projectile. Fired by ships and the boss.
-- Collision with player handled centrally in collision.checkEnemiesVsPlayer().

local anim8  = require("anim8")
local Assets = require("src.assets")

local EnemyBullet = {}
EnemyBullet.__index = EnemyBullet

local GRID
local BASE_ANIM

local function ensureAssets()
    if GRID then return end
    GRID      = anim8.newGrid(15, 15, 30, 15, 0, 0, 0)
    BASE_ANIM = anim8.newAnimation(GRID("1-2", 1), 0.2)
end

-- Parameters match original Init_EnemyBullet signature:
--   x0, y0        spawn position
--   offX, offY    positional offset applied when angle == 0
--   angle         firing angle (radians); 0 = straight down
--   sx, sy        parent entity speed (inherited)
function EnemyBullet.new(x0, y0, offX, offY, angle, sx, sy)
    ensureAssets()
    local img = Assets.images.bullet
    local dir = angle
    local ox, oy, vx, vy

    if dir == math.rad(0) then
        -- Straight down with fixed offset from parent position
        ox, oy = x0 + offX, y0 + offY
        vx, vy = 0, 250
    else
        ox = x0 + 24 * math.sin(dir) * 2
        oy = y0 - 24 * math.cos(dir) * 2
        vx = (sx or 0) + math.sin(dir) * 400
        vy = (sy or 0) - math.cos(dir) * 400
    end

    local obj = {
        imgAnim   = Assets.images.bullet_anim,
        anim      = BASE_ANIM:clone(),
        w         = img:getWidth(),
        h         = img:getHeight(),
        x         = ox,
        y         = oy,
        angle     = dir,
        speedX    = vx,
        speedY    = vy,
        spawnTime = love.timer.getTime(),
        life      = 4,
        isDead    = false,
    }
    return setmetatable(obj, EnemyBullet)
end

function EnemyBullet:update(dt)
    self.anim:update(dt)

    if love.timer.getTime() - self.spawnTime >= self.life then
        self.isDead = true
        return
    end

    self.x = self.x + self.speedX * dt
    self.y = self.y + self.speedY * dt
end

function EnemyBullet:draw()
    self.anim:draw(self.imgAnim, self.x, self.y, self.angle, 1, 1, self.w/2, self.h/2)
end

return EnemyBullet
