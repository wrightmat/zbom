local enemy = ...

-- Swamp Flower, Small: a swamp flower that hurts the hero.

function enemy:on_created()
  self:set_life(3); self:set_damage(6)
  self:create_sprite("enemies/swamp_flower_small")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_pushed_back_when_hurt(false)
  self:set_obstacle_behavior("swimming")
end