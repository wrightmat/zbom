local entity = ...
local map = entity:get_map()
local hero_on_pit = false

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
      sol.timer.start(self:get_map(), 10000, function()
        if hero_on_pit then
          return true
        else
          sprite:set_animation("pit")
          self:set_traversable_by(false)
        end
      end)
    elseif other:get_type() == "hero" then
      hero_on_pit = true
    else
      hero_on_pit = false
    end
  end)
end
