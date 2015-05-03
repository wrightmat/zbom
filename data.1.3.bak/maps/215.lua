local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 6) --
---------------------------------------------

function map:on_started(destination)

end

function sensor_hole:on_activated()
  map:get_hero():teleport("214", from_hole_above)
end
