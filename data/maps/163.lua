local map = ...
local game = map:get_game()

---------------------------------------------------
-- Great Fairy Fountain of Courage - Faron Woods --
---------------------------------------------------

function map:on_started(destination)

end

function sensor_fairy_speak:on_activated()
  game:start_dialog("great_fairy.1.faron")
end
