local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World G8 (Hidden Village) - Impa's House, Warp to Ancient Library --
-------------------------------------------------------------------------------

function map:on_started(destination)
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
  
  -- Opening doors
  local entrance_names = { "impa" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    local tile_glow = map:get_entity("night_" .. entrance_name .. "_door")
    tile_glow:set_enabled(false)
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        tile:set_enabled(false)
        if game:get_time_of_day() == "night" then
          tile_glow:set_enabled(true)
        end
        sol.audio.play_sound("door_open")
      end
    end
  end
end