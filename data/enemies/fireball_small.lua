local enemy = ...

-- A small fireball which automatically moves toward the hero.

function enemy:on_created()
  self:set_life(1); self:set_damage(4)
  self:create_sprite("enemies/fireball_small")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  sol.timer.start(self, 2000, function()
    self:restart()
    return true
  end)
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:on_restarted()
  local hero = self:get_map():get_entity("hero")
  local near_hero = self:get_distance(hero) < 250 and self:is_in_same_region(hero)

  if near_hero then
    local angle = self:get_angle(hero)
    local m = sol.movement.create("straight")
    m:set_speed(144)
    m:set_angle(angle)
    m:set_smooth(false)
    m:set_ignore_obstacles(false)
    m:start(self)
  end
end