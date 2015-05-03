local map = ...
local game = map:get_game()

------------------------------------------
-- Inside North Hyrule houses and such  --
------------------------------------------

if game:get_value("i1912")==nil then game:set_value("i1912", 0) end

function map:on_started(destination)
  if game:get_value("i1032") >= 2 then
    door:set_enabled(false)
  end
  if game:get_value("i1840") >= 5 then
    -- crystal ball is gone
    table_witch:set_enabled(true)
  end
  if game:get_value("i1068") == "9" then game:set_value("i1068", "10") end
end

function npc_isan:on_interaction()
    if game:get_value("i1912") == 2 then
      repeat -- make sure the same quote is not picked again
        index = math.random(2)
      until index ~= last_message
      game:start_dialog("isan.2.library."..index)
      last_message = index
    elseif game:get_value("i1912") == 1 then
      game:start_dialog("isan.1.library", function()
        game:set_value("i1912", game:get_value("i1912")+1)
      end)
    else
      game:start_dialog("isan.0.library", function()
        game:set_value("i1032", 1)
        game:set_value("i1912", game:get_value("i1912")+1)
      end)
    end
end

function npc_saria_witch:on_interaction()
  if game:get_value("b2024") then
    game:start_dialog("witch.0.trading", function(answer)
      if answer == 1 then
        -- give her the tear, get the crystal ball
        game:start_dialog("witch.0.trading_yes", function()
          hero:start_treasure("trading", 5)
          game:set_value("b2025", true)
          game:set_value("b2024", false)
	  table_witch:set_enabled(true)
        end)
      else
        -- don't give her the tear
        game:start_dialog("witch.0.trading_no")
      end
    end)
  else
    game:start_dialog("witch.0.house")
  end
end

function shelf_1:on_interaction()
  game:start_dialog("library_shelf_1")
end
function shelf_2:on_interaction()
  game:start_dialog("library_shelf_2")
end
function shelf_3:on_interaction()
  game:start_dialog("library_shelf_3")
end
function shelf_4:on_interaction()
  game:start_dialog("library_shelf_4")
end
function shelf_5:on_interaction()
  game:start_dialog("library_shelf_5")
end
function shelf_6:on_interaction()
  game:start_dialog("library_shelf_6")
end
function shelf_7:on_interaction()
  game:start_dialog("library_shelf_7")
end
function shelf_8:on_interaction()
  game:start_dialog("library_shelf_8")
end
