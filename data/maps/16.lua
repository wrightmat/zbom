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
  local distance_hero = math.abs((hero_x+hero_y)-(npc_x+npc_y))
  local m = sol.movement.create("target")
  if distance_hero > 1000 then
    m:set_speed(64)
  elseif distance_hero < 20 then
    m:set_speed(32)
  else
    m:set_speed(48)
  end
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_value("i1602") < 1 then
    npc_gaira:remove()
  end
end

function npc_gaira:on_interaction()
  if game:get_Value("i1602") >= 2 then
    game:start_dialog("gaira.3.faron", function()
      game:set_value("i1602", 3)
      follow_hero(npc_gaira)
    end)
  end
end
