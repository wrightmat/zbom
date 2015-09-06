local map = ...
local game = map:get_game()

------------------------------------------
-- Outside World B8 (Gerudo Encampment) --
------------------------------------------

function ocarina_wind_to_H6:on_interaction()
  game:set_dialog_style("default")
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1504") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1504", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1505") then
      game:start_dialog("warp.to_H6", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(66, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end