local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World G5 (Zora's Domain) --
--------------------------------------

function npc_zora_1:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_2:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_3:on_interaction()
  game:start_dialog("zora.0.domain")
end

function npc_zora_trading:on_interaction()
  if game:get_value("b2029") then
    game:start_dialog("zora.0.trading", function(answer)
      if answer == 1 then
        -- give him the vase, get the zora scale
        game:start_dialog("zora.0.trading_yes", function()
          hero:start_treasure("trading", 10)
          game:set_value("b2030", true)
          game:set_value("b2029", false)
        end)
      else
        -- don't give him the vase
        game:start_dialog("zora.0.trading_no")
      end
    end)
  else
    game:start_dialog("zora.0.domain")
  end
end

function ocarina_wind_to_C2:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1512") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1512", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1513") then
      game:start_dialog("warp.to_C2", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(93, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end