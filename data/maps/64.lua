local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World F6 (Death Mountain) - Cave of Ordeals Entrance --
------------------------------------------------------------------

function npc_goron:on_interaction()
  game:start_dialog("goron.3.death_mountain")
end