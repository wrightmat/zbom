local map = ...
local game = map:get_game()

---------------------------
-- Kakariko City houses  --
---------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if not game:has_item("bomb_bag") then
    if item_bomb_1 ~= nil then item_bomb_1:remove() end
    if item_bomb_2 ~= nil then item_bomb_2:remove() end
    if item_bomb_3 ~= nil then item_bomb_3:remove() end
  end
  random_walk(npc_etnaya)
end

function npc_etnaya:on_interaction()
  game:start_dialog("etnaya.0")
end

function npc_gartan:on_interaction()
  game:start_dialog("gartan.0.pub")
end

function npc_moriss:on_interaction()
  game:start_dialog("moriss.0.pub")
end

function npc_rowin:on_interaction()
  game:start_dialog("rowin.0.pub")
end

function npc_garroth_sensor:on_interaction()
  game:start_dialog("garroth.0.pub")
end

function npc_turt_sensor:on_interaction()
  game:start_dialog("turt.0.inn")
end
