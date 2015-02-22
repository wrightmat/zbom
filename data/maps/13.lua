local map = ...
local game = map:get_game()

-------------------------------------------------------------------------
-- Outside World H14 (Floria Peninsula) - Floria Babas and Heart Piece --
-------------------------------------------------------------------------

function ocarina_wind_to_E10:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1515") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1515", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1514") then
      game:start_dialog("warp.to_E10", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(34, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end
