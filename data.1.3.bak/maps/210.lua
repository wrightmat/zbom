local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 1) --
---------------------------------------------

function map:on_started(destination)
  sol.timer.start(map, 500, function()
    map:create_enemy({
	x = 72,
	y = 229,
	layer = 0,
	direction = 0,
	breed = "boulder"
    })
    return true
  end)
end
