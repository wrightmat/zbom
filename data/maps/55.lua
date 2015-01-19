local map = ...
local game = map:get_game()

function sensor_change_layer:on_activated()
  -- if walking forward on low level, change to intermediate level
  if layer ~= 1 and hero:get_direction() == 1 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer+1)
  end

  -- if walking down on intermediate level, changle to low level
  if layer ~= 0 and hero:get_direction() == 3 then
    local x, y, layer = hero:get_position()
    hero:set_position(x, y, layer-1)
  end
end
