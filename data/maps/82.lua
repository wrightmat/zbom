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
  game:start_dialog("tokay_1.0.beach")
end

function npc_tokay_2:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay_2.0.beach")
end

function npc_tokay_3:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay_1.0.beach")
end

function npc_tokay_4:on_interaction()
  sol.audio.play_sound("tokay")
  game:start_dialog("tokay_4.0.beach")
end

function ocarina_wind_to_H10:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1507") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1507", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1506") then
      game:start_dialog("warp.to_H10", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(37, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end
