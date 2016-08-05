local map = ...
local game = map:get_game()

--------------------------------------------------------------------------
-- Outside World C10 (Gerudo Desert) - Desert, Lanmola (Overworld Boss) --
--------------------------------------------------------------------------

function map:on_started(destination)
  if miniboss_lanmola then miniboss_lanmola:set_enabled(false) end
end

function sensor_lanmola_1:on_activated()
  -- This boss only activated if Pyramid is completed.
  if miniboss_lanmola and game:is_dungeon_finished(3) then
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

if miniboss_lanmola then
  function miniboss_lanmola:on_dead()
    sol.audio.play_music("gerudo")
  end
end