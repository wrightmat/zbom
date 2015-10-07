local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World G8 (Hidden Village) - Impa's House, Warp to Ancient Library --
-------------------------------------------------------------------------------

function map:on_started(destination)
  --ocarina_wind_to_L5:set_traversable_by(true)
  -- Opening doors
  local entrance_names = {
    "impa"
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