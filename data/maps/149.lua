local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World O4 (New Kasuto Town) - Spoils Shop --
------------------------------------------------------

if game:get_value("i1230")==nil then game:set_value("i1230", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

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

  random_walk(npc_oracle)
  random_walk(npc_kasuto_5)
end

function npc_oracle:on_interaction()
  local informed = false
  if game:get_value("i1230") >= 1 not informed then
    game:start_dialog("oracle_1.0.kasuto_gerudo")
    informed = true
  else
    game:start_dialog("oracle_1.0.kasuto")
  end
end

function npc_kasuto_5:on_interaction()
  game:start_dialog("hylian_5.0.kasuto")
end