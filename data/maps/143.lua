local map = ...
local game = map:get_game()

-------------------------------------------------------
-- Outside World N4 (New Kasuto Town) - Kasuto Mayor --
-------------------------------------------------------

function npc_mayor:on_interaction()
  if game:get_max_life() >= 40 and game:get_item("world_map"):get_variant() < 3 then
    game:start_dialog("mayor.1.kasuto", function()
      hero:start_treasure("world_map", 3)
    end)
  elseif game:get_max_life() < 40 then
    game:start_dialog("mayor.0.kasuto")
  else
    game:start_dialog("mayor.2.kasuto")
  end
end