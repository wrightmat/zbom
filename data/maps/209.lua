local map = ...
local game = map:get_game()

-------------------------------------------
-- Dungeon 5: Snowpeak Caverns (Floor 2) --
-------------------------------------------

function map:on_started(destination)
  boss_stalfos:set_enabled(false)
end

function sensor_boss:on_activated()
  if boss_stalfos ~= nil then
    map:close_doors("door_boss")
    boss_stalfos:set_enabled(true)
    sol.audio.play_music("boss")
  end
end

if boss_stalfos ~= nil then
  function boss_stalfos:on_dead()
    map:open_doors("door_boss")
    sol.audio.play_sound("boss_killed")
    boss_heart:set_enabled(true)
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_snow")
    end)
  end
end
