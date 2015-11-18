local enemy = ...
local going_hero = false
local timer

-- Moth: a small flying enemy that follows the hero in the air, but is attracted to flame.

function enemy:on_created()
  self:set_life(1); self:set_damage(1)
  self:create_sprite("enemies/moth")
  self:set_size(16, 16); self:set_origin(8, 8)
  self:set_hurt_style("monster")
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_push_hero_on_sword(false)
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
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer and self:get_distance(hero) < 100

  if self:get_map():get_entity("torch_moth") ~= nil then
    local torch_moth = self:get_map():get_entity("torch_moth")
    if torch_moth:get_sprite():get_animation() == "lit" then
      self:go_torch()
    end
  end

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:go_random()
  local m = sol.movement.create("random")
  m:set_speed(32)
  m:start(self)
  going_hero = false
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(48)
  m:start(self)
  going_hero = true
end

function enemy:go_torch()
  local m = sol.movement.create("target")
  m:set_target(self:get_map():get_entity("torch_moth"))
  m:set_speed(32)
  m:start(self)
  going_hero = false
  timer = sol.timer.start(self, math.random(10)*500, function() self:check_hero() end)
end