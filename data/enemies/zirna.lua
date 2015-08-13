local enemy = ...

-- Zirna (Dark Tribe enchantress)

function enemy:on_created()
  self:set_life(9); self:set_damage(3)
  local sprite = self:create_sprite("enemies/zirna")
  self:set_size(24, 40); self:set_origin(12, 37)
  self:set_invincible()
  self:set_attack_consequence("sword", "protected")
  self:set_pushed_back_when_hurt(false)
  sprite:set_animation("stopped")
end