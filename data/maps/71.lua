local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------
-- Outside World C7 (Desert Expanse) - Kakariko Graveyard and Zuna Astronomer --
--------------------------------------------------------------------------------

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
  sensor_enter_desert:set_enabled(false)
  sol.timer.start(sensor_enter_kakariko,2000,function()
    sensor_enter_desert:set_enabled(true)
  end)
end
function sensor_enter_desert:on_activated()
  sol.audio.play_music("gerudo")
  sensor_enter_kakariko:set_enabled(false)
  sol.timer.start(sensor_enter_desert,2000,function()
    sensor_enter_kakariko:set_enabled(true)
  end)
end
