local entity = ...
local map = entity:get_map()

-- Somaria pit: special entity that can be filled by
-- a somaria block, but is otherwise non-traversable.

function entity:on_created()
  local sprite = self:get_sprite()
  self:set_size(16, 16)
  self:set_traversable_by(false)
  self:add_collision_test("overlapping", function(self, other)
    if other:get_type() == "block" then
      sprite:set_animation("filled")
      self:set_traversable_by(true) -- pit is filled so hero can walk over it
      other:remove() -- remove the somaria block, it's in the pit
      sol.timer.start(self, 10000, function()
        sprite:set_animation("pit")
        self:set_traversable_by(false)
      end)
    end
  end)
end
