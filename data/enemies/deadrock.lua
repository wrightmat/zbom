local enemy = ...
timer = nil

-- Deadrock: a basic enemy.

function enemy:on_created()
  self:set_life(6); self:set_damage(2)
  self:create_sprite("enemies/deadrock")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:go_random()
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
end

function enemy:on_hurt(attack)
  self:get_sprite():set_animation("immobilized")
  self:get_movement():stop()
  timer = sol.timer.start(self, 20000, function() enemy:go_random() end)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end