local enemy = ...

-- Wallmaster

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/wallmaster")
  self:set_size(32, 32)
  self:set_origin(16, 13)
  self:set_pushed_back_when_hurt(false)
end
