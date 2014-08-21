local map = ...
local game = map:get_game()

------------------------------------------------------
-- Outside World I6 (Death Mountain/Mausoleum Entr) --
------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1029") == 5 then
    -- set position to hero and then follow
    -- (on intermediate layer so he doesn't collide)
    hx, hy, hl = map:get_entity("hero"):get_position()
    if map:get_entity("hero"):get_direction() == 0 or map:get_entity("hero"):get_direction() == 3 then
      npc_goron_ghost:set_position(hx+16, hy+16, 1)
    elseif map:get_entity("hero"):get_direction() == 1 or map:get_entity("hero"):get_direction() == 2 then
      npc_goron_ghost:set_position(hx-16, hy-16, 1)
    end
    sol.audio.play_sound("ghost")
    local m = sol.movement.create("target")
    m:set_speed(32)
    m:start(npc_goron_ghost)
  else
    npc_goron_ghost:remove()
  end
  if not game:get_value("b1110") then
    npc_dampeh:remove()
  end
end

function npc_dampeh:on_interaction()
  game:start_dialog("dampeh.2.mausoleum")
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_id() == "68" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
