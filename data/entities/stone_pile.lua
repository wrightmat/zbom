local entity = ...
local game = entity:get_game()

-- Stone pile: a pile of stones which can be
-- blown apart by a bomb or the hero running into it.

function entity:on_created()
  local sprite = self:get_sprite()
  self:set_size(32, 32)
  self:set_origin(16, 27)
  self:set_traversable_by(false)
  
  self:add_collision_test("touching", function(self, other)
    if other:get_type() == "explosion" or (other:get_type() == "hero" and game:get_hero():get_state() == "running") then
      sprite:set_animation("destroy")
      self:clear_collision_tests()
    end
  end)

  function sprite:on_animation_finished(animation)
    if animation == "destroy" then entity:remove() end
  end
end