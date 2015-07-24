local map = ...
local game = map:get_game()

----------------------------------------------------
-- Great Fairy Fountain of Power - Death Mountain --
----------------------------------------------------

if game:get_value("i1604")==nil then game:set_value("i1604", 0) end
if game:get_value("i1828")==nil then game:set_value("i1828", 0) end

function map:on_started(destination)

  if game:get_value("i1604") >= 1 and game:get_value("i1604") < 5 then  -- force the initial dialog to be heard
    if game:get_value("i1828") >= 10 then game:set_value("i1604", 2) end
    if game:get_value("i1828") >= 20 then game:set_value("i1604", 3) end
    if game:get_value("i1828") >= 35 then game:set_value("i1604", 4) end
    if game:get_value("i1828") >= 50 then game:set_value("i1604", 5) end
  end

end

function sensor_fairy_speak:on_activated()

  if game:get_value("i1604") == 1 then
    game:start_dialog("great_fairy.1")
  elseif game:get_value("i1604") == 2 then
    game:start_dialog("great_fairy.2")
  elseif game:get_value("i1604") == 3 then
    game:start_dialog("great_fairy.3", function()
      if game:get_item("bomb_bag"):get_variant() < 2 then hero:start_treasure("bomb_bag", 2) end
    end)
  elseif game:get_value("i1604") == 4 then
    game:start_dialog("great_fairy.4")
  elseif game:get_value("i1604") == 5 then
    game:start_dialog("great_fairy.5.mountain", function()
      game:set_value("i1604", 6)
      if game:get_item("bomb_bag"):get_variant() < 3 then hero:start_treasure("bomb_bag", 3) end
    end)
  elseif game:get_value("i1604") == 6 then
    game:start_dialog("great_fairy.6")
  else
    game:start_dialog("great_fairy.0.mountain", function()
      game:set_value("i1604", 1)
    end)
  end
  sensor_fairy_speak:set_enabled(false)

end