local map = ...
local game = map:get_game()
local anouki_talk = 0

---------------------------------
-- Outside World C6 (Snowpeak) --
---------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_time_of_day() == "night" then
    npc_anouki_2:remove()
  else
    random_walk(npc_anouki_2)
  end

  -- Activate any night-specific dynamic tiles.
  if game:get_time_of_day() == "night" then
    for entity in game:get_map():get_entities("night_") do
      entity:set_enabled(true)
    end
  end
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