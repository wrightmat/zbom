local map = ...
local game = map:get_game()

---------------------
-- Inside Snowpeak --
---------------------

function npc_anouki_5:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("anouki_5.0.snowpeak")
end