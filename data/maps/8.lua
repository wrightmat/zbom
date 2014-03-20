local map = ...
local game = map:get_game()

------------------------------------------
-- Inside North Hyrule houses and such  --
------------------------------------------

if game:get_value("i1912")==nil then game:set_value("i1912", 0) end

function map:on_started(destination)
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
        game:set_value("i1912", game:get_value("i1912")+1)
      end)
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
