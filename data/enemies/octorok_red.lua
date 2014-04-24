local enemy = ...

-- Octorok: simple enemy who wanders and shoots rocks

local going_hero = false
local awaken = false
local timer

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/octorok_red")
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
  if awaken and not going_hero then
    self:check_hero()
  end
end

function enemy:on_restarted()
  if not awaken then
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
end

function enemy:check_hero()
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if awaken then
    if near_hero and not going_hero then
      self:go_hero()
    elseif not near_hero and going_hero then
      self:go_random()
    end
  elseif not awaken and near_hero then
    self:wake_up()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:wake_up()
  self:stop_movement()
  local sprite = self:get_sprite()
  sprite:set_animation("shooting")
  local x, y, l = self:get_position()
  local sx, sy = 0
  if d == 0 then
    sx = x + 8
    sy = y
  end
  if d == 1 then
    sy = y - 8
    sx = x
  end
  if d == 2 then
    sx = x - 8
    sy = y
  end
  if d ==3 then
    sy = y +8
    sx = x
  end
  sol.timer.start(self, 1000, function()
    local rock = self:create_enemy{
      breed = "rock_small",
      x = sx,
      y = sy
    }
    rock:go(d)
    sol.timer.start(self, 2000, function()
      self:check_hero()
    end)
  end)
end

function enemy:go_random()
  local m = sol.movement.create("straight")
  m:set_speed(32)
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
