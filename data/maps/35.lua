local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World F10 (Hyrule Field) - Sewer access (to Big Key) --
------------------------------------------------------------------

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