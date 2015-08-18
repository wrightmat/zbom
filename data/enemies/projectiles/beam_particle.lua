local enemy = ...
local particle_sprite = "enemies/beamos_particle"
local damage = 1

-- Default parameters of the beam particle.

function enemy:on_created(properties)
  -- Get properties and target coordinates.
  if properties then
    if properties.particle_sprite then particle_sprite = properties.particle_sprite end
    if properties.damage then damage = properties.damage end
  end
  -- Set properties.
  self:set_size(8, 8)
  self:set_invincible()
  self:create_sprite(particle_sprite)
  self:set_damage(damage)
  self:set_minimum_shield_needed(3) --light shield
end

function enemy:explode()
  self:remove()
end