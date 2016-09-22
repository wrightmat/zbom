local map = ...
local game = map:get_game()

---------------------------------------------------
-- Great Fairy Fountain of Kindness - Lake Hylia --
---------------------------------------------------

if game:get_value("i1606")==nil then game:set_value("i1606", 0) end
if game:get_value("i1832")==nil then game:set_value("i1832", 0) end

function map:on_started(destination)
  if game:get_value("i1606") >= 1 and game:get_value("i1606") < 5 then  -- force the initial dialog to be heard
    if game:get_value("i1832") >= 10 then game:set_value("i1606", 2) end
    if game:get_value("i1832") >= 20 then game:set_value("i1606", 3) end
    if game:get_value("i1832") >= 35 then game:set_value("i1606", 4) end
    if game:get_value("i1832") >= 50 then game:set_value("i1606", 5) end
  end
end

function sensor_fairy_speak:on_activated()
  if game:get_value("i1606") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1606") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1606") == 3 then
    game:start_dialog("great_fairy.3")
  elseif game:get_value("i1606") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1606") == 5 then
    game:start_dialog("great_fairy.5.lake", function()
      game:set_value("i1606", 6)
      if game:get_value("i1808") == 1 then hero:start_treasure("boomerang", 2) end
    end)
  elseif game:get_value("i1606") == 6 then
    game:start_dialog("great_fairy.6")
  else
    game:start_dialog("great_fairy.0.lake", function()
      game:set_value("i1606", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)
end