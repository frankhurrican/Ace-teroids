# Handoff Notes

Last updated: 2026-03-13

## Current state

Game is fully working and published:
- `love .` — development build (always up to date)
- `bin/Ace-teroids.exe` — standalone Windows build (Love2D 11.5 fused)
- `Ace-teroids.love` — cross-platform distributable
- `docs/` → https://frankhurrican.github.io/Ace-teroids/ — web build (GitHub Pages)

All code is committed and pushed to master.

## Known remaining web issue

**Audio delay on first play** — browser audio context doesn't activate until user interaction. The first click (Start) unlocks it. There may be a brief moment where the game starts but audio is slightly delayed. This is a browser limitation, not a code bug. love.js has no workaround.

## What was fixed this session

| Bug | Fix location |
|-----|-------------|
| Bombs destroyed by bullets | `src/systems/collision.lua` — bullet dies, bomb survives |
| Bossboom sound every frame | `src/states/game.lua` — moved `Audio.play("bossboom")` from `draw()` to `on_boss_hit` |
| heart.png rgba16 crash on web | `assets/heart.png` — converted to 8-bit RGBA |
| Version mismatch warning on web | `conf.lua` — `11.5` → `11.4` |
| Web freeze after clicking Start | `main.lua` — `setGrabbed` skipped when `OS == "Web"` |

## How to rebuild everything after a code change

```bash
# 1. Test first
love .

# 2. Repackage .love (PowerShell)
Remove-Item Ace-teroids.love
Compress-Archive -Path main.lua,conf.lua,anim8.lua,src,assets -DestinationPath Ace-teroids.zip
Rename-Item Ace-teroids.zip Ace-teroids.love

# 3. Rebuild exe (icon BEFORE fuse)
cp D:/LOVE/love.exe bin/Ace-teroids.exe
node_modules/rcedit/bin/rcedit-x64.exe bin/Ace-teroids.exe --set-icon assets/icon.ico
python -c "exe=open('bin/Ace-teroids.exe','rb').read();love=open('Ace-teroids.love','rb').read();open('bin/Ace-teroids.exe','wb').write(exe+love)"

# 4. Rebuild web
Remove-Item -Recurse docs
love.js Ace-teroids.love docs/ --title "Ace-teroids" --memory 33554432
curl https://raw.githubusercontent.com/gzuidhof/coi-serviceworker/master/coi-serviceworker.js -o docs/coi-serviceworker.js
# Add <script src="coi-serviceworker.js"></script> as first line in <head> of docs/index.html

# 5. Commit
git add -A
git commit -m "..."
git push
```

## Architecture reminder

- All game state lives in `world` table owned by `src/states/game.lua`
- Collision: `src/systems/collision.lua` — reverse loops, no collision in entities
- Audio: never call `Audio.play()` inside `draw()` callbacks
- Shooting: gated by `C.MAX_BULLETS = 3` only — no time cooldown
- Web OS check pattern: `if love.system.getOS() ~= "Web" then ... end`
