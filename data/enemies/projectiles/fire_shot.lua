local enemy = ...

-- A fireball thrown by another enemy (Lynel, Lizalfos).

function enemy:on_created()
  enemy:set_life(1); enemy:set_damage(4)
  enemy:create_sprite("enemies/fire_shot")
  enemy:set_size(16, 16); enemy:set_origin(8, 8)
  enemy:set_invincible()
  enemy:set_obstacle_behavior("flying")
  self:set_can_hurt_hero_running(true)
  self:set_minimum_shield_needed(2)
end

function enemy:on_obstacle_reached()
  enemy:remove()
end

function enemy:go(direction4)
  local angle = direction4 * math.pi / 2
  local movement = sol.movement.create("straight")
  movement:set_speed(192)
  movement:set_angle(angle)
  movement:set_smooth(false)
  movement:start(enemy)
  enemy:get_sprite():set_direction(direction4)
end