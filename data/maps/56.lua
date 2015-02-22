local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World F5 (Septen Heights) --
---------------------------------------

function npc_rito_1:on_interaction()
  game:start_dialog("rito_1.0.septen")
end

function npc_rito_2:on_interaction()
  game:start_dialog("rito_2.0.septen")
end

function npc_rito_bridge:on_interaction()
  game:start_dialog("rito_carpenter.0.septen")
end
