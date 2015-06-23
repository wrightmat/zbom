local map = ...
local game = map:get_game()

--------------------------------------------
-- Outside World C2 (Ruto Town) - Trading --
--------------------------------------------

function npc_zora_trading:on_interaction()
  if game:get_value("b2030") then
    game:start_dialog("zora.1.trading", function()
        -- give him the scale, get the frozen fish (no choice this time)
        game:start_dialog("zora.1.trading_yes", function()
          hero:start_treasure("trading", 11)
          game:set_value("b2031", true)
          game:set_value("b2030", false)
        end)
    end)
  else
    game:start_dialog("zora.1.ruto")
  end
end

function ocarina_wind_to_G5:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1513") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1513", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1512") then
      game:start_dialog("warp.to_G5", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(57, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end