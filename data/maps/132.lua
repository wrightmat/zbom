local map = ...
local game = map:get_game()

----------------------------------------
-- Outside World L4 (Old Kasuto Town) --
----------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started()
  random_walk(npc_squirrel_1)
  random_walk(npc_squirrel_2)
end