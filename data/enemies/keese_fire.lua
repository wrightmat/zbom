local enemy = ...

-- Fire Keese (bat): Basic flying enemy, but also on fire!

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/keese_fire")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attack_consequence("sword", 1)
  self:set_attack_consequence("arrow", 1)
  self:set_attack_consequence("hookshot", 1)
  self:set_attack_consequence("boomerang", 1)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
end

function enemy:on_restarted()
  if self:get_movement() == nil then
    self:go_hero()
  end
end

-- Goes toward the hero.
function enemy:go_hero()
  local angle = self:get_angle(self:get_map():get_entity("hero"))
  local m = sol.movement.create("straight")
  m:set_speed(64)
  m:set_angle(angle)
  m:set_max_distance(160)
  m:set_ignore_obstacles(true)
  m:start(self)
end

-- Makes circles around the hero.
function enemy:go_circle(center_entity)
  local m = sol.movement.create("circle")
  m:set_center(center_entity, 0, -21)
  m:set_radius(48)
  m:set_initial_angle(math.pi / 2)
  m:set_angle_speed(100)
  m:set_ignore_obstacles(true)
  m:start(self)
end
