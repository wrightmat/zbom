local entity = ...
local game = entity:get_game()

-- Stone pile: a pile of stones which
-- can only be blown apart by a bomb.

function entity:on_created()
  self:create_sprite("entities/stone_pile")
  self:set_size(32, 32)
  self:set_origin(16, 27)
  self:set_traversable_by(false)
  self:add_collision_test("touching", function(self, other)
    ex, ey, el = entity:get_position()
    if other:get_type() == "explosion" then
      self:get_sprite():set_animation("destroy")
      sol.timer.start(self, 500, function() self:remove() end)
    elseif other:get_type() == "hero" and game:get_hero():get_state() == "running" then
      self:get_sprite():set_animation("destroy")
      sol.timer.start(self, 500, function() self:remove() end)
    end
  end)
end
