local enemy = ...

-- Green ChuChu: a basic overworld enemy that follows the hero.
-- The green variety is the first discovered and easiest in this game.

function enemy:on_created()
  self:set_life(1); self:set_damage(2)
  self:create_sprite("enemies/chuchu_green")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_hookshot("immobilized")
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end

-- Prevent enemies from "piling up" as much, which makes it easy to kill multiple in one hit.
function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
  if enemy:is_traversable() then
    enemy:set_traversable(false)
    sol.timer.start(200, function() enemy:set_traversable(true) end)
  end
end