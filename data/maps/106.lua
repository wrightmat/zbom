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
  -- Entrances of houses.
  local entrance_names = { "house_1", "house_2", "house_3", "house_4" }
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

  random_walk(hylian_1)
end

function hylian_1:on_interaction()
  game:start_dialog("hylian_1.0.rauru")
end