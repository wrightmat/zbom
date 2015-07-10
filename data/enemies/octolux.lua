local enemy = ...

-- Octorok: simple enemy who wanders and shoots rocks

local going_hero = false
local near_hero = false
local shooting = false
local timer, shoot_timer

function enemy:on_created()
  self:set_life(3)
  self:set_damage(6)
  self:create_sprite("enemies/octolux")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_size(16, 16)
  self:set_origin(8, 13)
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
end

function enemy:on_obstacle_reached(movement)
  self:check_hero()
end

function enemy:on_restarted()
  if not near_hero then
    self:go_random()
  else
    self:go_hero()
  end
  self:check_hero()
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
  if shoot_timer ~= nil then
    shoot_timer:stop()
    shoot_timer = nil
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
    self:go_random()
  elseif near_hero and going_hero then
    if not shoot_timer then self:shoot() end
  end

  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:shoot()
  self:stop_movement()
  local d = self:get_sprite():get_direction()
  self:get_sprite():set_animation("shooting")
  shoot_timer = sol.timer.start(self, 100, function()
    local rock = self:create_enemy{
      breed = "rock_lux",
      direction = d
    }
    sol.timer.start(self, 1000, function()
      shoot_timer = nil
      self:check_hero()
    end)
  end)
end

function enemy:go_random()
  local m = sol.movement.create("straight")
  m:set_speed(40)
  m:start(self)
  d = m:get_direction4()
  going_hero = false
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(48)
  m:start(self)
  d = m:get_direction4()
  going_hero = true
end
