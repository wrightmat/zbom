local enemy = ...

-- Plasmarine: a boss which floats around shooting
--  electricity balls in order to electricute hero.

function enemy:on_created()
  self:set_life(8)
  self:set_damage(4)
  self:create_sprite("enemies/plasmarine_blue")
  self:set_attack_consequence("arrow", "ignored")
  self:set_attack_consequence("boomerang", "ignored")
  self:set_attack_consequence("sword", "protected")
  self:set_attack_consequence("explosion", "ignored")
  self:set_attack_consequence("hookshot", "immobilized")
  self:set_size(32, 32)
  self:set_origin(16, 28)
end

function enemy:on_restarted()
  enemy:get_sprite():set_animation("walking")
  local m = sol.movement.create("path_finding")
  m:set_speed(32)
  m:start(self)
  local rand = math.random(10)
  if rand < 7 then
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:shoot_ball() end)
  else
    sol.timer.start(enemy, math.random(10)*1000, function() enemy:create_bari() end)
  end
end

function enemy:on_collision_enemy(other_enemy, other_sprite, my_sprite)
  if other_enemy:get_breed() == "plasmarine_ball" then
    if other_sprite:get_direction() == 2 or other_sprite:get_direction() == 3 then
      sol.timer.start(self, 100, function()
	self:hurt(1)
	enemy:remove_life(1)
      end)
    end
  end
end

function enemy:on_hurt_by_sword(hero, enemy_sprite)
  if enemy_sprite == "immobilized" then
    hero:start_electrocution(1500)
  end
end
function enemy:on_attacking_hero(hero, enemy_sprite)
  if enemy_sprite == "immobilized" then
    hero:start_electrocution(1500)
  else
    hero:start_hurt(4)
  end
end

function enemy:shoot_ball()
  -- If the other Plasmarine is dead, then this one's electricity
  -- needs to be able to hurt him, otherwise he won't die.
  -- Normally, only the other Plasmarine's electricity can hurt this one.
  if not enemy:get_map():has_entity("boss_plasmarine_red") then
    ball = enemy:create_enemy({ x = 10, y = 10, breed = "plasmarine_ball", direction = 2 })
  else
    ball = enemy:create_enemy({ breed = "plasmarine_ball", direction = 0 })
  end
  enemy:restart()
end

function enemy:create_bari()
  enemy:get_sprite():set_animation("shaking")
  enemy:create_enemy({ breed = "bari_blue" })
  sol.timer.start(enemy, 1000, function() enemy:restart() end)
end
