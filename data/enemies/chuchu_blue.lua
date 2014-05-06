local enemy = ...

-- Blue ChuChu: a basic enemy that follows the hero.

function enemy:on_created()
  self:set_life(2)
  self:set_damage(4)
  self:create_sprite("enemies/chuchu_blue")
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end
