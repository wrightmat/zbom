local map = ...
local game = map:get_game()

---------------------------------------------
-- Dungeon 7: Tower of the Winds (Floor 1) --
---------------------------------------------

function map:on_started(destination)
  game:set_world_rain_mode("dungeon_7", nil)
  flying_heart:get_sprite():set_animation("heart")
  flying_apple:get_sprite():set_animation("apple")

  if not game:get_value("b1166") then
    miniboss_warp:set_enabled(false)
  end

  sol.timer.start(map, 600, function()
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
