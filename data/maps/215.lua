local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 6) --
---------------------------------------------

function map:on_started(destination)
  block_1:set_enabled(false)
  block_2:set_enabled(false)
  switch_2:set_enabled(false) -- re-enabled after Grim Creeper defeat
  chest_map:set_enabled(false)
end

function sensor_hole:on_activated()
  map:get_hero():teleport("214", from_hole_above)
end

function switch_1:on_activated()
  block_1:set_enabled(true)
end

function switch_2:on_actived()
  block_2:set_enabled(true)
end