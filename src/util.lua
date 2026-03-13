-- Shared math helpers used across all entities and systems.
local M = {}

-- Euclidean distance between two points (correct Pythagorean formula).
function M.dist(x1, y1, x2, y2)
    local dx, dy = x2 - x1, y2 - y1
    return math.sqrt(dx * dx + dy * dy)
end

-- True when two circles overlap.
function M.circlesOverlap(x1, y1, r1, x2, y2, r2)
    return M.dist(x1, y1, x2, y2) < r1 + r2
end

-- Angle in radians from point 1 toward point 2.
-- Uses math.atan2 — no division-by-zero, correct in all quadrants.
function M.angleTo(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end

-- Clamp v between lo and hi.
function M.clamp(v, lo, hi)
    return math.max(lo, math.min(hi, v))
end

-- Wrap a value into [0, limit) with screen-edge teleport logic.
-- Returns the wrapped value, or nil if no wrap needed.
function M.wrapEdge(pos, size, limit)
    if pos - size > limit then
        return -size / 2
    elseif pos + size < 0 then
        return limit + size / 2
    end
    return nil
end

return M
