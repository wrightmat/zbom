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
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(40)
  m:start(self)
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  self:get_sprite():set_animation("immobilized")
  sol.timer.start(self, 10000, function() self:restart() end)
end
