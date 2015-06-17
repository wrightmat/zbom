local enemy = ...

-- Lynel

function enemy:on_created()
  self:set_life(6)
  self:set_damage(4)
  self:create_sprite("enemies/lynel")
  self:set_size(32, 32)
  self:set_origin(16, 27)
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("arrow", "protected")
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end