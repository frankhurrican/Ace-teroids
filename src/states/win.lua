-- Win screen. Shown after the boss dies and the delay elapses.
-- Fixes from original:
--   * love.graphics.newImage() and newFont() were called every frame
--   * love.graphics.clear() was called mid-draw (invalid in Love2D 11)
--   * Win logic was buried inside Draw_Game_Content() behind flag checks

local Assets     = require("src.assets")
local Audio      = require("src.systems.audio")
local Background = require("src.ui.background")

local Win = {}
Win.__index = Win

function Win.new(sm, score)
    return setmetatable({ sm = sm, score = score }, Win)
end

function Win:enter()
    Audio.playBGM("bgm_win")
end

function Win:exit() end

function Win:update(dt)
    -- intentionally empty
end

function Win:draw()
    Background.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Assets.images.win_screen, 300, 250)
    love.graphics.setFont(Assets.fonts.win)
    love.graphics.print("Score: " .. self.score, 250, 550)
end

function Win:keypressed(key)
    if key == "escape" then love.event.quit() end
end

function Win:mousepressed(mx, my, button)
    if button == 1 then
        -- Return to menu on click
        local Menu = require("src.states.menu")
        self.sm:replace(Menu.new(self.sm))
    end
end

return Win
