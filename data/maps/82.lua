local map = ...
local game = map:get_game()

-----------------------------------------------------
-- Outside World C13 (Beach) - Tokay Establishment --
-----------------------------------------------------

local function random_walk(npc)
  local m = sol.movement.create("random_path")
  m:set_speed(32)
  m:start(npc)
  npc:get_sprite():set_animation("walking")
end

function map:on_started(destination)
  if game:get_value("i1068") < 7 then
    npc_tokay_1:remove()
    npc_tokay_2:remove()
    npc_tokay_3:remove()
    npc_tokay_4:remove()
  else
    random_walk(npc_tokay_1)
    random_walk(npc_tokay_2)
    random_walk(npc_tokay_3)
    random_walk(npc_tokay_4)
  end
end

function npc_tokay_1:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay.0.beach")
end

function npc_tokay_2:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay.0.beach")
end

function npc_tokay_3:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay.0.beach")
end

function npc_tokay_4:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay.0.beach")
end
