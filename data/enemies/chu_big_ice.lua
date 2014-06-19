local enemy = ...

-- Big Ice Chu: A large gelatinous miniboss who
-- tries to either squish or freeze our hero.

local going_hero = false
local being_pushed = false
local base_sprite = nil
local head_sprite = nil
local timer

function enemy:on_created()
  self:set_life(10)
  self:set_damage(2)
  head_sprite = self:create_sprite("enemies/chu_big_ice")
  base_sprite = self:create_sprite("enemies/chu_big_ice_base")
  self:set_hurt_style("boss")
  self:set_size(48, 48)
  self:set_origin(24, 43)

  self:set_invincible_sprite(head_sprite)
  self:set_attack_consequence_sprite(head_sprite, "sword", "custom")
end

function enemy:on_restarted()
  if not being_pushed then
    if going_hero then
      self:go_hero()
    else
      self:go_random()
      self:check_hero()
    end
  end
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
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
    self:go_hero()
  end
end

function enemy:on_obstacle_reached(movement)
  if being_pushed then
    self:go_hero()
  end
end

function enemy:on_custom_attack_received(attack, sprite)
  if attack == "sword" and sprite == head_sprite then
    being_pushed = true
    head_sprite:set_animation("hurt")
    timer = sol.timer.start(self, 5000, function() self:go_hero() end)
  end
end

function enemy:go_random()
  local movement = sol.movement.create("random_path")
  movement:set_speed(32)
  movement:start(self)
  being_pushed = false
  going_hero = false
end

function enemy:go_hero()
  local movement = sol.movement.create("target")
  movement:set_speed(40)
  movement:start(self)
  being_pushed = false
  going_hero = true
end
