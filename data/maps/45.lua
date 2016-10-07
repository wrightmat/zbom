local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World F8 (Hyrule Castle) - Ordona Speaks --
------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  -- Opening doors
  local entrance_names = { "castle" }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    local tile = map:get_entity(entrance_name .. "_door")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 1 and tile:is_enabled() and game:get_time_of_day() == "day" then
        tile:set_enabled(false)
        sol.audio.play_sound("door_open")
      end
    end
  end

  if destination == from_castle_1 and game:get_value("i1032") == 3 then
    sol.timer.start(1000, function()
      hero:freeze()
      hero:set_direction(0)
      if game:get_time_of_day() ~= "night" then
        local previous_tone = game:get_map_tone()
        game:set_map_tone(32,64,128,255)
      end
      game:start_dialog("ordona.3.castle", game:get_player_name(), function()
        sol.timer.start(500, function()
          if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
        end)
        hero:unfreeze()
        game:add_max_stamina(100)
        game:set_stamina(game:get_max_stamina())
        game:set_value("i1032", 4)
      end)
    end)
  end

  random_walk(npc_guard_1)
  random_walk(npc_guard_2)
end