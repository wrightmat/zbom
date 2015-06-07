local enemy = ...

-- Grim Creeper

function enemy:on_created()
  self:set_life(9)
  self:set_damage(3)
  self:create_sprite("enemies/grim_creeper")
  self:set_size(16, 24)
  self:set_origin(8, 17)
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_pushed_back_when_hurt(false)
  self:get_sprite():set_animation("stopped")
end
