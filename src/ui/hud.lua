-- HUD: draws score, player hearts, and boss HP bar.
-- Consolidates health.lua, bossHealth.lua, and the inline score print from main.lua.
-- Fix: love.graphics.newFont() was called inside the draw loop — font is now
-- loaded once via Assets and set once per frame.

local Assets = require("src.assets")
local C      = require("src.constants")

local HUD = {}

function HUD.draw(world)
    love.graphics.setFont(Assets.fonts.hud)

    -- Score (hidden during win sequence)
    if not world.win then
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.print("Score: " .. world.score, C.SCORE_X, C.SCORE_Y)
    end

    -- Player hearts
    for _, icon in ipairs(world.health_icons) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(icon.img, icon.x, icon.y, icon.angle, 1, 1, icon.w/2, icon.h/2)
    end

    -- Boss HP bar (only visible when boss is present)
    for _, icon in ipairs(world.boss_health_icons) do
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(icon.img, icon.x, icon.y, icon.angle, 1, 1, icon.w/2, icon.h/2)
    end

    -- Reset colour so subsequent draws are unaffected
    love.graphics.setColor(1, 1, 1, 1)
end

return HUD
