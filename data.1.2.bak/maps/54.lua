local map = ...
local game = map:get_game()

------------------------------------------------
-- Outside World D5 (Death Mountain/Snowpeak) --
------------------------------------------------

function sensor_enter_snowpeak:on_activated()
  sol.audio.play_music("snowpeak")
  sensor_enter_mountain:set_enabled(false)
  sol.timer.start(sensor_enter_snowpeak,2000,function()
    sensor_enter_mountain:set_enabled(true)
  end)
end
function sensor_enter_mountain:on_activated()
  sol.audio.play_music("death_mountain")
  sensor_enter_snowpeak:set_enabled(false)
  sol.timer.start(sensor_enter_mountain,2000,function()
    sensor_enter_snowpeak:set_enabled(true)
  end)
end
