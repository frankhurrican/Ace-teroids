-- Main menu state. Handles logo, three buttons, and the instruction overlay.
--
-- Fixes from original:
--   * bgm_menu:play() was called inside Draw_Menu() (a draw function) every
--     frame. BGM now starts once in enter() via the audio manager.
--   * love.graphics.newImage() called every frame for every button image.
--     All images referenced from Assets (loaded once).
--   * Button hit regions used 6 separate hardcoded magic numbers; now use
--     constants (C.BTN_*).
--   * Draw_Instruction() was called from mousepressed() — it's a draw
--     function. State is now a flag (showInstructions) toggled in callbacks.

local Assets = require("src.assets")
local Audio  = require("src.systems.audio")
local C      = require("src.constants")

local Menu = {}
Menu.__index = Menu

function Menu.new(sm)
    return setmetatable({ sm = sm, showInstructions = false }, Menu)
end

-- ── Button hover state ──────────────────────────────────────────────────────
local hover = { start=1, option=1, exit=1, back=1 }
local played = { start=false, option=false, exit=false, back=false }

local function inBtn(mx, my, cy)
    return mx >= C.BTN_X_MIN and mx <= C.BTN_X_MAX
       and my >= cy - C.BTN_HALF_H and my <= cy + C.BTN_HALF_H
end

-- ── State lifecycle ─────────────────────────────────────────────────────────
function Menu:enter()
    Audio.playBGM("bgm_menu")
    hover   = { start=1, option=1, exit=1, back=1 }
    played  = { start=false, option=false, exit=false, back=false }
end

function Menu:exit()
    -- nothing to tear down
end

-- ── Update ───────────────────────────────────────────────────────────────────
function Menu:update(dt)
    -- intentionally empty — hover is updated in mousemoved
end

-- ── Draw ─────────────────────────────────────────────────────────────────────
function Menu:draw()
    love.graphics.setColor(1, 1, 1, 1)
    if self.showInstructions then
        love.graphics.draw(Assets.images.instruction,   100, 100, 0, 1, 1, 0, 0)
        love.graphics.draw(Assets.images.btn_back, 450, C.BTN_BACK_CY,  0, hover.back,  hover.back,  225, C.BTN_HALF_H)
    else
        love.graphics.draw(Assets.images.logo,      100,  10, 0, 1, 1, 0, 0)
        love.graphics.draw(Assets.images.btn_start, 450, C.BTN_START_CY,  0, hover.start,  hover.start,  225, C.BTN_HALF_H)
        love.graphics.draw(Assets.images.btn_option,450, C.BTN_OPTION_CY, 0, hover.option, hover.option, 225, C.BTN_HALF_H)
        love.graphics.draw(Assets.images.btn_exit,  450, C.BTN_EXIT_CY,   0, hover.exit,   hover.exit,   225, C.BTN_HALF_H)
    end
end

-- ── Input ─────────────────────────────────────────────────────────────────────
function Menu:mousemoved(mx, my)
    local function updateBtn(key, cy)
        local on = inBtn(mx, my, cy)
        hover[key] = on and 1.25 or 1
        if on and not played[key] then
            Audio.play("resize")
            played[key] = true
        elseif not on then
            played[key] = false
        end
    end

    if self.showInstructions then
        updateBtn("back", C.BTN_BACK_CY)
    else
        updateBtn("start",  C.BTN_START_CY)
        updateBtn("option", C.BTN_OPTION_CY)
        updateBtn("exit",   C.BTN_EXIT_CY)
    end
end

function Menu:mousepressed(mx, my, button)
    if button ~= 1 then return end

    if self.showInstructions then
        if inBtn(mx, my, C.BTN_BACK_CY) then
            self.showInstructions = false
        end
        return
    end

    if inBtn(mx, my, C.BTN_START_CY) then
        -- Switch to game state
        local Game = require("src.states.game")
        self.sm:replace(Game.new(self.sm))

    elseif inBtn(mx, my, C.BTN_OPTION_CY) then
        self.showInstructions = true

    elseif inBtn(mx, my, C.BTN_EXIT_CY) then
        love.event.quit()
    end
end

function Menu:keypressed(key)
    if key == "escape" then love.event.quit() end
end

return Menu
