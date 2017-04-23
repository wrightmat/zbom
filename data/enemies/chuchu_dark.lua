local enemy = ...

-- Dark ChuChu: a basic overworld enemy that follows the hero.
-- The dark variety will curse the hero if touched.

function enemy:on_created()
  self:set_life(6); self:set_damage(12)
  self:create_sprite("enemies/chuchu_dark")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_hookshot("immobilized")
end

function enemy:on_restarted()
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
end

function enemy:disappear()
  local sprite = self:get_sprite()
  sprite:set_animation("disappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_enabled(false)
    sol.timer.start(enemy, math.random*5000, function() enemy:reappear() end)
  end
end

function enemy:reappear()
  local sprite = self:get_sprite()
  sprite:set_animation("reappearing")

  function sprite:on_animation_finished(animation)
    enemy:set_enabled(true)
    enemy:restart()
  end
end

function enemy:on_attacking_hero(hero)
  if not hero:is_invincible() then
    -- Hero is cursed.
    hero:start_hurt(6)
    hero:start_cursed(3000)
    hero:set_invincible(true, 3500)
  end
end

-- Prevent enemies from "piling up" as much, which makes it easy to kill multiple in one hit.
function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
  if enemy:is_traversable() then
    enemy:set_traversable(false)
    sol.timer.start(200, function() enemy:set_traversable(true) end)
  end
end