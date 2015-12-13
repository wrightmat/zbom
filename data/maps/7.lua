local map = ...
local game = map:get_game()

---------------------
-- Inside Snowpeak --
---------------------

function npc_anouki_5:on_interaction()
  game:set_dialog_style("default")
  local rand = math.random(2)
  if rand == 1 then
    game:start_dialog("anouki_5.0.snowpeak")
  else
    game:start_dialog("anouki_5.1.snowpeak")
  end
end