local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World B9 (Gerudo Airship Port) - Gerudo Airship Port --
------------------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1068") <= 6 then
    gerudo_ship:remove()
    npc_gerudo_leader:remove()
    npc_gerudo_pirate_1:remove()
    npc_gerudo_pirate_2:remove()
  elseif game:get_value("i1068") > 6 then
    gerudo_ship:get_sprite():set_animation("airship")
  end
end

function npc_gerudo_pirate_1:on_interaction()
  game:start_dialog("gerudo.3.desert")
end

function npc_gerudo_pirate_2:on_interaction()
  game:start_dialog("gerudo.3.desert")
end

function npc_gerudo_leader:on_interaction()
  game:start_dialog("hesla.6.desert")
end
