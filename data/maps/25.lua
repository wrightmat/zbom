local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World D12 (Faron Woods-Beach) - Beach, Huge Crab (Overworld Boss) --
-------------------------------------------------------------------------------

function map:on_started(destination)
  if not game:get_value("b1712") then huge_crab:set_enabled(false) end
end

function sensor_crab_1:on_activated()
  if not game:get_value("b1712") then
    huge_crab:set_enabled(true)
  end
end
function sensor_crab_2:on_activated()
  sensor_crab_1:on_activated()
end
function sensor_crab_3:on_activated()
  sensor_crab_1:on_activated()
end
function sensor_crab_4:on_activated()
  sensor_crab_1:on_activated()
end