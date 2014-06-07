local entity = ...
local map = entity:get_map()

-- Somaria pit: special entity that can be filled by
-- a somaria block, but is otherwise non-traversable.

function entity:on_created()
  self:create_sprite("entities/somaria_pit")
  self:set_size(16, 16)
  self:set_origin(16, 13)
  self:set_traversable_by(false)
end

function entity:on_interaction_item(item_used)
  if item_used == "cane" then
    self:get_sprite():set_animation("filled")
    self:set_traversable_by(true)
    sol.timer.start(self, 10000, function()
      self:get_sprite():set_animation("pit")
      self:set_traverable_by(false)
    end)
  end
end
