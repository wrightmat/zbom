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
  subrosian_soaking:get_sprite():set_animation("soaking")
  random_walk(subrosian_blue)
  random_walk(subrosian_orange)
end

function subrosian_blue:on_interaction()
  game:start_dialog("subrosian_blue.0.subrosia")
end

function subrosian_orange:on_interaction()
  game:start_dialog("subrosian_orange.0.subrosia")
end

function subrosian_soaking:on_interaction()
  game:start_dialog("subrosian_soaking.0.subrosia")
end
