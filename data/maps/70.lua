local map = ...
local game = map:get_game()

--------------------------------------------------------------------
-- Outside World B7 (Desert/Pyramid Entrance) - Abandoned Pyramid --
--------------------------------------------------------------------

if game:get_value("i1068")==nil then game:set_value("i1068", 0) end

function map:on_started(destination)
  -- If you haven't gotten all of the parts (and have met the Gerudo), Ordona directs you back.
  if destination == from_pyramid and game:get_value("i1068") >= 1 then
    if not game:get_value("b1087") or not game:get_value("b1088") or not game:get_value("b1089") then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        hero:set_direction(2)
        if game:get_time_of_day() ~= "night" then
          local previous_tone = game:get_map_tone()
          game:set_map_tone(32,64,128,255)
        end
        game:start_dialog("ordona.1.pyramid", game:get_player_name(), function()
          sol.timer.start(500, function()
            if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
          end)
          hero:unfreeze()
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
        end)
      end)
    end
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end