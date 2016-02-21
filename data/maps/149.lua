local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World O4 (New Kasuto Town) - Spoils Shop --
------------------------------------------------------

if game:get_value("i1230")==nil then game:set_value("i1230", 0) end

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

function npc_oracle:on_interaction()
  local informed = false
  if game:get_value("i1230") >= 1 not informed then
    game:start_dialog("din.0.kasuto_gerudo")
    informed = true
  else
    game:start_dialog("din.0.kasuto")
  end
end