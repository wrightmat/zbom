local enemy = ...

-- Dodongo

function enemy:on_created()
  self:set_life(3)
  self:set_damage(2)
  self:create_sprite("enemies/dodongo")
  self:set_size(48, 48)
  self:set_origin(24, 29)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end
