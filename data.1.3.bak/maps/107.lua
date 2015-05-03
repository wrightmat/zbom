local map = ...
local game = map:get_game()

-------------------------------------
-- Outside World F4 (Midoro Swamp) --
-------------------------------------

function sensor_change_layer:on_activated()
  if layer ~= 1 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end
end
