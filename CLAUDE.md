# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**Ace-teroids** is a 2D space shooter (Asteroids-style) built with [Love2D 11.x](https://love2d.org/) and Lua. Three stages: asteroid destruction → enemy ships → boss battle.

## Running the Game

```bash
# With Love2D 11.x installed globally (recommended for development)
love .

# Bundled executable (no install needed)
bin/Ace-teroids.exe
```

No build step. Love2D interprets Lua directly. `Ace-teroids.love` is the pre-packaged distributable.

## Project Structure

```
main.lua           ← thin entry point (~40 lines); delegates to state machine
conf.lua           ← Love2D window config (900×900, version lock "11.5")
anim8.lua          ← embedded sprite-animation library v2.3.0; do not modify
src/
  constants.lua    ← all magic numbers (speeds, HP thresholds, UI positions, etc.)
  assets.lua       ← single asset load pass (Assets.load() in love.load())
  util.lua         ← math helpers: dist(), circlesOverlap(), angleTo()
  statemachine.lua ← push/pop/replace state machine
  states/
    menu.lua       ← main menu + instructions overlay
    game.lua       ← gameplay orchestrator; owns the world object
    win.lua        ← win screen
    gameover.lua   ← game over screen (shown on player death)
  entities/        ← one file per entity type
  systems/
    collision.lua  ← all collision logic (bullets vs enemies, enemies vs player)
    audio.lua      ← BGM manager + SFX clone-play helper
    spawner.lua    ← stage initialisation (initStage1/2/3)
  ui/
    hud.lua        ← score, player hearts, boss HP bar
    background.lua ← static background draw call
```

## Architecture

### State Machine Flow

```
love.load() → SM:push(Menu)
  Menu → [Start clicked] → SM:replace(Game)
  Game → [boss killed + delay] → SM:replace(Win)
  Game → [player killed + delay] → SM:replace(GameOver)
  Win / GameOver → [click] → SM:replace(Menu)
```

### World Object (`src/states/game.lua`)

`game.lua` owns a single `world` table passed to all systems. No globals.

```lua
world = {
  player, bullets, enemies{large,medium,small},
  ships{normal,large,boss_spawn}, boss,
  beams{pre,active}, bombs, enemy_bullets,
  explosions, final_explosion, debris, pickups,
  health_icons, boss_health_icons,
  score, stage, win, death_time, boss_death_time,
  spawn_pickup(), restore_health(), on_boss_hit(),  -- callbacks
}
```

### Entity Convention

All entities in `src/entities/` follow:

- `Entity.new(...)` — constructor, returns metatable object
- `entity:update(dt)` — movement and animation only
- `entity:update(dt, world)` — for entities that spawn sub-entities (boss, enemy ships)
- `entity:draw()` — draw call

All collision is in `src/systems/collision.lua` and called from `game.lua`. Entities do not check their own collisions.

### Collision System

Uses `util.circlesOverlap(x1,y1,r1, x2,y2,r2)` (correct Pythagorean distance). All loops use **reverse `for i=#list,1,-1`** so `table.remove()` is safe. Three entry points:

- `Collision.checkBullets(world)` — player bullets vs all enemies/boss
- `Collision.checkEnemiesVsPlayer(world)` — all hazards vs player
- `Collision.checkBulletsVsBombs(world)` — player bullets can destroy bombs

### Audio System

`Audio.play(name)` clones the source so overlapping SFX work. `Audio.playBGM(name)` stops all BGM tracks then starts the named one — no-ops if already playing. Never call audio functions inside draw callbacks.

### Asset Loading

`Assets.load()` is called once in `love.load()`. All entity files reference `Assets.images.*`, `Assets.sounds.*`, `Assets.fonts.*`. No per-frame or per-entity image loading.

## Key Files to Edit for Common Tasks

| Task | File(s) |
| ---- | ------- |
| Tune gameplay values (speeds, HP, pickup rates) | `src/constants.lua` |
| Add a new enemy type | New file in `src/entities/`, register in `src/systems/spawner.lua`, add draw/update calls in `src/states/game.lua` |
| Change stage 2 spawn positions | `C.STAGE2_SHIP_XS` / `C.STAGE2_SHIPL_XS` in `src/constants.lua` |
| Add a new sound | Add to `src/assets.lua` sounds table, call `Audio.play("name")` |
| Boss attack patterns | `src/entities/boss.lua` update() |
| Adjust master volume | `love.audio.setVolume(n)` in `love.load()` in `main.lua` (currently 0.5) |

## Distribution

### Rebuilding the standalone exe (bin/Ace-teroids.exe)

The exe is Love2D 11.5 runtime + `Ace-teroids.love` fused together, with the player ship icon applied. Steps must be done in order:

```bash
# 1. Repackage the .love file
cd project root
# (use PowerShell Compress-Archive or zip) → Ace-teroids.love

# 2. Apply icon FIRST (rcedit strips appended data if run after fuse)
node_modules/rcedit/bin/rcedit-x64.exe bin/Ace-teroids.exe --set-icon assets/icon.ico

# 3. Fuse AFTER icon
python -c "
exe = open('bin/Ace-teroids.exe','rb').read()
love = open('Ace-teroids.love','rb').read()
open('bin/Ace-teroids.exe','wb').write(exe + love)
"
```

### Rebuilding the web build (docs/)

Use the build script — it handles packaging, love.js rebuild, and coi-serviceworker injection in one step:

```bash
./build-web.sh           # build only
./build-web.sh --serve   # build + serve at http://localhost:8000
```

Requires love.js (`npm install -g love.js`). `coi-serviceworker.js` is kept in the project root as a stable copy and is copied into `docs/` by the script (love.js clears the output directory on each rebuild).

For local testing without pushing: `python -m http.server 8000 --directory docs` — service workers require HTTP, so `file://` won't work.

Hosted at: https://frankhurrican.github.io/Ace-teroids/

## Lua / Love2D Notes

- Runtime: **LuaJIT (Lua 5.1)**. Use `math.atan2(y, x)` not `math.atan(y, x)` — the two-argument form is Lua 5.3+. IDE warnings about `math.atan2` being deprecated are false positives (`.luarc.json` is configured for LuaJIT).
- `love.timer.getTime()` used for cooldowns and lifetimes, not delta accumulation.
- anim8 grids are created once per entity class via `ensureAssets()` guards; animations are cloned per instance.
- Shooting is gated only by `C.MAX_BULLETS = 3` — no time-based cooldown. Rapid-clicking fires all 3 bullets immediately.
- `bin/` contains Love2D 11.5 DLLs (OpenAL32, SDL2, love, lua51, mpg123, msvcp120, msvcr120) required to run the standalone exe.

## Web Build (love.js) Pitfalls

**love.js uses plain Lua 5.1 — not LuaJIT.** Code that works on desktop can silently break on web:

| Feature | Desktop (LuaJIT) | Web (love.js / Lua 5.1) |
| ------- | ---------------- | ----------------------- |
| `goto` / `::label::` | ✅ LuaJIT extension | ❌ syntax error |
| `math.atan(y, x)` two-arg | ✅ LuaJIT | ❌ use `math.atan2` |
| `//` integer division | ✅ LuaJIT | ❌ |
| `&` `\|` bitwise ops | ✅ LuaJIT | ❌ use `bit.band` etc. |

**`goto` replacement** — use `repeat ... until true` with `break` as the Lua 5.1 `continue` idiom:

```lua
-- instead of goto next / ::next::, wrap the loop body:
for i = #list, 1, -1 do
  repeat
    if skip_condition then break end
    -- ... rest of body ...
  until true
end
```

**`love.mouse.setGrabbed(true)` at load time hangs the WASM runtime** — pointer lock requires a user gesture on web. Skip it:

```lua
if love.system.getOS() ~= "Web" then
    love.mouse.setGrabbed(true)
end
```

**Debugging web errors** — the browser canvas captures F12. Instead, wrap love callbacks in `xpcall` and render errors on canvas:

```lua
function love.update(dt)
    local ok, err = xpcall(function() sm:update(dt) end, debug.traceback)
    if not ok then
        -- store err and draw it in love.draw() via love.graphics.printf
    end
end
```
