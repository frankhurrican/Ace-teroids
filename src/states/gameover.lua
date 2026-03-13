-- Game over state. Previously missing — player death just returned to menu
-- silently. Now shows the lose screen with the final score and a restart prompt.

local Assets     = require("src.assets")
local Audio      = require("src.systems.audio")
local Background = require("src.ui.background")

local GameOver = {}
GameOver.__index = GameOver

function GameOver.new(sm, score)
    return setmetatable({ sm = sm, score = score }, GameOver)
end

function GameOver:enter()
    Audio.stopBGM()
end

function GameOver:exit() end

function GameOver:update(dt) end

function GameOver:draw()
    Background.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(Assets.images.lose_screen, 250, 250)
    love.graphics.setFont(Assets.fonts.hud)
    love.graphics.print("Score: " .. self.score, 350, 500)
    love.graphics.print("Click to retry", 310, 560)
end

function GameOver:keypressed(key)
    if key == "escape" then love.event.quit() end
end

function GameOver:mousepressed(mx, my, button)
    if button == 1 then
        local Menu = require("src.states.menu")
        self.sm:replace(Menu.new(self.sm))
    end
end

return GameOver
