local entity = ...
local map = entity:get_map()

-- Somaria pit: special entity that can be filled by
-- a somaria block, but is otherwise non-traversable.

function entity:on_created()
  self:create_sprite("entities/somaria_pit")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_traversable_by(false)
  self:add_collision_test("sprite", fill_pit)
end

local function fill_pit(entity1, entity2)
  if entity2:get_type() == "somaria_block" then
    self:get_sprite():set_animation("filled")
    entity2:remove()
    self:set_traversable_by(true)
    sol.timer.start(self, 10000, function()
      self:get_sprite():set_animation("pit")
      self:set_traverable_by(false)
    end)
  end
end
