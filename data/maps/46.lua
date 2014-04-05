local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World G8 (Hidden Village) - Impa's House, Warp to Ancient Library --
-------------------------------------------------------------------------------

function map:on_started(destination)
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

function ocarina_wind_to_L5:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1501") then
    game:start_dialog("warp.new_point")
    game:set_value("b1501", true)
  end
  -- if other paired point is discovered, then
  -- ask the player if they want to warp there!
  if game:get_value("b1500") then
    game:start_dialog("warp.to_L5", function(answer)
      if answer == 1 then
        sol.audio.play_sound("ocarina_wind")
        hero:transport(133, "ocarina_warp", "fade")
      end
    end)
  else
    game:start_dialog("warp.interaction")
  end
end
