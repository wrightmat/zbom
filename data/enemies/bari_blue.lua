local enemy = ...

-- Bari: a flying enemy that follows the hero and tries to electrocute him.

local shocking = false

function enemy:on_created()
  self:set_life(2); self:set_damage(2)
  self:create_sprite("enemies/bari_blue")
  self:set_size(16, 16); self:set_origin(8, 13)
  self:set_attack_hookshot("immobilized")
end

function enemy:shock()
  shocking = true
  enemy:get_sprite():set_animation("shaking")
  sol.timer.start(enemy, math.random(10)*1000, function()
    enemy:get_sprite():set_animation("walking")
    shocking = false
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:restart() end)
  end)
end

function enemy:on_restarted()
  shocking = false
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  if math.random(10) < 5 then
    enemy:shock()
  end
end

function enemy:on_immobilized()
  shocking = false
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    self:hurt(1)
    enemy:remove_life(1)
  end
end
function enemy:on_attacking_hero(hero, enemy_sprite)
  if shocking == true then
    hero:start_electrocution(1500)
  else
    hero:start_hurt(2)
  end
end

function enemy:on_dying()
  -- It splits into two mini baris when it dies
  enemy:create_enemy({ breed = "bari_mini" })
  enemy:create_enemy({ breed = "bari_mini" })
end