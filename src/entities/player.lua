-- Player entity.
-- Fixes from original:
--   * t.scroe typo → score (unused anyway; score lives on world)
--   * angleUpdate used manual quadrant-switching math.atan — replaced with math.atan2
--   * Per-frame love.graphics.newImage() in Update during immunity flash — now
--     switches between two pre-loaded image references from Assets

local anim8  = require("anim8")
local Assets = require("src.assets")

local Player = {}
Player.__index = Player

local IMG      -- set on first new()
local GRID
local ANIM_NORMAL
local ANIM_DMG

local function ensureAssets()
    if IMG then return end
    IMG        = Assets.images.player
    GRID       = anim8.newGrid(48, 75, 144, 75, 0, 0, 0)
    ANIM_NORMAL = anim8.newAnimation(GRID("1-3", 1), 0.1)
    ANIM_DMG    = anim8.newAnimation(GRID("1-3", 1), 0.1)
end

function Player.new()
    ensureAssets()
    local w = Assets.images.player:getWidth()
    local h = Assets.images.player:getHeight()
    local obj = {
        imgAnim   = Assets.images.player_anim,
        anim      = ANIM_NORMAL:clone(),
        w         = w,
        h         = h,
        x         = love.graphics.getWidth()  / 2 - w / 2,
        y         = love.graphics.getHeight() / 2 - h / 2 + 200,
        speedX    = 0,
        speedY    = 0,
        angle     = 0,
        isDead    = false,
        isImmune  = false,
        dmgTime   = 0,
    }
    return setmetatable(obj, Player)
end

function Player:update(dt)
    self.anim:update(dt)

    -- Immunity flash: swap sprite reference (no newImage each frame)
    if love.timer.getTime() - self.dmgTime <= 2 then
        self.isImmune = true
        self.imgAnim  = Assets.images.player_dmg
    else
        self.isImmune = false
        self.imgAnim  = Assets.images.player_anim
    end

    -- Thrust input (right-mouse or W key)
    if love.mouse.isDown(2) or love.keyboard.isDown("w") then
        self.speedX = self.speedX + 10 * math.sin(self.angle) * dt
        self.speedY = self.speedY - 10 * math.cos(self.angle) * dt
    end

    -- Aim toward mouse using math.atan2 — no division-by-zero, correct everywhere
    local mx, my = love.mouse.getPosition()
    self.angle = math.atan2(mx - self.x, self.y - my)

    -- Move
    self.x = self.x + self.speedX
    self.y = self.y + self.speedY

    -- Screen-edge wrap
    if self.x > love.graphics.getWidth()  then self.x = -self.w  end
    if self.y > love.graphics.getHeight() then self.y = -self.h  end
    if self.x + self.w < 0               then self.x = love.graphics.getWidth()  end
    if self.y + self.h < 0               then self.y = love.graphics.getHeight() end
end

function Player:draw()
    self.anim:draw(
        self.imgAnim,
        self.x, self.y,
        self.angle,
        1, 1,
        self.w / 2, self.h / 2
    )
end

return Player
