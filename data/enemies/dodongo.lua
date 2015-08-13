local enemy = ...

-- Dodongo

function enemy:on_created()
  self:set_life(2); self:set_damage(2)
  self:create_sprite("enemies/dodongo")
  self:set_size(48, 48); self:set_origin(24, 29)
  self:set_attack_consequence("sword", "protected")
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