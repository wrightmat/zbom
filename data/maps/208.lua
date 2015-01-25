local map = ...
local game = map:get_game()

-------------------------------------------
-- Dungeon 5: Snowpeak Caverns (Floor 1) --
-------------------------------------------

function map:on_started(destination)
  map:set_doors_open("door_miniboss")
  miniboss_chu:set_enabled(false)
end

function sensor_miniboss:on_activated()
  if miniboss_chu ~= nil nil then
    map:close_doors("door_miniboss")
    miniboss_chu:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end

if miniboss_chu ~= nil then
  function miniboss_chu:on_dead()
    map:open_doors("door_miniboss")
    sol.audio.play_sound("boss_killed")
    sol.timer.start(1000, function()
      sol.audio.play_music("temple_snow")
    end)
  end
end
