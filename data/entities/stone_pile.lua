local entity = ...
local game = entity:get_game()

-- Stone pile: a pile of stones which
-- can only be blown apart by a bomb.

function entity:on_created()
  self:create_sprite("entities/stone_pile")
  self:set_size(32, 32)
  self:set_origin(16, 27)
  self:set_traversable_by(false)
  self:add_collision_test("overlapping", function(self, other)
    if other:get_type() == "explosion" then
      self:get_sprite():set_animation("destroy")
      sol.timer.start(self, 1000, function()
        self:remove()
      end)
    end
  end)
end
