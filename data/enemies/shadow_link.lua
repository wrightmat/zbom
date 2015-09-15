local enemy = ...
local map = enemy:get_map()
local hero = map:get_hero()

local going_hero = false
local being_pushed = false
local main_sprite = nil
local sword_sprite = nil
local state = nil
local damage = 8

-- Shadow Link.

function enemy:on_created()
  self:set_life(16); self:set_damage(damage)
  main_sprite = self:create_sprite("enemies/shadow_link")
  sword_sprite = self:create_sprite("enemies/shadow_link_sword")
  self:set_size(32, 40); self:set_origin(16, 36)
  self:set_hurt_style("boss")
  self:set_attack_arrow("protected")
  self:set_attack_hookshot("protected")
  self:set_attack_consequence("boomerang", "protected")
  self:set_attack_consequence("explosion", "ignored")
  self:set_pushed_back_when_hurt(false)
  self:set_push_hero_on_sword(false)
  self:set_invincible_sprite(sword_sprite)
  self:set_attack_consequence_sprite(sword_sprite, "sword", "custom")
end

function enemy:on_restarted()
  if self:get_game():get_map():get_id() ~= "219" then -- Don't want Shadow Link to act during the game.
    state = nil
    if not being_pushed then
      if going_hero then
        enemy:go_hero()
      else
        enemy:go_random()
        enemy:check_hero()
      end
    end
  end
end

function enemy:check_hero()
  local _, _, layer = enemy:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
	and enemy:get_distance(hero) < 500
        and enemy:is_in_same_region(hero)

  if near_hero and not going_hero then
    enemy:go_hero()
  elseif near_hero and going_hero then
    enemy:go_attack()
  elseif not near_hero and going_hero then
    enemy:go_random()
  end
  sol.timer.stop_all(self)
  sol.timer.start(self, 1000, function() enemy:check_hero() end)
end

function enemy:on_movement_changed(movement)
  if not being_pushed then
    local direction4 = movement:get_direction4()
    main_sprite:set_direction(direction4)
    sword_sprite:set_direction(direction4)
  end
end

function enemy:on_movement_finished(movement)
  if being_pushed then
    enemy:go_hero()
  end
end

function enemy:on_obstacle_reached(movement)
  if being_pushed then
    enemy:go_hero()
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" and sprite == sword_sprite then
    sol.audio.play_sound("sword_tapping")
    being_pushed = true
    local x, y = enemy:get_position()
    local angle = hero:get_angle(enemy)
    local movement = sol.movement.create("straight")
    movement:set_speed(128)
    movement:set_angle(angle)
    movement:set_max_distance(26)
    movement:set_smooth(true)
    movement:start(enemy)
  end
end

function enemy:go_random()
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(enemy)
  being_pushed = false
  going_hero = false
end

function enemy:go_hero()
  local movement = sol.movement.create("target")
  movement:set_speed(48)
  movement:start(self)
  being_pushed = false
  going_hero = true
end

function enemy:go_attack()
  local movement = self:get_movement()
  if movement then movement:stop() end
  if math.random(3) == 1 then
    state = "spin_attack"
    sword_sprite:set_animation("spin_attack")
  else
    state = "attack"
    sword_sprite:set_animation("attack")
  end

  function sword_sprite:on_animation_finished(animation)
    enemy:check_hero()
  end
end

function enemy:on_attacking_hero(hero, enemy_sprite)
  if state == "spin_attack" then
    hero:start_hurt(damage*2)
  elseif state == "attack" then
    hero:start_hurt(damage*1.5)
  else
    hero:start_hurt(damage)
  end
end

function enemy:on_hurt(attack)
  self:go_attack()
end