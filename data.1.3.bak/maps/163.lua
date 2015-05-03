local map = ...
local game = map:get_game()

---------------------------------------------------
-- Great Fairy Fountain of Courage - Faron Woods --
---------------------------------------------------

if game:get_value("i1603")==nil then game:set_value("i1603", 0) end
if game:get_value("i1849")==nil then game:set_value("i1849", 0) end

function map:on_started(destination)
  if game:get_value("i1603") >= 1 then  -- force the iniial dialog to be heard
    if game:get_value("i1849") >= 10 then game:set_value("i1603", 2) end
    if game:get_value("i1849") >= 20 then game:set_value("i1603", 3) end
    if game:get_value("i1849") >= 35 then game:set_value("i1603", 4) end
    if game:get_value("i1849") >= 50 then game:set_value("i1603", 5) end
  end
end

function sensor_fairy_speak:on_activated()
  if game:get_value("i1603") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1603") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1603") == 3 then
    game:start_dialog("great_fairy.3", function()
      if game:get_value("i1803") < 2 then hero:start_treasure("quiver", 2) end
    end)
  elseif game:get_value("i1603") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1603") == 5 then
    game:start_dialog("great_fairy.5.faron", function()
      hero:start_treasure("quiver", 3)
    end)
  else
    game:start_dialog("great_fairy.0.faron", function()
      game:set_value("i1603", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end
