local map = ...
local game = map:get_game()

-----------------------------------------------
-- Outside World B6 (Snowpeak) - Snow drifts --
-----------------------------------------------

function sensor_snow_drift_1:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 1)
end

function sensor_snow_drift_2:on_activated()
  x, y, l = map:get_hero():get_position()
  map:get_hero():set_position(x, y, 0)
end
