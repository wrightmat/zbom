local enemy = ...

-- Stone Arrghus: Miniboss who creates small rocks and has to be hit in the eye with arrows to be hurt
-- These are the small rocks - cannot be hit with arrows

local properties = {}
local going_hero = false
local timer

function enemy:on_created()
  self:set_life(1)
  self:set_damage(2)
  self:create_sprite("enemies/arrghus_baby")
  self:set_hurt_style("monster")
  self:set_pushed_back_when_hurt(true)
  self:set_push_hero_on_sword(false)
  self:set_size(16, 16)
  self:set_origin(8, 13)
  self:set_attack_consequence("arrow", "protected")
end

function enemy:on_movement_changed(movement)
  local direction4 = movement:get_direction4()
  local sprite = self:get_sprite()
  sprite:set_direction(direction4)
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
  local near_hero = layer == hero_layer
    and self:get_distance(hero) < 100

  if near_hero and not going_hero then
    self:go_hero()
  elseif not near_hero and going_hero then
    self:go_random()
  end
  timer = sol.timer.start(self, 1000, function() self:check_hero() end)
end

function enemy:go_random()
  local m = sol.movement.create("random")
  m:set_speed(24)
  m:start(self)
  going_hero = false
end

function enemy:go_hero()
  local m = sol.movement.create("target")
  m:set_speed(32)
  m:start(self)
  going_hero = true
end