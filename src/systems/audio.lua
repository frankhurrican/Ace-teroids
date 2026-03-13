-- Centralised audio manager.
--
-- Fixes from original:
--   * BGM was called inside Draw_Menu() (a draw function) every frame → played
--     60x/sec. Now BGM only switches when the name actually changes.
--   * SFX used source:stop()+play() on a single shared source, so two
--     simultaneous explosions would cut each other off. Now SFX are cloned so
--     multiple instances can play at the same time.

local Assets  -- set lazily on first use to avoid load-order issues

local Audio = {}
local currentBGM = nil   -- name of the currently playing BGM track

-- Play a one-shot SFX. Clones the source so overlapping sounds work.
function Audio.play(name, volume)
    if not Assets then Assets = require("src.assets") end
    local src = Assets.sounds[name]
    if not src then return end
    local clone = src:clone()
    if volume then clone:setVolume(volume) end
    clone:play()
end

-- Play a SFX with a random volume in [minVol, maxVol].
function Audio.playRandom(name, minVol, maxVol)
    Audio.play(name, minVol + math.random() * (maxVol - minVol))
end

-- Switch BGM. No-ops if the requested track is already playing.
function Audio.playBGM(name)
    if currentBGM == name then return end
    if not Assets then Assets = require("src.assets") end
    -- Stop all BGM tracks
    for _, key in ipairs({"bgm_menu","bgm_normal","bgm_boss","bgm_win"}) do
        Assets.sounds[key]:stop()
    end
    currentBGM = name
    if name then
        Assets.sounds[name]:setLooping(true)
        Assets.sounds[name]:play()
    end
end

function Audio.stopBGM()
    Audio.playBGM(nil)
end

return Audio
