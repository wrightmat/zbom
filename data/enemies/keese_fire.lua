local enemy = ...

-- Fire Keese (bat): Basic flying enemy, but also on fire!

local going_hero = false
local timer

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/keese_fire")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_obstacle_behavior("flying")
  self:set_layer_independent_collisions(true)
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_restarted()
  self:go_circle()
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
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  elseif not near_hero and not going_hero then
    self:go_circle(hero)
  end
  timer = sol.timer.start(self, 2000, function() self:check_hero() end)
end

function enemy:go_hero()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("target")
  m:set_speed(64)
  m:start(self)
  going_hero = true
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("circle")
  m:set_radius(32)
  m:set_radius_speed(48)
  m:start(self)
  going_hero = false
end

function enemy:go_circle(center_entity)
  local m = sol.movement.create("circle")
  m:set_center(center_entity, 0, -21)
  m:set_radius(48)
  m:set_initial_angle(math.pi / 2)
  m:set_angle_speed(100)
  m:set_ignore_obstacles(true)
  m:start(self)
  going_hero = true
end
