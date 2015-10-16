local map = ...
local game = map:get_game()

function map:on_started(destination)
  -- Remove HUD and hero.
  map:get_game().hud:set_enabled(false)
  map:get_hero():set_position(-100, -100)

  -- Set initial and max stamina.
  game:set_value("i1025", 200)
  game:set_value("i1024", 200)

  -- Dream sequence depicting the Dark Mirror
  belahim:set_enabled(false)
  light_beam:set_enabled(false)
  dark_mirror:set_enabled(false)
  sol.timer.start(map, 2000, function()
    dark_mirror:set_enabled(true)
    dark_mirror:get_sprite():fade_in(100)
    sol.timer.start(map, 2000, function()
      belahim:set_enabled(true)
      belahim:get_sprite():fade_in(60)
      m = sol.movement.create("target")
      m:set_ignore_obstacles(true)
      m:set_target(320,240)
      m:set_speed(48)
      m:start(belahim, function()
        belahim:remove()
        dark_mirror:get_sprite():fade_out(80, function()
          dark_mirror:remove()
          light_beam:set_enabled(true)
          sol.timer.start(map, 1000, function()
            game:start_dialog("ordona.0.intro", function()
              -- Hero wakes up in bed.
              hero:teleport("1", "from_intro", "fade")
            end)
          end)
        end)
      end)
    end)
  end)
end