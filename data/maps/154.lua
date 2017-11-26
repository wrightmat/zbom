local map = ...
local game = map:get_game()

--------------
-- Subrosia --
--------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end