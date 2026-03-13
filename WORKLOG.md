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
