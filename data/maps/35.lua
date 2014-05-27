local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World F10 (Hyrule Field) - Sewer access (to Big Key) --
------------------------------------------------------------------

function map:on_started(destination)
  if game:get_value("i1030") >= 2 then
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
  end
end
