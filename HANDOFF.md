# Handoff Notes

Last updated: 2026-03-15

## Current state

Game is fully working and published:

- `love .` — development build (always up to date)
- `bin/Ace-teroids.exe` — standalone Windows build (Love2D 11.5 fused, rebuilt this session)
- `Ace-teroids.love` — cross-platform distributable
- `docs/` → [frankhurrican.github.io/Ace-teroids](https://frankhurrican.github.io/Ace-teroids/) — web build (GitHub Pages, rebuilt this session)

All code is committed and pushed to master. Desktop and web are both confirmed working.

## Known non-issues

**Audio delay on first play (web)** — browser audio context doesn't activate until user interaction. The first click (Start) unlocks it. Brief audio delay is a browser limitation, not a bug. No workaround exists in love.js.

**verify-exe.py size mismatch after rcedit** — `rcedit` trims ~1,024 bytes of padding from the PE resource section when applying the icon. The total exe size ends up ~1KB less than `love.exe + .love`. This is expected. To confirm the fuse is correct, check that the tail of the exe matches the `.love` file:

```python
exe  = open('bin/Ace-teroids.exe', 'rb').read()
love = open('Ace-teroids.love',    'rb').read()
print(exe[-len(love):] == love)  # must be True
```

## How to rebuild after a code change

```bash
# 1. Test first
love .

# 2. Build .love + web in one go
bash build-web.sh   # rebuilds .love and docs/

# 3. Rebuild exe (icon BEFORE fuse, always start from bare runtime)
cp D:/LOVE/love.exe bin/Ace-teroids.exe
"C:/Users/frank/AppData/Roaming/npm/node_modules/rcedit/bin/rcedit-x64.exe" bin/Ace-teroids.exe --set-icon assets/icon.ico
python -c "exe=open('bin/Ace-teroids.exe','rb').read();love=open('Ace-teroids.love','rb').read();open('bin/Ace-teroids.exe','wb').write(exe+love)"

# 4. Verify exe tail matches .love
python -c "exe=open('bin/Ace-teroids.exe','rb').read();love=open('Ace-teroids.love','rb').read();print('OK' if exe[-len(love):]==love else 'FAIL')"

# 5. Test web locally before pushing
python -m http.server 8000 --directory docs
# open http://localhost:8000

# 6. Commit and push
git add -A && git commit -m "..." && git push
```

## Architecture reminder

- All game state lives in `world` table owned by `src/states/game.lua`
- Collision: `src/systems/collision.lua` — reverse loops, no collision in entities
- Audio: never call `Audio.play()` inside `draw()` callbacks
- Shooting: gated by `C.MAX_BULLETS = 3` only — no time cooldown
- Web OS check pattern: `if love.system.getOS() ~= "Web" then ... end`
- love.js uses Lua 5.1 (not LuaJIT) — `goto` and other LuaJIT extensions crash on web

## Claude Code skills added this session

Three user-level skills now live in `~/.claude/skills/`:

| Skill | Invocation | Purpose |
| ----- | ---------- | ------- |
| `love-web-audit` | `/love-web-audit` or auto | Scan codebase for Lua 5.1 / love.js incompatibilities before web publish |
| `love-publish-exe` | `/love-publish-exe` | Step-by-step Windows exe build with icon-before-fuse rule baked in |
| `love-web-debug` | `/love-web-debug` | Add on-canvas error display to debug silent web crashes |
