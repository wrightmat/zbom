local map = ...
local game = map:get_game()

-----------------------------------------------------------
-- Outside World O3 (New Kasuto Town) - Houses and Shops --
-----------------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  random_walk(npc_dog)
end

function npc_dog:on_interaction()
  sol.audio.play_sound("dog")
end