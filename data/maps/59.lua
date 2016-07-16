local map = ...
local game = map:get_game()

------------------------------------------------------------------
-- Outside World I5 (Death Mountan/Fire Peak) - Subrosia access --
------------------------------------------------------------------

-- Can only get to Subrosia after the Mausoleum has been completed
function map:on_started(destination)
  if not game:get_value("b1117") then
    warp_to_subrosia:set_enabled(false)
  end
end
