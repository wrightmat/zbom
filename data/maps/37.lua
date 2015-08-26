local map = ...
local game = map:get_game()

---------------------------------------------------
-- Outside World H10 (Lost Woods) - Deku Trading --
---------------------------------------------------

function trading()
  game:start_dialog("deku.0.trading", function(answer)
    if answer == 1 then --yes, so give deku mask
      game:start_dialog("deku.0.trading_yes", function()
        hero:start_treasure("trading", 3)
        game:set_value("b2023", true)
        game:set_value("b2022", false)
      end)
    else
      game:start_dialog("deku.0.lost_woods")
    end
  end)
end

function npc_deku_1:on_interaction()
  if game:get_value("b2022") then
    trading()
  else
    if game:get_value("i1807") == 7 then
      game:start_dialog("deku.2.lost_woods")
    else
      game:start_dialog("deku.0.lost_woods")
    end
  end
end
function npc_deku_2:on_interaction()
  npc_deku_1:on_interaction()
end

function ocarina_wind_to_C13:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1506") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1506", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1507") then
      game:start_dialog("warp.to_C13", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(82, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end