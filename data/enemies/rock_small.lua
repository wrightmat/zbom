local enemy = ...

-- A small rock thrown by another enemy (octorok).

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/rock_small")
  self:set_size(16, 16)
  self:set_origin(8, 8)
  self:set_invincible()
  self:set_obstacle_behavior("flying")
  self:set_optimization_distance(200)
end

function enemy:on_obstacle_reached()
  self:remove()
end

function enemy:go(dir4)
  local angle = 0
  local m = sol.movement.create("straight")
  m:set_speed(192)
  if dir4 == 0 then angle = 0
  if dir4 == 1 then angle = math.pi / 2
  if dir4 == 2 then angle = math.pi
  if dir4 == 3 then angle = 3 * math.pi / 2
  m:set_angle(angle)
  m:set_smooth(false)
  m:start(self)
end
