local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E13 (Faron Woods-Poisoned) - Poisonsed Trees, Great Fairy Fountain --
--------------------------------------------------------------------------------------

if game:get_value("i1911")==nil then game:set_value("i1911", 0) end --Gaira
if game:get_value("i1602")==nil then game:set_value("i1602", 0) end

local function follow_hero(npc)
  local hero_x, hero_y, hero_layer = hero:get_position()
  local npc_x, npc_y, npc_layer = npc:get_position()
  local m = sol.movement.create("target")
  m:set_speed(40)
  npc:get_sprite():set_animation("walking")
  m:start(npc)
end

function map:on_started(destination)
  if game:get_value("i1602") < 1 or game:get_value("i1602") >= 4 then
    npc_gaira:remove()
  end
end

function npc_gaira:on_interaction()
  if game:get_value("i1602") >= 2 then
    game:start_dialog("gaira.3.faron", function()
      game:set_value("i1602", 3)
    end)
    follow_hero(npc_gaira)
  else
    game:start_dialog("gaira.2.faron")
  end
end
