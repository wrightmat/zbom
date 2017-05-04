local enemy = ...

-- A lava ball thrown by another enemy (Smog miniboss).

function enemy:on_created()
  enemy:set_life(1); enemy:set_damage(8)
  local sprite = enemy:create_sprite("enemies/lava_shot")
  enemy:set_size(32, 24); enemy:set_origin(16, 21)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  self:set_can_hurt_hero_running(true)
  self:set_layer_independent_collisions(true)
  self:set_minimum_shield_needed(2)

  function sprite:on_animation_finished(animation)
    enemy:remove()
  end
end

function enemy:on_restarted()
  -- By default, go to where the hero is now.
  local x, y = self:get_map():get_entity("hero"):get_position()
  x = x + math.random(-32, 32)
  y = y + math.random(-32, 32)
  local m = sol.movement.create("target")
  m:set_speed(144)
  m:set_target(x, y)
  m:set_ignore_obstacles(false)
  m:start(self)
  sol.timer.start(self, 2000, function() self:on_movement_finished() end)
end

function enemy:go(direction4)
  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)
end