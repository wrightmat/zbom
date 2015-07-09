local map = ...
local game = map:get_game()

-------------------------------------------------------
-- Outside World N4 (New Kasuto Town) - Kasuto Mayor --
-------------------------------------------------------

function npc_mayor:on_interaction()
print(game:get_max_life())
  if game:get_max_life() >= 40 then
    game:start_dialog("mayor.1.kasuto", function()
      hero:start_treasure("world_map", 3)
    end)
  else
    game:start_dialog("mayor.0.kasuto")
  end
end