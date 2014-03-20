local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------
-- Outside World C7 (Desert Expanse) - Kakariko Graveyard and Zuna Astronomer --
--------------------------------------------------------------------------------

sunset_overlay = sol.surface.create(320, 240)
if hero:get_direction() == 2 then
  -- If coming from right side of town (facing left),
  -- show the sunset overlay.
  sunset_overlay:set_opacity(0.4 * 255)
else
  sunset_overlay:set_opacity(0)
end
sunset_overlay:fill_color{187, 33, 21}

function map:on_started(destination)
  local entrance_names = {
    "house"
  }
  for _, entrance_name in ipairs(entrance_names) do
    local sensor = map:get_entity(entrance_name .. "_door_sensor")
    sensor.on_activated_repeat = function()
      if hero:get_direction() == 3 then
	sol.audio.play_music("gerudo")
      end
    end
  end
end

function sensor_enter_kakariko:on_activated()
  sol.audio.play_music("kakariko")
  sunset_overlay:set_opacity(0.1*255)
  sensor_enter_desert:set_enabled(false)
  sol.timer.start(sensor_enter_kakariko,2000,function()
    sensor_enter_desert:set_enabled(true)
    sunset_overlay:set_opacity(0.2*255)
    sol.timer.start(sensor_enter_kakariko,2000,function()
      sunset_overlay:set_opacity(0.3*255)
    end)
  end)
end
function sensor_enter_desert:on_activated()
  sol.audio.play_music("gerudo")
  sunset_overlay:set_opacity(0.3*255)
  sensor_enter_kakariko:set_enabled(false)
  sol.timer.start(sensor_enter_desert,2000,function()
    sensor_enter_kakariko:set_enabled(true)
    sunset_overlay:set_opacity(0.2*255)
    sol.timer.start(sensor_enter_desert,2000,function()
      sunset_overlay:set_opacity(0.1*255)
    end)
  end)
end

function game:on_map_changed(map)
  function map:on_draw(dst_surface)
    if map:get_world() ~= "inside_world" then sunset_overlay:draw(dst_surface) end
  end
end
