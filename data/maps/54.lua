local map = ...
local game = map:get_game()

-------------------------------------------------------------------------
-- Outside World D5 (Death Mountain/Snowpeak)- Lynels (Overworld Boss) --
-------------------------------------------------------------------------

function map:on_started()
  game:set_world_snow_mode("outside_world", nil)
  
  if not game:get_value("b1720") then chest_heart_piece:set_enabled(false) end
end

for enemy in map:get_entities("lynel") do
  enemy.on_dead = function()
    if not map:has_entities("lynel") and not game:get_value("b1720") then
      chest_heart_piece:set_enabled(true)
      sol.audio.play_sound("chest_appears")
    end
  end
end

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