local map = ...
local game = map:get_game()

----------------------------------------------------------------------
-- Beach/Desert houses (Tokay settlement, Astronomer, Gerudo, etc.) --
----------------------------------------------------------------------

function map:on_started(destination)

end

function npc_astronomer:on_interaction()
  if game:get_value("b2023") then
   game:start_dialog("astronomer.0.trading", function(answer)
    if answer == 1 then
      -- give him the potion, get the deku mask
      game:start_dialog("astronomer.0.trading_yes", function()
        hero:start_treasure("trading", 4)
        game:set_value("b2024", true)
        game:set_value("b2023", false)
      end)
    else
      -- don't give him the potion
      game:start_dialog("astronomer.0.trading_no")
    end
   end)
  else
   game:start_dialog("astronomer.0.house")
  end
end
