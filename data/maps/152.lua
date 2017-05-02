local map = ...
local game = map:get_game()

-------------------------------------------------
-- Subrosia A2 (I5 Access) - Coastline, Houses --
-------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(24)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  npc_salai:get_sprite():set_animation("soaking")
  random_walk(npc_ral)
  random_walk(npc_himi)
end

npc_ral:register_event("on_interaction", function()
  game:start_dialog("subrosian_blue.0.subrosia")
end)

npc_himi:register_event("on_interaction", function()
  game:start_dialog("subrosian_orange.0.subrosia")
end)

npc_salai:register_event("on_interaction", function()
  game:start_dialog("subrosian_soaking.0.subrosia", function()
    if game:get_value("tunic_equipped") ~= 2 then
      game:start_dialog("subrosian_soaking.0.tunic")
    end
  end)
end)