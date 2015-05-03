local map = ...
local game = map:get_game()

------------------------------------------------------------
-- Outside World E9 (Lon Lon Ranch)                       --
------------------------------------------------------------

function map:on_started(destination)
  -- Opening doors
  local entrance_names = {
    "ranch"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1
	  and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end
end
