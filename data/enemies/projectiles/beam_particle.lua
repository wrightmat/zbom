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
  self:set_minimum_shield_needed(3) -- Light shield.
  self:set_obstacle_behavior("flying")
  self:set_optimization_distance(10)
  -- If particle isn't already destroyed after 5 seconds, do it manually.
  sol.timer.start(self, 5000, function() enemy:explode() end)
end

function enemy:explode()
  self:remove()
end