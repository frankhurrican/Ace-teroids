-- Static background. Created once in love.load(), drawn every frame.
-- Fix: original called Init_Background() inside love.draw(), creating a
-- new object every frame. Now it's a plain module with a single draw call.

local Assets = require("src.assets")

local Background = {}

function Background.draw()
    love.graphics.draw(Assets.images.background, 0, 0, 0, 1.2, 1.2, 0, 0)
end

return Background
