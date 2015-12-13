local map = ...

--------------------------------------------
-- Outside World K1 (Darunia Town/Market) --
--------------------------------------------

local function random_walk_slow(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(16)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started()
  random_walk_slow(goron_1)
  random_walk_slow(goron_4)
end