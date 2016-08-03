local map = ...
local game = map:get_game()

--------------------------------------------------------
-- Outside World F3 (Rauru Town) - Houses and Shops   --
--------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
    hylian_1:remove()
    hylian_6:remove()
  else
    random_walk(hylian_1)
    random_walk(hylian_6)
  end

  -- Entrances of houses.
  local entrance_names = { "house_1", "house_2", "house_3", "sanctuary" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    local tile_glow = map:get_entity("night_" .. entrance_name .. "_door")
    tile_glow:set_enabled(false)
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() then
        tile:set_enabled(false)
        tile_glow:set_enabled(true)
        sol.audio.play_sound("door_open")
      end
    end
  end
end

function hylian_1:on_interaction()
  game:start_dialog("hylian_1.0.rauru")
end

function hylian_6:on_interaction()
  game:start_dialog("hylian_6.0.rauru")
end