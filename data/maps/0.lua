local map = ...
local game = map:get_game()

function map:on_started(destination)
  -- Remove HUD and hero.
  map:get_game():set_hud_enabled(false)
  map:get_hero():set_position(-100, -100)

  -- Set initial and max stamina.
  game:set_value("i1025", 200)
  game:set_value("i1024", 200)

  -- Dream sequence depicting the Dark Mirror???

  -- Hero wakes up in bed.
  hero:teleport("1", "from_intro", "fade")
end
