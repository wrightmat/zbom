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
      game:set_map_tone(32,64,128,255)
      if not game:get_value("b1033") then  -- If player has not done Ruins, suggest that before Lost Woods.
        game:start_dialog("ordona.7.septen_2", game:get_player_name(), function()
          sol.timer.start(500, function() game:set_map_tone(255,255,255,255) end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 7)
        end)
      else
        game:start_dialog("ordona.7.septen", game:get_player_name(), function()
          sol.timer.start(500, function() game:set_map_tone(255,255,255,255) end)
          hero:unfreeze()
          game:set_map_tone(32,64,128,255)
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

function sensor_change_layer:on_activated()
  -- If walking forward on low level, change to intermediate level.
  if layer ~= 1 and hero:get_direction() == 1 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end

  -- If walking down on intermediate level, changle to low level.
  if layer ~= 0 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer-1)
  end
end