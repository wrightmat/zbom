local map = ...
local game = map:get_game()

--------------------------------------------------------------------------------------
-- Outside World E11 (Lakebed Lair Entr) - Entrance to Lakebed Lair (dynamic water) --
--------------------------------------------------------------------------------------

if game:get_value("i1030")==nil then game:set_value("i1030", 0) end

function map:on_started(destination)
  if game:get_value("b1134") then
    -- If the dungeon has been completed, the water returns
    map:set_entities_enabled("water", true)
    map:set_entities_enabled("wake", true)
  elseif game:get_value("i1030") >= 2 then
    -- If the switch has been flipped in the sewers, the water is gone
    map:set_entities_enabled("water", false)
    map:set_entities_enabled("wake", false)
    sx, sy, sl = statue:get_position()
    tx, ty, tl = temple_entr:get_position()
    statue:set_position(sx, sy, 0)
    temple_entr:set_position(tx, ty, 1)
  end
end
