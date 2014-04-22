local map = ...
local game = map:get_game()

---------------------------------------
-- Outside World I7 (Death Mountain) --
---------------------------------------

function map:on_started(destination)

  if game:get_value("i1029") == 4 or game:get_value("i1029") == 5 then
    -- set position to hero and then follow
    -- (on intermediate layer so he doesn't collide)
    hx, hy, hl = map:get_entity("hero"):get_position()
    npc_goron_ghost:set_position(hx, hy, 1)
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(16)
    m:start(npc_goron_ghost)
  else
    npc_goron_ghost:remove()
  end

end
