local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E11 (Lakebed Lair Entr) - Entrance to Lakebed Lair (dynamic water) --
--------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end

function map:on_started(destination)
  if game:get_value("b1134") then
    -- If the dungeon has been completed, the water returns.
    map:set_entities_enabled("water", true)
    map:set_entities_enabled("wake", true)

    if game:get_value("i1910") < 5 then
      torch_1:get_sprite():set_animation("lit")
      sol.timer.start(1000, function()
        hero:freeze()
        game:set_map_tone(32,64,128,255)
        game:start_dialog("ordona.5.lake_hylia", game:get_player_name(), function()
          sol.timer.start(500, function() game:set_map_tone(255,255,255,255) end)
          hero:unfreeze()
          game:add_max_stamina(100)
          game:set_stamina(game:get_max_stamina())
          torch_1:get_sprite():set_animation("unlit")
          game:set_value("i1910", 5)
        end)
      end)
    end
  elseif game:get_value("i1030") >= 2 then
    -- If the switch has been flipped in the sewers, the water is gone.
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
    sx, sy, sl = statue:get_position()
    tx, ty, tl = temple_entr:get_position()
    statue:set_position(sx, sy, 0)
    temple_entr:set_position(tx, ty, 1)
  end
end