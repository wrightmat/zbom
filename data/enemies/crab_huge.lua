local enemy = ...

-- Huge Crab: slow moving but much tougher crab (Overworld Boss).

function enemy:on_created()
  self:set_life(10)
  self:set_damage(4)
  self:create_sprite("enemies/crab_huge")
  self:set_size(256, 160)
  self:set_origin(172, 81)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(24)
  m:start(self)
end