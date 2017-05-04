local map = ...
local game = map:get_game()

---------------------------------
-- Subrosia C2 (Smog miniboss) --
---------------------------------

function map:on_started(destination)
  if smog ~= nil then smog:set_enabled(false) end
end

function sensor_smog_1:on_activated()
  if smog ~= nil then
    smog:set_enabled(true)
    sol.audio.play_music("miniboss")
  end
end
function sensor_smog_2:on_activated()
  sensor_smog_1:on_activated()
end
function sensor_smog_3:on_activated()
  sensor_smog_1:on_activated()
end
function sensor_smog_4:on_activated()
  sensor_smog_1:on_activated()
end

function smog:on_dead()
  sol.audio.play_music("subrosia")
end