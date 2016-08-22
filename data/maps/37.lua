local map = ...
local game = map:get_game()

---------------------------------------------------
-- Outside World H10 (Lost Woods) - Deku Trading --
---------------------------------------------------

function map:on_started(destination)
  if not game:get_value("b2022") then quest_trading_mask:remove() end
end

function trading()
  game:start_dialog("deku.0.trading", function(answer)
    if answer == 1 then -- yes, so give deku mask
      game:start_dialog("deku.0.trading_yes", function()
        hero:start_treasure("trading", 3)
        game:set_value("b2023", true)
        game:set_value("b2022", false)
        quest_trading_mask:remove()
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
    if game:get_value("b1699") then
      game:start_dialog("deku.4.lost_woods")
    elseif game:get_value("i1807") == 7 then
      game:start_dialog("deku.2.lost_woods")
    else
      game:start_dialog("deku.0.lost_woods")
    end
  end
end
function npc_deku_2:on_interaction()
  npc_deku_1:on_interaction()
end