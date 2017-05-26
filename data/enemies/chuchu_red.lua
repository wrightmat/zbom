local enemy = ...

-- Red ChuChu: a basic overworld enemy that follows the hero.
-- The red variety can disappear into the ground.

function enemy:on_created()
  self:set_life(2); self:set_damage(4)
  self:create_sprite("enemies/chuchu_red")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_hookshot("immobilized")
  self:set_attack_consequence("fire", "protected")
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