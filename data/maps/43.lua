local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World D8 (Hyrule Field)  --
--------------------------------------

function sensor_enter_field:on_activated()
  sol.audio.play_music("field")
  sensor_enter_field:set_enabled(false)
  sol.timer.start(sensor_enter_field,2000,function()
    sensor_enter_field:set_enabled(true)
  end)
end
