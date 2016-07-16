local map = ...
local game = map:get_game()

---------------------
-- Inside Snowpeak --
---------------------

function map:on_started()
  if game:get_time_of_day() == "day" then
    npc_anouki_1:remove()
    npc_anouki_2:remove()
    npc_anouki_3:remove()
  end
end

function npc_anouki_1:on_interaction()
  game:set_dialog_style("default")
  game:start_dialog("anouki_1."..anouki_talk..".snowpeak")
  if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
end

function npc_anouki_2:on_interaction()
  game:set_dialog_style("default")
  if game:get_value("b1150") then
    game:start_dialog("anouki_2.2.snowpeak")
  else
    game:start_dialog("anouki_2."..anouki_talk..".snowpeak")
    if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
  end
end

function npc_anouki_3:on_interaction()
  game:set_dialog_style("default")
  if not game:get_value("b1117") then
    -- If at least Mausoleum not completed, suggest going there instead.
    game:start_dialog("anouki_3.0.snowpeak", function()
      game:start_dialog("anouki_3.1.not_ready")
    end)
  else
    game:start_dialog("anouki_3."..anouki_talk..".snowpeak")
    if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
  end
end

function npc_anouki_5:on_interaction()
  game:set_dialog_style("default")
  local rand = math.random(2)
  if rand == 1 then
    game:start_dialog("anouki_5.0.snowpeak")
  else
    game:start_dialog("anouki_5.1.snowpeak")
  end
end