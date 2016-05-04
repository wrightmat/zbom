local enemy = ...
local particle_sprite = "enemies/beamos_laser"
local damage = 1
local speed = 200
local max_distance = 100
local time_between_particles = 20
local particles_per_beam = 30
local stop_time = 1000

-- Big Armos Status: Shoots lasers from its eye.

function enemy:on_created()
  self:set_life(2); self:set_damage(2)
  self:create_sprite("enemies/armos_big")
  self:set_invincible(); self:set_can_attack(false); self:set_traversable(true)
  self:set_size(16,16); self:set_origin(8,13)
  self:set_pushed_back_when_hurt(false)
end

function enemy:on_restarted()
  -- Start throwing beam particles.
  local properties = {particle_sprite = particle_sprite, damage = damage, breed = "projectiles/beam_particle"}
  local particles = particles_per_beam
  -- Function used to shoot a beam.
  local function shoot(tx, ty)
    -- Create new particle.
	  local e = enemy:create_enemy(properties)
	  -- Create movement. Destroy enemy when the movement ends.
    local m = sol.movement.create("target")
    m:set_target(tx, ty); m:set_speed(speed)
    function m:on_finished() e:explode() end
    function m:on_obstacle_reached() e:explode() end
    m:start(e)
    -- Stop creating particles if necessary.
	  particles = particles -1
    if particles <= 0 then
      enemy:stop_firing()
      return 
	  else
	    sol.timer.start(enemy, time_between_particles, function()
	      shoot(tx, ty)
	    end)
	  end
  end
  -- Check if hero is close to shoot.
  sol.timer.start(enemy, 50, function()
    local tx, ty, _ = enemy:get_map():get_hero():get_position()
	  if enemy:get_distance(tx, ty) < max_distance then
	    sol.timer.start(self, 1000, function() shoot(tx-5, ty) end)
	    return false -- Stop timer.
	  end
	  return true
  end)
end

-- Function to stop firing for a while.
function enemy:stop_firing()
  sol.timer.stop_all(enemy)
  sol.timer.start(enemy, stop_time, function() enemy:on_restarted() end)
end