local map = ...
local game = map:get_game()

-----------------------------------------------------------
-- Outside World O3 (New Kasuto Town) - Houses and Shops --
-----------------------------------------------------------

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
  end

  -- Entrances of houses.
  local entrance_names = { "house3" }
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

  random_walk(npc_dog)
  random_walk(npc_kasuto_2)
  -- If hero has collected all the book, Mr. Write is in his house and rewards the player.
  if game:get_value("i1615") >= 13 then
    npc_mr_write:set_enabled(false)
  else
    random_walk(npc_mr_write)
  end
end

function npc_dog:on_interaction()
  sol.audio.play_sound("dog")
end

function npc_mr_write:on_interaction()
  game:start_dialog("hylian_1.0.kasuto")
end

function npc_kasuto_2:on_interaction()
  game:start_dialog("hylian_2.0.kasuto")
end