local entity = ...
local game = entity:get_game()

-- Flag

function entity:on_created()
  self:set_traversable_by(false)
  self:set_drawn_in_y_order(true)
end