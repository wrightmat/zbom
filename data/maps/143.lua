local map = ...
local game = map:get_game()

-------------------------------------------------------
-- Outside World N4 (New Kasuto Town) - Kasuto Mayor --
-------------------------------------------------------

function map:on_started()
  -- Entrances of houses.
  local entrance_names = { "house1" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")

    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
	tile:set_enabled(false)
	sol.audio.play_sound("door_open")
      end
    end
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end

function npc_mayor:on_interaction()
  if game:get_max_life() >= 40 and game:get_item("world_map"):get_variant() < 3 then
    game:start_dialog("mayor.1.kasuto", function()
      hero:start_treasure("world_map", 3)
    end)
  elseif game:get_max_life() < 40 then
    game:start_dialog("mayor.0.kasuto")
  else
    game:start_dialog("mayor.2.kasuto")
  end
end