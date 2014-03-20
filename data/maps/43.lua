local map = ...
local game = map:get_game()

--------------------------------------
-- Outside World D8 (Hyrule Field)  --
--------------------------------------

sunset_overlay = sol.surface.create(320, 240)
if hero:get_direction() == 3 then
  -- If coming from above (Kakariko), show the
  -- sunset overlay. If coming from field, don't.
  sunset_overlay:set_opacity(0.4 * 255)
else
  sunset_overlay:set_opacity(0)
end
sunset_overlay:fill_color{187, 33, 21}

function sensor_enter_field:on_activated()
  sol.audio.play_music("field")
  sunset_overlay:set_opacity(0.3*255)
  sol.timer.start(sensor_enter_field,2000,function()
    sunset_overlay:set_opacity(0.2*255)
    sol.timer.start(sensor_enter_field,2000,function()
      sunset_overlay:set_opacity(0.1*255)
      sol.timer.start(sensor_enter_field,2000,function()
        sunset_overlay:set_opacity(0)
      end)
    end)
  end)
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_world() ~= "inside_world" then sunset_overlay:draw(dst_surface) end
  end
end
