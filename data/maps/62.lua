local map = ...
local game = map:get_game()

------------------------------------------------
-- Outside World D6 (Death Mountain/Snowpeak) --
------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_yepa)
end

function npc_yepa:on_interaction()
  game:start_dialog("anouki_4.0.snowpeak")
end
