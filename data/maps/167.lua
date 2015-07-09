local map = ...
local game = map:get_game()

----------------------------------------------
-- Great Fairy Fountain of Magic - Subrosia --
----------------------------------------------

if game:get_value("i1607")==nil then game:set_value("i1607", 0) end
if game:get_value("i1836")==nil then game:set_value("i1836", 0) end

function map:on_started(destination)
  if game:get_value("i1607") >= 1 then  -- force the initial dialog to be heard
    if game:get_value("i1836") >= 10 then game:set_value("i1607", 2) end
    if game:get_value("i1836") >= 20 then game:set_value("i1607", 3) end
    if game:get_value("i1836") >= 35 then game:set_value("i1607", 4) end
    if game:get_value("i1836") >= 50 then game:set_value("i1607", 5) end
  end
end

function sensor_fairy_speak:on_activated()
  if game:get_value("i1607") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1607") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1607") == 3 then
    game:start_dialog("great_fairy.3")
  elseif game:get_value("i1607") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1607") == 5 then
    game:start_dialog("great_fairy.5.subrosia", function()
      if game:get_value("i1817") < 2 then hero:start_treasure("glove", 2) end
      game:set_value("i1607", 6)
    end)
  elseif game:get_value("i1607") == 6 then
    game:start_dialog("great_fairy.6")
  else
    game:start_dialog("great_fairy.0.subrosia", function()
      game:set_value("i1607", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end