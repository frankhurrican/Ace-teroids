-- Simple stack-based state machine.
-- Each state is a table with optional methods:
--   :enter()            called when state becomes active
--   :exit()             called when state is removed
--   :update(dt)
--   :draw()
--   :keypressed(key)
--   :mousemoved(x, y)
--   :mousepressed(x, y, button)
local SM = {}
SM.__index = SM

function SM.new()
    return setmetatable({ stack = {} }, SM)
end

function SM:current()
    return self.stack[#self.stack]
end

-- Replace the current top state (or push if stack is empty).
function SM:replace(state)
    local top = self:current()
    if top and top.exit then top:exit() end
    self.stack[#self.stack] = state
    if state.enter then state:enter() end
end

-- Push a new state on top (pauses the one below).
function SM:push(state)
    local top = self:current()
    if top and top.exit then top:exit() end
    self.stack[#self.stack + 1] = state
    if state.enter then state:enter() end
end

-- Remove the top state and resume the one below.
function SM:pop()
    local top = self:current()
    if top and top.exit then top:exit() end
    self.stack[#self.stack] = nil
    local next = self:current()
    if next and next.resume then next:resume() end
end

function SM:update(dt)
    local s = self:current()
    if s and s.update then s:update(dt) end
end

function SM:draw()
    local s = self:current()
    if s and s.draw then s:draw() end
end

function SM:keypressed(key)
    local s = self:current()
    if s and s.keypressed then s:keypressed(key) end
end

function SM:mousemoved(x, y)
    local s = self:current()
    if s and s.mousemoved then s:mousemoved(x, y) end
end

function SM:mousepressed(x, y, button)
    local s = self:current()
    if s and s.mousepressed then s:mousepressed(x, y, button) end
end

return SM
