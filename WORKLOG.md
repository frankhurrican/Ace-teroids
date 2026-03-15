# Worklog

## 2026-03-12 — Full overhaul + polish

### Overhaul (prior conversation)

Rewrote the entire project from a flat 22-file monolith into a clean `src/` layout targeting Love2D 11.5. Fixed ~10 critical bugs from the original:

- Division-by-zero in distance checks → replaced with `util.circlesOverlap()`
- `table.remove()` inside `ipairs` loops → converted all to reverse `for i=#list,1,-1`
- Wrong distance formula → correct Pythagorean distance in `util.lua`
- Per-frame `love.graphics.newImage()` calls → single `Assets.load()` in `love.load()`
- BGM called every frame inside draw → `Audio.playBGM()` no-ops if already playing
- Missing game-over state → added `src/states/gameover.lua`
- `math.atan(y,x)` (Lua 5.3 only) → `math.atan2(y,x)` (LuaJIT/Lua 5.1)

### This session

- **Verified** game runs correctly end-to-end (`love .`)
- **Deleted** 19 superseded root-level `.lua` files
- **GitHub Pages web build** — packaged with `love.js`, added `coi-serviceworker.js` to fix `SharedArrayBuffer` error on GitHub Pages
- **Standalone exe** — fused Love2D 11.5 runtime + `Ace-teroids.love`; upgraded bin/ DLLs from 0.10.1 → 11.5
- **Exe icon** — applied player ship sprite as Windows icon via `rcedit` (icon first, fuse second — order matters)
- **Master volume** — set to 50% via `love.audio.setVolume(0.5)` in `main.lua`
- **Menu background** — `Background.draw()` was missing from `src/states/menu.lua`; added
- **Rapid fire restored** — removed `BULLET_COOLDOWN` (0.5s fixed cadence); firing is now gated only by `C.MAX_BULLETS = 3`
- **README** updated with browser play link, download instructions, and correct controls

### Known gotcha: rebuilding the exe

`rcedit` rewrites the PE and strips any data appended after the PE structure. Always apply the icon **before** fusing the `.love` file. See CLAUDE.md Distribution section for the full procedure.

---

## 2026-03-13 — Bug fixes + web compatibility

- **Bombs absorb bullets** — `checkBulletsVsBombs` was destroying bombs on hit; changed so only the bullet dies
- **Bossboom sound one-shot** — `Audio.play("bossboom")` was inside `draw()` firing every frame; moved to the `on_boss_hit` one-shot trigger in `game.lua`
- **heart.png rgba16** — was saved as 16-bit PNG (Photoshop default); love.js WebAssembly doesn't support rgba16; converted to 8-bit RGBA
- **conf.lua version** — changed `11.5` → `11.4` to match love.js runtime (was showing compatibility warning)
- **Web freeze on Start** — `love.mouse.setGrabbed(true)` triggers browser pointer lock at load time which hangs the WASM runtime; now skipped when `love.system.getOS() == "Web"`
- **Audio delay on web** — inherent browser audio policy (context unlocks on first user interaction); not fully fixable, acceptable behaviour

---

## 2026-03-15 — Web fix, local dev tooling, Claude Code skills

### Root cause of web freeze identified and fixed

The real crash was a **Lua 5.1 syntax error** in `src/systems/collision.lua`. The code used `goto next_bullet` / `::next_bullet::` which is a LuaJIT extension not available in Lua 5.1 (which love.js uses). Desktop worked because LuaJIT supports `goto`; web crashed silently on the first `require` of the file.

Fix: replaced all `goto` / `::label::` with `repeat ... until true` + `break` — the standard Lua 5.1 `continue` idiom.

The earlier `setGrabbed` fix (2026-03-13) was valid but incomplete — the `goto` syntax error was the actual cause of "nothing happens on Start".

### Debugging technique developed

Browser canvas captures F12, making DevTools inaccessible. Solution: wrap love callbacks in `xpcall` and render caught errors directly on the canvas via `love.graphics.printf`. Error message, file, line, and full stack trace appear on screen without any browser tooling. (Scaffolding added, used to find the `goto` bug, then removed before shipping.)

### Local web testing setup

Added `build-web.sh` — one command rebuilds `.love`, runs `love.js`, copies `coi-serviceworker.js`, patches `index.html`, and optionally starts a local server:

```bash
./build-web.sh          # build only
./build-web.sh --serve  # build + serve at http://localhost:8000
```

`coi-serviceworker.js` saved to project root so it survives love.js rebuilding `docs/`.

### CLAUDE.md updated

Added "Web Build (love.js) Pitfalls" section documenting the Lua 5.1 vs LuaJIT compatibility gap, the `goto` fix pattern, `setGrabbed` guard, and on-canvas debug technique. Account-wide `~/.claude/CLAUDE.md` also updated with a Love2D web section.

### Claude Code skills created

Three reusable skills added to `~/.claude/skills/` (available in any Love2D project):

| Skill | Type | What it does |
| ----- | ---- | ------------ |
| `love-web-audit` | Analysis | Runs `audit.sh` + reports Lua 5.1 / love.js incompatibilities with file:line and fixes |
| `love-publish-exe` | User-only | Step-by-step Windows exe build; icon-before-fuse rule baked in; `verify-exe.py` checks tail integrity |
| `love-web-debug` | User-only | Adds / removes xpcall + on-canvas error display scaffolding in `main.lua` |

Each skill includes supporting scripts, references, and/or examples in subdirectories.

### Exe and web rebuilt

Both `bin/Ace-teroids.exe` and `docs/` rebuilt from clean state with all fixes in place. Exe tail verification confirms correct fusion.

### Note: verify-exe.py and rcedit

`rcedit` trims ~1,024 bytes of PE padding when applying the icon, so the total fused exe size is ~1KB less than `runtime + .love`. The verify script's total-size check will report a false failure after rcedit. Use tail verification instead: `exe[-len(love):] == love` must be `True`.
