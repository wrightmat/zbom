local map = ...
local game = map:get_game()

-----------------------------------------------
-- Inside various caves - Blacksmith, etc.   --
-----------------------------------------------

if game:get_value("i1902")==nil then game:set_value("i1902", 0) end
if game:get_value("i1601")==nil then game:set_value("i1601", 0) end

function rudy_reputation()
  game:set_value("i1902", game:get_value("i1902")+1)
end

function map:on_started(destination)
  if game:get_value("i1902") < 2 or game:get_value("i1601") >= 1 then
    quest_rudy:remove() -- remove quest bubble if rep is too low or quest is already complete
  end
  if game:get_value("i1601") >= 2 then
    blacksmith_water:set_enabled(true)
  end
end

function npc_rudy:on_interaction()
  if game:get_value("i1902") == 0 then   -- General dialogs for low Rep
    game:start_dialog("rudy.0", rudy_reputation)
  elseif game:get_value("i1902") >= 1 then
    -- Cave-specific dialogs for water bottle side quest
    if game:get_value("i1601") == 1 then
      if game:get_item("bottle_1"):get_variant() == 2 then --bottle has water
        game:start_dialog("rudy.3.cave", function()
          game:get_item("bottle_1"):set_variant(1)
          game:set_value("i1601", 2)
        end)
      else
        game:start_dialog("rudy.2.cave", function()
          if not game:has_item("bottle_1") then
            game:start_dialog("rudy.2.cave_bottle", function()
              hero:start_treasure("bottle_1")
            end)
          end
        end)
      end
    elseif game:get_value("i1601") == 2 then
      -- quest complete
      game:start_dialog("rudy.4.cave", function(answer)
        if answer == 1 then --work
          game:start_dialog("rudy.4.cave_work")
        else --chat
          game:start_dialog("rudy.4.cave_chat")
        end
      end)
    else
      game:start_dialog("rudy.1.cave", rudy_reputation)
      game:set_value("i1601", 1)
    end
  end
end
