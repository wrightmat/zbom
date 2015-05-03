local enemy = ...

-- Big Armos Status: Shoots lasers from its eye.

function enemy:on_created()
  self:set_life(2)
  self:set_damage(2)
  self:create_sprite("enemies/armos_big")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(true)
  self:set_size(32, 32)
  self:set_origin(16, 27)
  self:get_sprite():set_animation("immobilized")
  self:set_invincible(true)
end
