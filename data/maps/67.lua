local map = ...
local game = map:get_game()

------------------------------
-- Outside H7 (Goron City)  --
------------------------------

function map:on_started(destination)

  -- Opening doors
  local entrance_names = {
    "house_3", "house_4", "house_leader"
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

  if game:get_value("i029") == 4 then
    game:start_dialog("osgor.1.ghost", function()
      
    end)
  else
    npc_goron_ghost:remove()
  end

end
