local enemy = ...

-- Green ChuChu: a basic overworld enemy that follows the hero.
-- The green variety is the first discovered and easiest in this game.

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  self:create_sprite("enemies/chuchu_green")
  self:set_size(16, 16); self:set_origin(8, 13)
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end