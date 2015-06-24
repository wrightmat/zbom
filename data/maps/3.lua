local map = ...
local game = map:get_game()

---------------------------------
-- Inside Zora/Septen/Subrosia --
---------------------------------

function npc_rito_4:on_interaction()
  if game:get_value("b1150") then
    game:start_dialog("rito_4.1.septen")
  else
    game:start_dialog("rito_4.0.septen")
  end
end

function npc_rito_5:on_interaction()
  if not game:get_value("b1150") then
    game:start_dialog("rito_5.0.septen")
  end
end