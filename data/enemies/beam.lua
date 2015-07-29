local enemy = ...

-- Beam: fired by another enemy such as a beamos

local timers = {}

function enemy:on_created()
  self:set_life(1)
  self:set_damage(1)
  self:create_sprite("enemies/beamos")
  self:set_size(8, 8)
  self:set_origin(4, 6)
  self:set_invincible(true)
  self:set_minimum_shield_needed(3)
  self:get_sprite():set_animation("beam")
end

function enemy:on_update()

end