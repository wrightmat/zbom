local map = ...
local game = map:get_game()
local anouki_talk = 0

----------------------------------------------
-- Outside World C5 (Snowpeak/Caverns Entr) --
----------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_anouki_3)
end

function npc_anouki_3:on_interaction()
  game:start_dialog("anouki_3."..anouki_talk..".snowpeak")
  if anouki_talk == 0 then anouki_talk = 1 else anouki_talk = 0 end
end
