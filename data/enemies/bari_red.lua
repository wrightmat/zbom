local enemy = ...

-- Bari: a flying enemy that follows the hero
--       and tries to electricute him.

function enemy:on_created()
  self:set_life(3)
  self:set_damage(4)
  self:create_sprite("enemies/bari_red")
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end
