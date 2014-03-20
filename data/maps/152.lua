local map = ...
local game = map:get_game()

-----------------------------------------------------------
-- Subrosia A2 (I5 Access) - Coastline, House, test site --
-----------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  subrosian_soaking:set_sprite("soaking")
  random_walk(subrosian_blue)
  random_walk(subrosian_orange)
end
