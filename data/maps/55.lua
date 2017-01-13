local map = ...
local game = map:get_game()

--------------------------------------------------
-- Outside World E5 (Septen Heights/Tower Entr) --
--------------------------------------------------

function map:on_started(destination)
  if game:get_value("b1150") then stone_pile:remove() end -- Tower construction over after Snowpeak Caverns beat.
  if game:get_value("b1170") and game:get_value("i1910") < 7 then
    torch_1:get_sprite():set_animation("lit")
    sol.timer.start(1000, function()
      hero:freeze()
      if game:get_time_of_day() ~= "night" then
        local previous_tone = game:get_map_tone()
        game:set_map_tone(32,64,128,255)
      end
      if not game:get_value("b1033") then  -- If player has not done Ruins, suggest that before Lost Woods.
        game:start_dialog("ordona.7.septen_2", game:get_player_name(), function()
          sol.timer.start(500, function()
            if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
          end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 7)
        end)
      else
        game:start_dialog("ordona.7.septen", game:get_player_name(), function()
          sol.timer.start(500, function()
            if game:get_time_of_day() ~= "night" then game:set_map_tone(previous_tone) end
          end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 7)
        end)
      end
    end)
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
end