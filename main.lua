-- Ace-teroids — Love2D 11.x entry point.
-- This file is intentionally thin: load assets, start the state machine,
-- then delegate all four Love2D callbacks to the current state.

local Assets = require("src.assets")
local SM     = require("src.statemachine")

local sm     -- state machine instance
local cursor -- current cursor image (menu vs in-game)

function love.load()
    -- Load all images, sounds, and fonts once
    Assets.load()
    love.audio.setVolume(0.5)

    -- Hide the OS cursor; we draw our own.
    -- setGrabbed is skipped on Web — pointer lock at load time hangs the WASM runtime.
    love.mouse.setVisible(false)
    if love.system.getOS() ~= "Web" then
        love.mouse.setGrabbed(true)
    end

    cursor = Assets.images.crosshair_menu

    -- Initialise state machine and push the main menu
    sm = SM.new()
    local Menu = require("src.states.menu")
    sm:push(Menu.new(sm))
end

-- DEBUG: catch and print errors to browser console (love.js → console.log)
function love.errorhandler(msg)
    print("LOVE ERROR: " .. tostring(msg) .. "\n" .. debug.traceback("", 2))
    return function() return true end
end

function love.update(dt)
    local ok, err = xpcall(function() sm:update(dt) end, debug.traceback)
    if not ok then
        print("ERROR in love.update: " .. tostring(err))
        return
    end

    -- Switch cursor based on whether we are in gameplay
    local state = sm:current()
    local inGame = state and state.world ~= nil
    cursor = inGame and Assets.images.crosshair or Assets.images.crosshair_menu
end

function love.draw()
    sm:draw()
    -- Custom cursor drawn on top of everything
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        cursor,
        love.mouse.getX() - cursor:getWidth()  / 2,
        love.mouse.getY() - cursor:getHeight() / 2
    )
end

function love.keypressed(key)
    sm:keypressed(key)
end

function love.mousemoved(x, y)
    sm:mousemoved(x, y)
end

function love.mousepressed(x, y, button)
    local ok, err = xpcall(function() sm:mousepressed(x, y, button) end, debug.traceback)
    if not ok then
        print("ERROR in love.mousepressed: " .. tostring(err))
    end
end
