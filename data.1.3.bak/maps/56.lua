local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World F5 (Septen Heights) --
---------------------------------------

if game:get_value("i1926")==nil then game:set_value("i1926", 0) end
if game:get_value("i1927")==nil then game:set_value("i1927", 0) end

function map:on_started(destination)
  if game:get_value("i1926") >= 2 and game:get_value("i1927") >= 2 then
    npc_rito_carpenter:remove()
  end
end

function npc_rito_1:on_interaction()
  game:start_dialog("rito_1.0.septen")
end

function npc_rito_2:on_interaction()
  game:start_dialog("rito_2.0.septen")
end

function npc_rito_carpenter:on_interaction()
  if game:get_value("i1926") >= 1 then
    game:start_dialog("rito_carpenter.1.septen")
    game:set_value("i1927", 2)
  else
    game:start_dialog("rito_carpenter.0.septen")
    game:set_value("i1927", 1)
  end
end
