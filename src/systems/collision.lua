-- Collision helpers used by game.lua.
--
-- All collision detection is centralised here and in game.lua rather than
-- scattered across entity Update() functions. This fixes:
--   * table.remove() inside ipairs() — replaced with reverse for-loops
--   * Wrong distance formula (tempX/math.cos) — replaced with util.dist()
--   * Beam only checking X axis — now checks both X and Y

local util  = require("src.util")
local Audio = require("src.systems.audio")

local Collision = {}

-- Remove the last heart icon and apply damage to the player.
-- Handles kill (last heart) vs hurt (remaining hearts) logic.
-- No-ops if player is immune or already dead.
function Collision.damagePlayer(world)
    local player = world.player
    if player.isImmune or player.isDead then return end

    local hp = #world.health_icons
    if hp <= 1 then
        if hp == 1 then table.remove(world.health_icons, 1) end
        player.isDead    = true
        world.death_time = love.timer.getTime()
    else
        table.remove(world.health_icons, hp)
        Audio.playRandom("hurt", 0.6, 1.0)
        player.dmgTime = love.timer.getTime()
    end
end

-- Check every player bullet against all enemy groups.
-- On hit: marks both bullet and enemy isDead, increments score,
-- optionally spawns a health pickup.
-- Uses reverse iteration so table.remove() is safe.
function Collision.checkBullets(world)
    local C = require("src.constants")

    for i = #world.bullets, 1, -1 do
        local b = world.bullets[i]
        if b.isDead then goto next_bullet end

        -- vs asteroids
        local asteroid_groups = {
            { list = world.enemies.large },
            { list = world.enemies.medium },
            { list = world.enemies.small, pickup_chance = C.PICKUP_CHANCE_SMALL },
        }
        for _, grp in ipairs(asteroid_groups) do
            if b.isDead then break end
            for j = #grp.list, 1, -1 do
                local e = grp.list[j]
                if not e.isDead and util.circlesOverlap(b.x, b.y, b.w/2, e.x, e.y, e.w/2) then
                    e.isDead      = true
                    b.isDead      = true
                    world.score   = world.score + 1
                    if grp.pickup_chance and math.random(100) <= grp.pickup_chance then
                        world.spawn_pickup(e.x, e.y)
                    end
                    break
                end
            end
        end
        if b.isDead then goto next_bullet end

        -- vs stage-2 ships
        local ship_groups = {
            { list = world.ships.normal,     pickup_chance = C.PICKUP_CHANCE_SHIP },
            { list = world.ships.large },
            { list = world.ships.boss_spawn, pickup_chance = C.PICKUP_CHANCE_BOSS_SPAWN },
        }
        for _, grp in ipairs(ship_groups) do
            if b.isDead then break end
            for j = #grp.list, 1, -1 do
                local e = grp.list[j]
                if not e.isDead and util.circlesOverlap(b.x, b.y, b.w/2, e.x, e.y, e.w/2) then
                    e.isDead    = true
                    b.isDead    = true
                    world.score = world.score + 1
                    if grp.pickup_chance and math.random(100) <= grp.pickup_chance then
                        world.spawn_pickup(e.x, e.y)
                    end
                    break
                end
            end
        end
        if b.isDead then goto next_bullet end

        -- vs boss
        if world.boss and not world.boss.isDead then
            local boss = world.boss
            if util.circlesOverlap(b.x, b.y, b.w/2, boss.x, boss.y, boss.w/2) then
                b.isDead  = true
                world.on_boss_hit()
            end
        end

        ::next_bullet::
    end
end

-- Check all enemy projectiles / bodies against the player.
function Collision.checkEnemiesVsPlayer(world)
    local player = world.player
    if player.isDead then return end

    local pr = player.w / 2

    local function hit() Collision.damagePlayer(world) end

    -- Asteroids (die on contact)
    for _, grp in ipairs({world.enemies.large, world.enemies.medium, world.enemies.small}) do
        for i = #grp, 1, -1 do
            local e = grp[i]
            if not e.isDead and util.circlesOverlap(e.x, e.y, e.w/2, player.x, player.y, pr) then
                e.isDead = true
                hit()
            end
        end
    end

    -- Stage-2 ships (die on contact)
    for _, grp in ipairs({world.ships.normal, world.ships.large, world.ships.boss_spawn}) do
        for i = #grp, 1, -1 do
            local e = grp[i]
            if not e.isDead and util.circlesOverlap(e.x, e.y, e.w/2, player.x, player.y, pr) then
                e.isDead = true
                hit()
            end
        end
    end

    -- Enemy bullets (die on contact)
    for i = #world.enemy_bullets, 1, -1 do
        local b = world.enemy_bullets[i]
        if not b.isDead and util.circlesOverlap(b.x, b.y, b.w/2, player.x, player.y, pr) then
            b.isDead = true
            hit()
        end
    end

    -- Bombs (do NOT die — they keep falling after hitting player)
    for _, bomb in ipairs(world.bombs) do
        if not bomb.isDead and util.circlesOverlap(bomb.x, bomb.y, bomb.w/2, player.x, player.y, pr) then
            hit()
        end
    end

    -- Boss body (does not die on contact)
    if world.boss and not world.boss.isDead then
        local boss = world.boss
        if util.circlesOverlap(boss.x, boss.y, boss.w/2, player.x, player.y, pr) then
            hit()
        end
    end

    -- Beam: fixed — now checks BOTH X range and Y range.
    -- Original only checked X, so player was safe above/below the beam.
    for _, beam in ipairs(world.beams.active) do
        if not beam.isDead then
            local inX = math.abs(player.x - beam.x) < 45
            local inY = player.y >= beam.y   -- beam fires downward from beam.y
            if inX and inY then
                hit()
            end
        end
    end

    -- Beam pre-charge (small hitbox around spawn point)
    for _, bp in ipairs(world.beams.pre) do
        if not bp.isDead then
            if util.circlesOverlap(bp.x, bp.y, 18, player.x, player.y, pr) then
                hit()
            end
        end
    end

    -- Health pickups (player collects)
    for i = #world.pickups, 1, -1 do
        local p = world.pickups[i]
        if not p.isDead and util.circlesOverlap(p.x, p.y, p.w/2, player.x, player.y, pr) then
            p.isDead = true
            world.restore_health()
        end
    end
end

-- Bullets vs bombs: player bullets can destroy bombs.
-- (Bug fix: original never set bomb.isDead on bullet hit.)
function Collision.checkBulletsVsBombs(world)
    for i = #world.bombs, 1, -1 do
        local bomb = world.bombs[i]
        if not bomb.isDead then
            for j = #world.bullets, 1, -1 do
                local b = world.bullets[j]
                if not b.isDead and util.circlesOverlap(bomb.x, bomb.y, bomb.w/2, b.x, b.y, b.w/2) then
                    b.isDead    = true
                    bomb.isDead = true   -- fixed: was commented out in original
                    break
                end
            end
        end
    end
end

return Collision
