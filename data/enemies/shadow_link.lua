local enemy = ...
local map = enemy:get_map()

-- Shadow Link

function enemy:on_created()
  self:set_life(10); self:set_damage(8)
  self:create_sprite("enemies/shadow_link")
  self:set_size(32, 40); self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_attack_consequence("arrow", "protected")
  self:set_attack_consequence("hookshot", "protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "ignored")
  self:set_attack_consequence("sword", "custom")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
end