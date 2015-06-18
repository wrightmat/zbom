local map = ...
local game = map:get_game()

--------------------------------------------------------------------------
-- Outside World C10 (Gerudo Desert) - Desert, Lanmola (Overworld Boss) --
--------------------------------------------------------------------------

function map:on_started(destination)
  if miniboss_lanmola ~= nil then miniboss_lanmola:set_enabled(false) end
end

function sensor_lanmola_1:on_activated()
  -- this boss only activated if Pyramid is completed
  if minboss_lanmola ~= nil and game:get_value("b1082") then
    miniboss_lanmola:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end
function sensor_lanmola_2:on_activated()
  sensor_lanmola_1:on_activated()
end
function sensor_lanmola_3:on_activated()
  sensor_lanmola_1:on_activated()
end
function sensor_lanmola_4:on_activated()
  sensor_lanmola_1:on_activated()
end

function miniboss_lanmola:on_dead()
  sol.audio.play_music("gerudo")
end