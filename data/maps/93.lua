local map = ...
local game = map:get_game()

--------------------------------------------
-- Outside World C2 (Ruto Town) - Trading --
--------------------------------------------

function map:on_started(destination)
  if not game:get_value("b2030") then quest_trading_fish:remove() end
end

function npc_zora_trading:on_interaction()
  if game:get_value("b2030") then
    game:start_dialog("zora.1.trading", function()
        -- give him the scale, get the frozen fish (no choice this time)
        game:start_dialog("zora.1.trading_yes", function()
          hero:start_treasure("trading", 11)
          game:set_value("b2031", true)
          game:set_value("b2030", false)
          quest_trading_fish:remove()
        end)
    end)
  else
    game:start_dialog("zora.1.ruto")
  end
end