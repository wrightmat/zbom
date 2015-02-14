local map = ...
local game = map:get_game()

----------------------------------------------------------
-- Great Fairy Fountain of Understanding - North Hyrule --
----------------------------------------------------------

if game:get_value("i1608")==nil then game:set_value("i1608", 0) end
if game:get_value("i1834")==nil then game:set_value("i1834", 0) end

function map:on_started(destination)
  if game:get_value("i1834") >= 25 then game:set_value("i1608", 2) end
  if game:get_value("i1834") >= 50 then game:set_value("i1608", 3) end
  if game:get_value("i1834") >= 75 then game:set_value("i1608", 4) end
  if game:get_value("i1834") == 99 then game:set_value("i1608", 5) end
end

function sensor_fairy_speak:on_activated()
  if game:get_value("i1608") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1608") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1608") == 3 then
    game:start_dialog("great_fairy.3")
  elseif game:get_value("i1608") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1608") == 5 then
    game:start_dialog("great_fairy.5.north", function()
      hero:start_treasure("sword", 3)
    end)
  else
    game:start_dialog("great_fairy.0.north", function()
      game:set_value("i1608", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end
