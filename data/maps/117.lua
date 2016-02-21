local map = ...
local game = map:get_game()

-------------------------------------------------------------------
-- Outside World I2 (Parapa Desert/Island Palace) - Oracle Nayru --
-------------------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_oracle)
end