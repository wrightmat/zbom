local map = ...
local game = map:get_game()

-------------------------------------------------------------
-- Outside World F13 (Faron Woods) - Deacon the Lumberjack --
-------------------------------------------------------------

if game:get_value("i1913")==nil then game:set_value("i1913", 0) end

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  --random_walk(npc_deacon)
end

function npc_deacon:on_interaction()
  if game:get_value("i1913") == 1 then
    game:start_dialog("deacon.1.faron")
    game:set_value("i1913", game:get_value("i1913")+1)
  --elseif game:get_value("i1913") == 2 then
  --  game:start_dialog("deacon.2.faron")
  else
    game:start_dialog("deacon.0.faron")
    game:set_value("i1913", game:get_value("i1913")+1)
  end
end
