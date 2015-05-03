local map = ...
local game = map:get_game()

------------------------------------------------------------------------------------
-- Outside World E10 (Lake Hylia) - Path to Lakebed Lair entrance (dynamic water) --
------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end

function map:on_started(destination)
  if game:get_value("b1134") then
    -- If the dungeon has been completed, the water returns
    map:set_entities_enabled("water", true)
    map:set_entities_enabled("wake", true)
  elseif game:get_value("i1030") >= 2 then
    -- If the switch has been flipped in the sewers, the water is gone
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
  end
end

function ocarina_wind_to_H14:on_interaction()
  -- if this point not previously discovered
  -- then add it, otherwise do nothing
  if not game:get_value("b1514") then
    game:start_dialog("warp.new_point", function()
      game:set_value("b1514", true)
    end)
  else
    -- if other paired point is discovered (and they have the Ocarina),
    -- then ask the player if they want to warp there!
   if game:has_item("ocarina") then
    if game:get_value("b1515") then
      game:start_dialog("warp.to_H14", function(answer)
        if answer == 1 then
          sol.audio.play_sound("ocarina_wind")
          map:get_entity("hero"):teleport(13, "ocarina_warp", "fade")
        end
      end)
    else
      game:start_dialog("warp.interaction")
    end
   end
  end
end
