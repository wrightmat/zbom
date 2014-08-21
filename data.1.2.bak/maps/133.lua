local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World L5 (Old Kasuto Town) - From sewer access to Ancient Library --
-------------------------------------------------------------------------------

function map:on_started(destination)
  --ocarina_wind_to_G8:set_traversable_by(true)
end

function ocarina_wind_to_G8:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1500") then
    game:start_dialog("warp.new_point")
    game:set_value("b1500", true)
  else
    -- if other paired point is discovered, then
    -- ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1501") then
      game:start_dialog("warp.to_G8", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(46, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    -- clear away lantern overlay from sewer
    if map:get_id() == "133" and lantern_overlay then lantern_overlay:fade_out() end
  end
end
