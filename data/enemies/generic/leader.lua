local enemy = ...

-- ranged leader type
local properties = {}
local main_sprite = nil
local towards_hero = false
local away_hero = false
local attacked_hero = false
local towards_enemy = false
local timer, fire_timer

function enemy:set_properties(prop)
  properties = prop
  if properties.life == nil then
    properties.life = 2
  end
  if properties.damage == nil then
    properties.damage = 2
  end
  if properties.play_hero_seen_sound == nil then
    properties.play_hero_seen_sound = false
  end
  if properties.stopped_speed == nil then
    properties.stopped_speed = 0
  end
  if properties.normal_speed == nil then
    properties.normal_speed = 32
  end
  if properties.faster_speed == nil then
    properties.faster_speed = 64
  end
  if properties.hurt_style == nil then
    properties.hurt_style = "normal"
  end
    if properties.regen == nil then
    properties.regen = 0
  end
end

function enemy:on_created()
  self:set_life(properties.life)
  self:set_damage(properties.damage)
  self:set_hurt_style(properties.hurt_style)
  main_sprite = self:create_sprite(properties.main_sprite)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attack_consequence("sword", 1)
  self:begin()
end

function enemy:begin()
  local get_life = enemy:get_life()
  local ehalflife = .5 * properties.life 
  local hero = self:get_map():get_entity("hero")
  local _, _, layer = self:get_position()
  local _, _, hero_layer = hero:get_position()
  local spawn_line = layer == hero_layer 
     and self:get_distance(hero) > 200
  local sight_line = layer == hero_layer 
     and self:get_distance(hero) < 100
  local life_recharge = enemy:get_life() < properties.life
  local life_low = enemy:get_life() < ehalflife 
     and self:get_distance(hero) < 64
  if spawn_line then
    self:go_spawn()
  elseif not sight_line then
    self:go_random()
  elseif sight_line and not towards_hero and not away_hero then
    self:go_hero()
  elseif not sight_line and not towards_hero then
    self:go_random()
  elseif sight_line and towards_hero then
    if not fire_timer then self:fire() 
  elseif life then
    self:go_away()
  else
    self:go_random()
    end
  if life_recharge then
    self:get_game():add_life(properties.regen)
  end
  timer = sol.timer.start(self, 1000, function() self:begin() 
  return true
  end)
  end
end

function enemy:on_restarted()
  timer = sol.timer.start(self, 1000, function() self:begin() 
  return true
  end)
end

function enemy:on_hurt()
  if timer ~= nil then
    timer:stop()
    timer = nil
  end
  self:begin()
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  main_sprite:set_direction(direction4)
end

function enemy:go_spawn()
    local x, y, layer = self:get_position()
    local direction = self:get_sprite():get_direction()
    
  if self:get_map():get_entities_count("lizalfos") <= 3 then
     if direction == 0 then
     x = x + 32
     elseif direction == 1 then
     y = y - 32
     elseif direction == 2 then
     x = x - 32
     elseif direction == 3 then
     y = y + 32
     end

    local spawn = enemy:create_enemy{
      name = "lizalfos",
      breed = "lizalfos",
      x = x,
      y = y,
      layer = layer,
      direction = direction,
      treasure_name = "random"
    }
    spawn:set_position(x, y, layer)
    spawn:set_optimization_distance(0)
  end
end

function enemy:go_away()
  local x, y = self:get_map():get_entity("hero"):get_position()
  local direction = self:get_sprite():get_direction()
    if direction == 0 then
    x = x + 128
    elseif direction == 1 then
    y = y - 128
    elseif direction == 2 then
    x = x - 128
    elseif direction == 3 then
    y = y + 128
    end
  
  local m = sol.movement.create("target")
  m:set_speed(properties.faster_speed)
  m:set_target(x, y)
  m:set_ignore_obstacles(false)
  m:start(self)
  away_hero = true 
  towards_hero = false
end

function enemy:go_random()
  self:get_sprite():set_animation("walking")
  local m = sol.movement.create("random_path")
  m:set_speed(properties.normal_speed)
  m:start(self)
  towards_hero = false
  away_hero = false
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(properties.normal_speed)
  m:start(self)
  towards_hero = true
  away_hero = false
end

function enemy:go_static()
  local m = sol.movement.create("target")
  m:set_speed(0)
  m:start(self)
  towards_hero = false
end

function enemy:fire()
  self:get_sprite():set_animation("firing")
  fire_timer = sol.timer.start(self, 100, function()
    local x, y, layer = self:get_position()
    local direction = self:get_sprite():get_direction()
    
    if direction == 0 then
      x = x + 16
    elseif direction == 1 then
      y = y - 16
    elseif direction == 2 then
      x = x - 16
    elseif direction == 3 then
      y = y + 16
    end
    if rock == nil or not rock:exists() then
    local rock = enemy:create_enemy{
      x = x,
      y = y,
      layer = layer,
      direction = direction,
      breed = "projectile"
    }
    self.created = true
    rock:set_position(x, y, layer)
    rock:set_optimization_distance(0)
    end
    end)
    sol.timer.start(self, 1000, function()
      fire_timer = nil
      self:begin()
    end)
  end