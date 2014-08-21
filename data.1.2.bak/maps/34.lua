local map = ...
local game = map:get_game()

------------------------------------------------------------------------------------
-- Outside World E10 (Lake Hylia) - Path to Lakebed Lair entrance (dynamic water) --
------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end

function map:on_started(destination)
  if game:get_value("i1030") >= 2 then
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
  end
end
