local map = ...
local game = map:get_game()

-------------------------------------------------------------------------------
-- Outside World D12 (Faron Woods-Beach) - Beach, Huge Crab (Overworld Boss) --
-------------------------------------------------------------------------------

function map:on_started(destination)
  if huge_crab ~= nil then huge_crab:set_enabled(false) end
end

function sensor_crab_1:on_activated()
  if huge_crab ~= nil then
    huge_crab:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end
function sensor_crab_2:on_activated()
  sensor_crab_1:on_activated()
end
function sensor_crab_3:on_activated()
  sensor_crab_1:on_activated()
end
function sensor_crab_4:on_activated()
  sensor_crab_1:on_activated()
end

function huge_crab:on_dead()
  sol.audio.play_music("beach")
end