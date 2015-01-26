local enemy = ...

-- Plasmarine ball: ball of electricity shot by Plasmarine

function enemy:on_created()
  self:set_life(1)
  self:set_damage(4)
  self:create_sprite("enemies/plasmarine_ball")
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_optimization_distance(0)
  self:set_attack_consequence("sword", "custom")
  self:set_attack_consequence("hookshot", "ignored")
end

function enemy:on_movement_finished(movement)
  self:remove()
end

function enemy:on_restarted()
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:set_ignore_obstacles(true)
  m:set_target(enemy:get_game():get_hero())
  m:start(self)
end

function enemy:on_custom_attack_received(attack, sprite)
  -- the hero bats the electric ball in the other direction with the sword
  if attack == "sword" then
    local angle = self:get_movement():get_angle()
    local m = sol.movement.create("straight")
    m:set_speed(64)
    m:set_ignore_obstacles(true)
    m:set_angle(angle+math.pi)
    m:start(self)
  end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  -- the ball electrocutes the hero when it touches him
  hero:start_electrocution(1500)
end
