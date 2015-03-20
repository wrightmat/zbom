local enemy = ...

-- Deadrock: a basic enemy.

function enemy:on_created()
  self:set_life(2)
  self:set_damage(2)
  self:create_sprite("enemies/deadrock")
  self:set_size(32, 32)
  self:set_origin(16, 29)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
end
