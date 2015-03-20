local enemy = ...

-- Peahat: a flying enemy that follows the hero in the air (and lands periodically)

local state = "stopped"
local timer

function enemy:on_created()
  self:set_life(3)
  self:set_damage(4)
  self:create_sprite("enemies/peahat")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(true)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(32, 48)
  self:set_origin(16, 45)
end

function enemy:on_obstacle_reached(movement)
  if not going_hero then
    self:go_random()
    self:check_hero()
  end
end

function enemy:on_restarted()
  self:go_random()
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
end

function enemy:check_hero()
  local sprite = self:get_sprite()
  local hero = self:get_map():get_entity("hero")
  -- Check whether the hero is close.
  if self:get_distance(hero) <= 96 and state ~= "going" then
    self:go_hero()
  elseif self:get_distance(hero) > 96 and state ~= "random" then
    self:go_random()
  elseif self:get_distance(hero) > 144 then
    self:get_sprite():set_animation("immobilized")
    state = "stopped"
    self:stop_movement()
    self:set_invincible_false()
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:go_random()
  sol.audio.play_sound("peahat_awake")
  self:get_sprite():set_animation("walking")
  self:set_invincible()
  local m = sol.movement.create("random")
  m:set_speed(56)
  m:start(self)
  state = "random"
  -- randomly stop to allow the hero an opportunity to attack
  if math.random(10) <= 5 then
    self:get_sprite():set_animation("immobilized")
    state = "stopped"
    self:stop_movement()
    self:set_invincible_false()
    sol.timer.start(self, 5000, function() self:restart() end)
  end
end

function enemy:go_hero()
  sol.audio.play_sound("peahat_awake")
  self:get_sprite():set_animation("walking")
  self:set_invincible()
  local m = sol.movement.create("target")
  m:set_ignore_obstacles(true)
  m:set_speed(64)
  m:start(self)
  state = "going"
  -- randomly stop to allow the hero an opportunity to attack
  if math.random(10) <= 3 then
    self:get_sprite():set_animation("immobilized")
    state = "stopped"
    self:stop_movement()
    self:set_invincible_false()
    sol.timer.start(self, 5000, function() self:restart() end)
  end
end

function enemy:set_invincible_false()
  enemy:set_attack_consequence("sword", 1)
  enemy:set_attack_consequence("arrow", 1)
  enemy:set_attack_consequence("boomerang", "immobilized")
  enemy:set_attack_consequence("hookshot", "immobilized")
  enemy:set_attack_consequence("explosion", 1)
end
